<?php

declare(strict_types=1);

namespace App\Services;

use App\Enums\SaleStatus;
use App\Models\PaymentMethod;
use App\Models\Product;
use App\Models\Sale;
use App\Models\Setting;
use App\Models\Shift;
use App\Models\User;
use Illuminate\Support\Facades\DB;
use Illuminate\Validation\ValidationException;

class CheckoutService
{
    public function __construct(
        private readonly PricingService $pricing,
        private readonly StockService $stock,
        private readonly ShiftService $shifts,
        private readonly DocumentNumberService $numbers,
    ) {}

    /**
     * @param  array<string, mixed>  $payload
     */
    public function checkout(User $cashier, array $payload): Sale
    {
        return DB::transaction(function () use ($cashier, $payload): Sale {
            $existing = Sale::query()
                ->where('idempotency_key', $payload['idempotency_key'])
                ->first();

            if ($existing) {
                return $existing->load(['items', 'payments.paymentMethod', 'cashier', 'customer', 'shift']);
            }

            $shift = Shift::query()
                ->where('user_id', $cashier->id)
                ->where('status', 'open')
                ->lockForUpdate()
                ->first();

            if (! $shift) {
                throw ValidationException::withMessages([
                    'shift' => 'Buka shift terlebih dahulu sebelum melakukan transaksi.',
                ]);
            }

            $items = collect($payload['items'] ?? []);
            if ($items->isEmpty()) {
                throw ValidationException::withMessages(['items' => 'Keranjang masih kosong.']);
            }

            $products = Product::query()
                ->whereIn('id', $items->pluck('product_id')->unique()->all())
                ->get()
                ->keyBy('id');

            $lines = [];
            foreach ($items as $item) {
                $product = $products->get((int) $item['product_id']);

                if (! $product || ! $product->is_active) {
                    throw ValidationException::withMessages(['items' => 'Produk tidak ditemukan atau tidak aktif.']);
                }

                $qty = (float) $item['qty'];
                if ($qty <= 0) {
                    throw ValidationException::withMessages(['items' => "Qty {$product->name} tidak valid."]);
                }

                $lines[] = [
                    'product_id' => $product->id,
                    'name' => $product->name,
                    'qty' => $qty,
                    'unit_price' => (float) $product->sell_price,
                    'cost_price' => (float) $product->cost_price,
                    'discount' => (float) ($item['discount'] ?? 0),
                    'is_taxable' => (bool) $product->is_taxable,
                ];
            }

            $taxRate = (float) Setting::get('tax_rate', '0') / 100;
            $taxIncluded = Setting::get('tax_included', '0') === '1';
            $roundingStep = (int) Setting::get('rounding_step', '0');

            $pricing = $this->pricing->calculate(
                $lines,
                (float) ($payload['discount_total'] ?? 0),
                $taxIncluded,
                $taxRate,
                $roundingStep,
            );

            $payments = collect($payload['payments'] ?? []);
            $paidTotal = round((float) $payments->sum('amount'), 2);

            if ($payments->isEmpty() || $paidTotal < $pricing['grand_total']) {
                throw ValidationException::withMessages([
                    'payments' => 'Total pembayaran kurang dari total tagihan.',
                ]);
            }

            $methodIds = PaymentMethod::query()
                ->whereIn('id', $payments->pluck('payment_method_id')->all())
                ->where('is_active', true)
                ->pluck('id')
                ->all();

            foreach ($payments as $payment) {
                if (! in_array((int) $payment['payment_method_id'], $methodIds, true)) {
                    throw ValidationException::withMessages(['payments' => 'Metode pembayaran tidak valid.']);
                }
            }

            $invoiceNumber = $this->numbers->next('INV', now()->format('Ymd'));

            $sale = Sale::create([
                'invoice_number' => $invoiceNumber,
                'idempotency_key' => $payload['idempotency_key'],
                'shift_id' => $shift->id,
                'cashier_id' => $cashier->id,
                'customer_id' => $payload['customer_id'] ?? null,
                'subtotal' => $pricing['subtotal'],
                'discount_total' => $pricing['discount_total'],
                'tax_total' => $pricing['tax_total'],
                'rounding' => $pricing['rounding'],
                'grand_total' => $pricing['grand_total'],
                'paid_total' => $paidTotal,
                'change_amount' => round(max(0, $paidTotal - $pricing['grand_total']), 2),
                'status' => SaleStatus::Paid->value,
            ]);

            foreach ($pricing['lines'] as $line) {
                $sale->items()->create([
                    'product_id' => $line['product_id'],
                    'name_snapshot' => $line['name'],
                    'qty' => $line['qty'],
                    'unit_price' => $line['unit_price'],
                    'cost_price' => $line['cost_price'],
                    'discount' => $line['discount'],
                    'tax' => $line['tax'],
                    'line_total' => $line['line_total'],
                ]);
            }

            foreach ($payments as $payment) {
                $sale->payments()->create([
                    'payment_method_id' => $payment['payment_method_id'],
                    'amount' => $payment['amount'],
                    'reference' => $payment['reference'] ?? null,
                ]);
            }

            foreach ($pricing['lines'] as $line) {
                $product = $products->get($line['product_id']);
                $this->stock->decrease($product, $line['qty'], Sale::class, $sale->id, $cashier->id, $invoiceNumber);
            }

            activity()
                ->causedBy($cashier)
                ->performedOn($sale)
                ->withProperties(['invoice' => $invoiceNumber, 'grand_total' => $pricing['grand_total']])
                ->log('Transaksi penjualan dibuat');

            return $sale->load(['items', 'payments.paymentMethod', 'cashier', 'customer', 'shift']);
        });
    }
}
