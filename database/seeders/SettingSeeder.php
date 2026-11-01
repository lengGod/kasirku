<?php

declare(strict_types=1);

namespace Database\Seeders;

use App\Models\Setting;
use Illuminate\Database\Seeder;

class SettingSeeder extends Seeder
{
    public function run(): void
    {
        $settings = [
            'store_name' => 'KasirKu',
            'store_address' => 'Jl. Merdeka No. 17, Jakarta',
            'store_phone' => '021-555-0100',
            'receipt_footer' => 'Terima kasih telah berbelanja. Barang yang sudah dibeli tidak dapat ditukar tanpa struk.',
            'tax_rate' => '11',
            'tax_included' => '0',
            'rounding_step' => '100',
            'max_discount_without_pin' => '10000',
            'allow_negative_stock' => '0',
        ];

        foreach ($settings as $key => $value) {
            Setting::put($key, $value);
        }
    }
}
