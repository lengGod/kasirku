<?php

declare(strict_types=1);

namespace Database\Seeders;

use App\Models\Customer;
use Illuminate\Database\Seeder;

class CustomerSeeder extends Seeder
{
    public function run(): void
    {
        $customers = [
            ['name' => 'Umum', 'phone' => null, 'notes' => 'Pelanggan tanpa identitas'],
            ['name' => 'Bu Siti', 'phone' => '081234567890', 'notes' => 'Langganan sembako'],
            ['name' => 'Pak Budi', 'phone' => '081298765432', 'notes' => 'Langganan minuman'],
        ];

        foreach ($customers as $customer) {
            Customer::query()->firstOrCreate(['name' => $customer['name']], $customer);
        }
    }
}
