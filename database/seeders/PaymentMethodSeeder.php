<?php

declare(strict_types=1);

namespace Database\Seeders;

use App\Models\PaymentMethod;
use Illuminate\Database\Seeder;

class PaymentMethodSeeder extends Seeder
{
    public function run(): void
    {
        $methods = [
            ['name' => 'Tunai', 'type' => 'cash'],
            ['name' => 'QRIS', 'type' => 'qris'],
            ['name' => 'Transfer Bank', 'type' => 'transfer'],
            ['name' => 'Kartu Debit/Kredit', 'type' => 'card'],
        ];

        foreach ($methods as $method) {
            PaymentMethod::query()->firstOrCreate(['name' => $method['name']], $method + ['is_active' => true]);
        }
    }
}
