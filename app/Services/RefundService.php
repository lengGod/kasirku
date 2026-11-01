<?php

declare(strict_types=1);

namespace App\Services;

use App\Enums\SaleStatus;
use App\Enums\ShiftStatus;
use App\Models\Product;
use App\Models\Refund;
use App\Models\Sale;
use App\Models\Shift;
use App\Models\User;
use Illuminate\Support\Facades\DB;
use Illuminate\Validation\ValidationException;

class RefundService
{
    public function __construct(
        private readonly StockService $stock,
        private readonly DocumentNumberService $numbers,
    ) {}

    public function void(Sale $sale, User $user, string $reason): Refund
    {
        return DB::transaction(function () use ($sale, $user, $reason): Refund {
            $sale = Sale::query()->whereKey($sale->id)->lockForUpdate()->firstOrFail();

            if ($sale->status !== SaleStatus::Paid) {
                throw ValidationException::withMessages(['sale' => 'Hanya transaksi berstatus dibayar yang bisa di-void.']);
            }

            if (! $sale->created_at->isToday()) {
                throw ValidationException::withMessages(['sale' => 'Void hanya diizinkan pada hari yang sama.']);
            }

            $shift = $this->openShift($user);

            $refund = Refund::create([
                'refund_number' => $this->numbers->next('RTN', now()->format('Ymd')),
                'sale_id' => $sale->id,
                'shift_id' => $shift->id,
                'total' => $sale->grand_total,
                'reason' => $reason,
                'approved_by' => $user->id,
                'created_by' => $user->id,
            ]);

            foreach ($sale->items as $item) {
                $refund->items()->create([
                    'sale_item_id' => $item->id,
                    'qty' => $item->qty,
                    'amount' => $item->line_total,
                    'restock' => true,
                ]);

                $product = Product::query()->find($item->product_id);
                if ($product) {
                    $this->stock->increase($product, (float) $item->qty, Refund::class, $refund->id, $user->id, 'Void '.$sale->invoice_number);
                }
            }

            $sale->update([
                'status' => SaleStatus::Voided->value,
                'voided_by' => $user->id,
                'void_reason' => $reason,
                'voided_at' => now(),
            ]);

            activity()
                ->causedBy($user)
                ->performedOn($sale)
                ->withProperties(['refund_number' => $refund->refund_number, 'reason' => $reason])
                ->log('Transaksi di-void');

            return $refund->load('items');
        });
    }

    /**
     * @param  array<int, array{sale_item_id:int, qty:float, restock?:bool}>  $items
     */
    public function refund(Sale $sale, array $items, User $user, string $reason): Refund
    {
        return DB::transaction(function () use ($sale, $items, $user, $reason): Refund {
            $sale = Sale::query()->with('items')->whereKey($sale->id)->lockForUpdate()->firstOrFail();

            if (! in_array($sale->status, [SaleStatus::Paid, SaleStatus::PartialRefund], true)) {
                throw ValidationException::withMessages(['sale' => 'Transaksi ini tidak bisa diretur.']);
            }

            $shift = $this->openShift($user);
            $refund = Refund::create([
                'refund_number' => $this->numbers->next('RTN', now()->format('Ymd')),
                'sale_id' => $sale->id,
                'shift_id' => $shift->id,
                'total' => 0,
                'reason' => $reason,
                'approved_by' => $user->id,
                'created_by' => $user->id,
            ]);

            $total = 0.0;
            $refundedQty = [];

            foreach ($items as $row) {
                $saleItem = $sale->items->firstWhere('id', (int) $row['sale_item_id']);
                if (! $saleItem) {
                    throw ValidationException::withMessages(['items' => 'Item transaksi tidak ditemukan.']);
                }

                $qty = (float) $row['qty'];
                if ($qty <= 0) {
                    continue;
                }

                $already = (float) $saleItem->refundItems()->sum('qty');
                $remaining = (float) $saleItem->qty - $already;

                if ($qty > $remaining) {
                    throw ValidationException::withMessages([
                        'items' => "Qty retur {$saleItem->name_snapshot} melebihi sisa yang bisa diretur.",
                    ]);
                }

                $amount = round(((float) $saleItem->line_total / (float) $saleItem->qty) * $qty, 2);
                $restock = (bool) ($row['restock'] ?? true);

                $refund->items()->create([
                    'sale_item_id' => $saleItem->id,
                    'qty' => $qty,
                    'amount' => $amount,
                    'restock' => $restock,
                ]);

                if ($restock) {
                    $product = Product::query()->find($saleItem->product_id);
                    if ($product) {
                        $this->stock->increase($product, $qty, Refund::class, $refund->id, $user->id, 'Retur '.$sale->invoice_number);
                    }
                }

                $refundedQty[$saleItem->id] = $already + $qty;
                $total += $amount;
            }

            if ($total <= 0) {
                throw ValidationException::withMessages(['items' => 'Pilih minimal satu item untuk diretur.']);
            }

            $refund->update(['total' => round($total, 2)]);

            $allRefunded = $sale->items->every(
                fn ($item): bool => ($refundedQty[$item->id] ?? (float) $item->refundItems()->sum('qty')) >= (float) $item->qty,
            );

            $sale->update([
                'status' => $allRefunded ? SaleStatus::Refunded->value : SaleStatus::PartialRefund->value,
            ]);

            activity()
                ->causedBy($user)
                ->performedOn($sale)
                ->withProperties(['refund_number' => $refund->refund_number, 'total' => $total])
                ->log('Retur transaksi dibuat');

            return $refund->load('items.saleItem');
        });
    }

    private function openShift(User $user): Shift
    {
        $shift = Shift::query()
            ->where('user_id', $user->id)
            ->where('status', ShiftStatus::Open->value)
            ->lockForUpdate()
            ->first();

        if (! $shift) {
            throw ValidationException::withMessages(['shift' => 'Buka shift terlebih dahulu.']);
        }

        return $shift;
    }
}
