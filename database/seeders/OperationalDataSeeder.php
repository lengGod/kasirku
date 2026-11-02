<?php

declare(strict_types=1);

namespace Database\Seeders;

use App\Models\CashMovement;
use App\Models\Category;
use App\Models\Customer;
use App\Models\HeldSale;
use App\Models\PaymentMethod;
use App\Models\Product;
use App\Models\Promotion;
use App\Models\ReceiptPrintLog;
use App\Models\Refund;
use App\Models\Sale;
use App\Models\Shift;
use App\Models\Stock;
use App\Models\StockAdjustment;
use App\Models\StockIn;
use App\Models\StockMovement;
use App\Models\Unit;
use App\Models\User;
use App\Services\PricingService;
use App\Services\ShiftService;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;

class OperationalDataSeeder extends Seeder
{
    public function run(): void
    {
        DB::transaction(function (): void {
            $products = $this->seedCatalog();
            $cashier = User::query()->where('email', 'kasir@kasirku.test')->firstOrFail();
            $manager = User::query()->where('email', 'manager@kasirku.test')->firstOrFail();

            $this->seedPromotions($products);
            $this->seedStockReceipts($products, $manager);
            $shifts = $this->seedShifts($cashier);
            $sales = $this->seedSales($products, $shifts, $cashier);
            $this->seedCashMovements($shifts, $manager);
            $this->seedRefund($sales, $cashier);
            $this->seedAdjustment($products, $manager);
            $this->seedHeldSales($products, $cashier);
            $this->updateShiftBalances($shifts);
        });
    }

    /** @return array<int, Product> */
    private function seedCatalog(): array
    {
        $categories = Category::query()->pluck('id', 'name');
        $units = Unit::query()->pluck('id', 'short_name');
        $catalog = [
            ['SBK-004', '8999901000004', 'Tepung Terigu Protein Sedang 1 kg', 'Sembako', 'kg', 11000, 14000, 80, false], ['SBK-005', '8999901000005', 'Telur Ayam Ras 1 kg', 'Sembako', 'kg', 27000, 31000, 45, false], ['SBK-006', '8999901000006', 'Garam Beryodium 500 g', 'Sembako', 'pcs', 2500, 4000, 90, false], ['SBK-007', '8999901000007', 'Kecap Manis 600 ml', 'Sembako', 'btl', 13500, 17000, 48, false], ['SBK-008', '8999901000008', 'Saus Sambal 340 ml', 'Sembako', 'btl', 9000, 12000, 42, false], ['SBK-009', '8999901000009', 'Sarden Saus Tomat 155 g', 'Sembako', 'pcs', 9500, 12500, 55, false],
            ['MKN-004', '8999901000010', 'Keripik Singkong Balado 68 g', 'Makanan', 'pcs', 5500, 8000, 70, true], ['MKN-005', '8999901000011', 'Wafer Cokelat 65 g', 'Makanan', 'pcs', 3500, 5500, 90, true], ['MKN-006', '8999901000012', 'Biskuit Kelapa 300 g', 'Makanan', 'pack', 8500, 12000, 58, true], ['MKN-007', '8999901000013', 'Kacang Panggang 100 g', 'Makanan', 'pcs', 6000, 9000, 50, true], ['MKN-008', '8999901000014', 'Roti Isi Cokelat', 'Makanan', 'pcs', 4500, 7000, 36, true], ['MKN-009', '8999901000015', 'Bubur Instan Ayam 45 g', 'Makanan', 'pcs', 7000, 10000, 44, false],
            ['MNM-004', '8999901000016', 'Minuman Teh Melati 500 ml', 'Minuman', 'btl', 3500, 6000, 84, false], ['MNM-005', '8999901000017', 'Minuman Isotonik Lemon 500 ml', 'Minuman', 'btl', 5500, 8500, 72, false], ['MNM-006', '8999901000018', 'Susu UHT Cokelat 200 ml', 'Minuman', 'pcs', 4500, 7000, 65, false], ['MNM-007', '8999901000019', 'Jus Jambu 250 ml', 'Minuman', 'pcs', 3500, 5500, 62, false], ['MNM-008', '8999901000020', 'Kopi Susu Siap Minum 200 ml', 'Minuman', 'pcs', 6500, 10000, 45, false], ['MNM-009', '8999901000021', 'Soda Rasa Jeruk 390 ml', 'Minuman', 'btl', 4500, 7000, 52, false],
            ['PRW-003', '8999901000022', 'Sampo Sachet 12 ml', 'Perawatan Diri', 'pcs', 800, 1500, 150, true], ['PRW-004', '8999901000023', 'Deterjen Bubuk 800 g', 'Perawatan Diri', 'pack', 11500, 15500, 40, true], ['PRW-005', '8999901000024', 'Pewangi Pakaian 800 ml', 'Perawatan Diri', 'btl', 9000, 13000, 42, true], ['PRW-006', '8999901000025', 'Tisu Wajah 250 Lembar', 'Perawatan Diri', 'pack', 7500, 11000, 44, true], ['PRW-007', '8999901000026', 'Sikat Gigi Dewasa', 'Perawatan Diri', 'pcs', 4500, 7500, 52, true], ['PRW-008', '8999901000027', 'Sabun Cuci Piring 755 ml', 'Perawatan Diri', 'btl', 11500, 15500, 36, true],
        ];

        foreach ($catalog as [$sku, $barcode, $name, $category, $unit, $cost, $sell, $stock, $taxable]) {
            $product = Product::query()->updateOrCreate(['sku' => $sku], ['barcode' => $barcode, 'name' => $name, 'category_id' => $categories[$category], 'unit_id' => $units[$unit], 'cost_price' => $cost, 'sell_price' => $sell, 'is_taxable' => $taxable, 'min_stock' => max(8, (int) floor($stock * .2)), 'track_stock' => true, 'track_batch' => false, 'track_expiry' => false, 'is_active' => true]);
            Stock::query()->firstOrCreate(['product_id' => $product->id, 'batch_key' => 0], ['quantity' => $stock]);
        }

        return Product::query()->with('unit')->where('is_active', true)->orderBy('id')->get()->all();
    }

    /** @param array<int, Product> $products */
    private function seedPromotions(array $products): void
    {
        $bySku = collect($products)->keyBy('sku');
        $categories = Category::query()->pluck('id', 'name');
        $promotions = [
            ['Hemat Minuman Akhir Pekan', 'percentage', 10, 'category', null, $categories['Minuman'], now()->startOfWeek(), now()->endOfWeek(), true],
            ['Harga Spesial Mie Instan', 'nominal', 500, 'product', $bySku['MKN-003']->id, null, now()->subDays(5), now()->addDays(10), true],
            ['Promo Sabun Mandi Bulanan', 'percentage', 15, 'product', $bySku['PRW-001']->id, null, now()->startOfMonth(), now()->endOfMonth(), true],
            ['Promo Ramadan Sembako', 'percentage', 8, 'category', null, $categories['Sembako'], now()->subMonths(7), now()->subMonths(6), false],
        ];
        foreach ($promotions as [$name, $type, $value, $target, $targetId, $categoryId, $startAt, $endAt, $isActive]) {
            Promotion::query()->updateOrCreate(['name' => $name], ['type' => $type, 'value' => $value, 'target' => $target, 'target_id' => $targetId, 'category_id' => $categoryId, 'start_at' => $startAt, 'end_at' => $endAt, 'is_active' => $isActive]);
        }
    }

    /** @param array<int, Product> $products */
    private function seedStockReceipts(array $products, User $manager): void
    {
        $suppliers = ['PT Sumber Pangan Nusantara', 'CV Segar Makmur', 'PT Mitra Kebutuhan Harian', 'UD Berkah Jaya'];
        for ($index = 0; $index < 8; $index++) {
            $receivedAt = now()->subDays(22 - ($index * 2))->setTime(9, 30);
            $number = 'IN-'.$receivedAt->format('Ym').'-'.str_pad((string) ($index + 1), 4, '0', STR_PAD_LEFT);
            $document = StockIn::query()->firstOrCreate(['document_number' => $number], ['supplier_name' => $suppliers[$index % 4], 'received_at' => $receivedAt, 'note' => 'Penerimaan barang rutin untuk kebutuhan toko.', 'created_by' => $manager->id, 'created_at' => $receivedAt, 'updated_at' => $receivedAt]);
            if (! $document->wasRecentlyCreated) {
                continue;
            }
            for ($line = 0; $line < 5; $line++) {
                $product = $products[($index * 5 + $line * 3) % count($products)];
                $qty = 12 + (($index + $line) % 4) * 6;
                $document->items()->create(['product_id' => $product->id, 'qty' => $qty, 'cost_price' => $product->cost_price]);
                $stock = Stock::query()->firstOrCreate(['product_id' => $product->id, 'batch_key' => 0], ['quantity' => 0]);
                $balance = (float) $stock->quantity + $qty;
                $stock->update(['quantity' => $balance]);
                StockMovement::query()->create(['product_id' => $product->id, 'created_by' => $manager->id, 'type' => 'in', 'qty' => $qty, 'balance_after' => $balance, 'reference_type' => StockIn::class, 'reference_id' => $document->id, 'note' => $number, 'created_at' => $receivedAt]);
            }
        }
    }

    /** @return array<string, Shift> */
    private function seedShifts(User $cashier): array
    {
        $shifts = [];
        for ($daysAgo = 20; $daysAgo >= 0; $daysAgo--) {
            $openedAt = now()->subDays($daysAgo)->setTime(7, 45);
            $shifts[(string) $daysAgo] = Shift::query()->firstOrCreate(['user_id' => $cashier->id, 'opened_at' => $openedAt], ['opening_cash' => 300000, 'status' => $daysAgo === 0 ? 'open' : 'closed', 'closed_at' => $daysAgo === 0 ? null : $openedAt->copy()->setTime(21, 10), 'expected_cash' => 300000, 'actual_cash' => $daysAgo === 0 ? null : 300000, 'difference' => 0, 'created_at' => $openedAt, 'updated_at' => $openedAt]);
        }

        return $shifts;
    }

    /**
     * @param  array<int, Product>  $products
     * @param  array<string, Shift>  $shifts
     * @return array<int, Sale>
     */
    private function seedSales(array $products, array $shifts, User $cashier): array
    {
        $pricing = app(PricingService::class);
        $customers = Customer::query()->orderBy('id')->get()->all();
        $methods = PaymentMethod::query()->pluck('id', 'type')->all();
        $sales = [];
        for ($daysAgo = 20; $daysAgo >= 0; $daysAgo--) {
            for ($sequence = 1; $sequence <= 3; $sequence++) {
                $createdAt = now()->subDays($daysAgo)->setTime(9 + ($sequence * 3), 10 + ($sequence * 7));
                $invoice = sprintf('INV-%s-%04d', $createdAt->format('Ymd'), $sequence);
                $lines = [];
                for ($line = 0; $line < 2 + (($daysAgo + $sequence) % 3); $line++) {
                    $product = $products[($daysAgo * 7 + $sequence * 5 + $line * 11) % count($products)];
                    $lines[] = ['product_id' => $product->id, 'name' => $product->name, 'qty' => 1 + (($daysAgo + $line) % 2), 'unit_price' => (float) $product->sell_price, 'cost_price' => (float) $product->cost_price, 'discount' => $line === 0 && $sequence === 2 ? 500 : 0, 'is_taxable' => $product->is_taxable];
                }
                $calculation = $pricing->calculate($lines, $sequence === 3 ? 1000 : 0, false, .11, 100);
                $methodType = ['cash', 'qris', 'transfer'][$sequence - 1];
                $sale = Sale::query()->firstOrCreate(['invoice_number' => $invoice], ['idempotency_key' => 'seed-'.$invoice, 'shift_id' => $shifts[(string) $daysAgo]->id, 'cashier_id' => $cashier->id, 'customer_id' => $customers[($daysAgo + $sequence) % count($customers)]->id, 'subtotal' => $calculation['subtotal'], 'discount_total' => $calculation['discount_total'], 'tax_total' => $calculation['tax_total'], 'rounding' => $calculation['rounding'], 'grand_total' => $calculation['grand_total'], 'paid_total' => $calculation['grand_total'], 'change_amount' => 0, 'status' => 'paid', 'created_at' => $createdAt, 'updated_at' => $createdAt]);
                $sales[] = $sale;
                if (! $sale->wasRecentlyCreated) {
                    continue;
                }
                foreach ($calculation['lines'] as $line) {
                    $sale->items()->create(['product_id' => $line['product_id'], 'name_snapshot' => $line['name'], 'qty' => $line['qty'], 'unit_price' => $line['unit_price'], 'cost_price' => $line['cost_price'], 'discount' => $line['discount'], 'tax' => $line['tax'], 'line_total' => $line['line_total']]);
                    $product = Product::query()->findOrFail($line['product_id']);
                    if ($product->track_stock) {
                        $stock = Stock::query()->firstOrCreate(['product_id' => $product->id, 'batch_key' => 0], ['quantity' => 0]);
                        $balance = (float) $stock->quantity - (float) $line['qty'];
                        $stock->update(['quantity' => $balance]);
                        StockMovement::query()->create(['product_id' => $product->id, 'created_by' => $cashier->id, 'type' => 'sale', 'qty' => -(float) $line['qty'], 'balance_after' => $balance, 'reference_type' => Sale::class, 'reference_id' => $sale->id, 'note' => $invoice, 'created_at' => $createdAt]);
                    }
                }
                $sale->payments()->create(['payment_method_id' => $methods[$methodType], 'amount' => $calculation['grand_total'], 'reference' => $methodType === 'cash' ? null : strtoupper($methodType).'-'.$createdAt->format('ymdHis')]);
                if ($sequence !== 2) {
                    ReceiptPrintLog::query()->create(['sale_id' => $sale->id, 'printed_by' => $cashier->id, 'is_copy' => $sequence === 3, 'created_at' => $createdAt, 'updated_at' => $createdAt]);
                }
            }
        }

        return $sales;
    }

    /** @param array<string, Shift> $shifts */
    private function seedCashMovements(array $shifts, User $manager): void
    {
        foreach ([4 => ['out', 75000, 'Belanja kebutuhan operasional toko'], 9 => ['in', 50000, 'Tambahan uang kecil dari kas toko'], 15 => ['out', 35000, 'Pembelian kantong belanja dan tisu']] as $daysAgo => [$type, $amount, $reason]) {
            $createdAt = now()->subDays($daysAgo)->setTime(15, 30);
            CashMovement::query()->firstOrCreate(['shift_id' => $shifts[(string) $daysAgo]->id, 'reason' => $reason], ['type' => $type, 'amount' => $amount, 'created_by' => $manager->id, 'created_at' => $createdAt, 'updated_at' => $createdAt]);
        }
    }

    /** @param array<int, Sale> $sales */
    private function seedRefund(array $sales, User $cashier): void
    {
        $sale = collect($sales)->first(fn (Sale $sale): bool => $sale->created_at->isToday() && $sale->payments()->whereHas('paymentMethod', fn ($query) => $query->where('type', 'cash'))->exists());
        $item = $sale?->items()->first();
        if (! $sale || ! $item) {
            return;
        }
        $refund = Refund::query()->firstOrCreate(['refund_number' => 'RTN-'.now()->format('Ymd').'-0001'], ['sale_id' => $sale->id, 'shift_id' => $sale->shift_id, 'total' => $item->line_total, 'reason' => 'Kemasan produk rusak saat diterima pelanggan', 'approved_by' => $cashier->id, 'created_by' => $cashier->id]);
        if (! $refund->wasRecentlyCreated) {
            return;
        }
        $refund->items()->create(['sale_item_id' => $item->id, 'qty' => $item->qty, 'amount' => $item->line_total, 'restock' => true]);
        $product = $item->product;
        if ($product?->track_stock) {
            $stock = Stock::query()->where('product_id', $product->id)->where('batch_key', 0)->firstOrFail();
            $balance = (float) $stock->quantity + (float) $item->qty;
            $stock->update(['quantity' => $balance]);
            StockMovement::query()->create(['product_id' => $product->id, 'created_by' => $cashier->id, 'type' => 'refund', 'qty' => $item->qty, 'balance_after' => $balance, 'reference_type' => Refund::class, 'reference_id' => $refund->id, 'note' => 'Retur '.$sale->invoice_number, 'created_at' => now()->setTime(18, 15)]);
        }
        $sale->update(['status' => 'partial_refund']);
    }

    /** @param array<int, Product> $products */
    private function seedAdjustment(array $products, User $manager): void
    {
        $createdAt = now()->subDays(2)->setTime(20, 15);
        $number = 'ADJ-'.$createdAt->format('Ymd').'-0001';
        $document = StockAdjustment::query()->firstOrCreate(['document_number' => $number], ['reason' => 'Penyesuaian stok hasil stok opname mingguan', 'created_by' => $manager->id, 'created_at' => $createdAt, 'updated_at' => $createdAt]);
        if (! $document->wasRecentlyCreated) {
            return;
        }
        foreach ([$products[3], $products[13], $products[23]] as $product) {
            $stock = Stock::query()->where('product_id', $product->id)->where('batch_key', 0)->firstOrFail();
            $before = (float) $stock->quantity;
            $after = max(0, $before - 1);
            $document->items()->create(['product_id' => $product->id, 'qty_before' => $before, 'qty_after' => $after, 'difference' => $after - $before]);
            $stock->update(['quantity' => $after]);
            StockMovement::query()->create(['product_id' => $product->id, 'created_by' => $manager->id, 'type' => 'adjust', 'qty' => $after - $before, 'balance_after' => $after, 'reference_type' => StockAdjustment::class, 'reference_id' => $document->id, 'note' => $number, 'created_at' => $createdAt]);
        }
    }

    /** @param array<int, Product> $products */
    private function seedHeldSales(array $products, User $cashier): void
    {
        foreach ([['Pesanan Bu Rina', 1, 2], ['Belanja kantor RT', 8, 3]] as [$label, $first, $second]) {
            HeldSale::query()->firstOrCreate(['cashier_id' => $cashier->id, 'label' => $label], ['cart_json' => ['items' => [$this->cartItem($products[$first]), $this->cartItem($products[$second], 2)], 'customer_id' => null, 'discount_total' => 0]]);
        }
    }

    /** @return array<string, mixed> */
    private function cartItem(Product $product, int $qty = 1): array
    {
        return ['product_id' => $product->id, 'name' => $product->name, 'price' => (float) $product->sell_price, 'qty' => $qty, 'discount' => 0, 'is_taxable' => $product->is_taxable, 'track_stock' => $product->track_stock, 'stock' => $product->currentStock(), 'unit' => $product->unit?->short_name];
    }

    /** @param array<string, Shift> $shifts */
    private function updateShiftBalances(array $shifts): void
    {
        $service = app(ShiftService::class);
        foreach ($shifts as $daysAgo => $shift) {
            if ($daysAgo === '0') {
                continue;
            }
            $expected = $service->expectedCash($shift);
            $difference = (int) $daysAgo % 3 === 0 ? -500 : 0;
            $shift->update(['expected_cash' => $expected, 'actual_cash' => $expected + $difference, 'difference' => $difference]);
        }
    }
}
