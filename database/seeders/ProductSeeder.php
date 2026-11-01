<?php

declare(strict_types=1);

namespace Database\Seeders;

use App\Models\Category;
use App\Models\Product;
use App\Models\Stock;
use App\Models\Unit;
use Illuminate\Database\Seeder;

class ProductSeeder extends Seeder
{
    public function run(): void
    {
        $categories = Category::query()->pluck('id', 'name');
        $units = Unit::query()->pluck('id', 'short_name');

        $products = [
            ['sku' => 'MKN-001', 'barcode' => '8991001000011', 'name' => 'Roti Tawar Gandum', 'category' => 'Makanan', 'unit' => 'pcs', 'cost' => 12000, 'sell' => 17000, 'stock' => 25, 'tax' => true],
            ['sku' => 'MKN-002', 'barcode' => '8991001000028', 'name' => 'Biskuit Cokelat', 'category' => 'Makanan', 'unit' => 'pack', 'cost' => 8000, 'sell' => 12000, 'stock' => 40, 'tax' => true],
            ['sku' => 'MKN-003', 'barcode' => '8991001000035', 'name' => 'Mie Instan Goreng', 'category' => 'Makanan', 'unit' => 'pcs', 'cost' => 2800, 'sell' => 3500, 'stock' => 120, 'tax' => false],
            ['sku' => 'MNM-001', 'barcode' => '8992002000010', 'name' => 'Air Mineral 600ml', 'category' => 'Minuman', 'unit' => 'btl', 'cost' => 2500, 'sell' => 4000, 'stock' => 80, 'tax' => false],
            ['sku' => 'MNM-002', 'barcode' => '8992002000027', 'name' => 'Teh Kotak 250ml', 'category' => 'Minuman', 'unit' => 'pcs', 'cost' => 3500, 'sell' => 5000, 'stock' => 60, 'tax' => false],
            ['sku' => 'MNM-003', 'barcode' => '8992002000034', 'name' => 'Kopi Sachet', 'category' => 'Minuman', 'unit' => 'pcs', 'cost' => 1500, 'sell' => 2500, 'stock' => 150, 'tax' => false],
            ['sku' => 'SBK-001', 'barcode' => '8993003000019', 'name' => 'Beras Premium 5kg', 'category' => 'Sembako', 'unit' => 'kg', 'cost' => 65000, 'sell' => 75000, 'stock' => 20, 'tax' => false],
            ['sku' => 'SBK-002', 'barcode' => '8993003000026', 'name' => 'Minyak Goreng 1L', 'category' => 'Sembako', 'unit' => 'ltr', 'cost' => 15000, 'sell' => 19000, 'stock' => 35, 'tax' => false],
            ['sku' => 'SBK-003', 'barcode' => '8993003000033', 'name' => 'Gula Pasir 1kg', 'category' => 'Sembako', 'unit' => 'kg', 'cost' => 14000, 'sell' => 17000, 'stock' => 30, 'tax' => false],
            ['sku' => 'PRW-001', 'barcode' => '8994004000018', 'name' => 'Sabun Mandi', 'category' => 'Perawatan Diri', 'unit' => 'pcs', 'cost' => 4000, 'sell' => 6500, 'stock' => 45, 'tax' => true],
            ['sku' => 'PRW-002', 'barcode' => '8994004000025', 'name' => 'Pasta Gigi', 'category' => 'Perawatan Diri', 'unit' => 'pcs', 'cost' => 9000, 'sell' => 13500, 'stock' => 28, 'tax' => true],
            ['sku' => 'JSA-001', 'barcode' => null, 'name' => 'Jasa Cetak Dokumen', 'category' => 'Jasa', 'unit' => 'pcs', 'cost' => 500, 'sell' => 3000, 'stock' => 0, 'tax' => false, 'track_stock' => false],
        ];

        foreach ($products as $row) {
            $product = Product::query()->updateOrCreate(
                ['sku' => $row['sku']],
                [
                    'barcode' => $row['barcode'],
                    'name' => $row['name'],
                    'category_id' => $categories[$row['category']],
                    'unit_id' => $units[$row['unit']],
                    'cost_price' => $row['cost'],
                    'sell_price' => $row['sell'],
                    'is_taxable' => $row['tax'],
                    'min_stock' => 10,
                    'track_stock' => $row['track_stock'] ?? true,
                    'track_batch' => false,
                    'track_expiry' => false,
                    'is_active' => true,
                ],
            );

            if ($product->track_stock) {
                Stock::query()->updateOrCreate(
                    ['product_id' => $product->id, 'batch_key' => 0],
                    ['quantity' => $row['stock']],
                );
            }
        }
    }
}
