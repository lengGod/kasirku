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
            ['name' => 'Ibu Rina Wijaya', 'phone' => '081287654321', 'notes' => 'Pelanggan rumah tangga'],
            ['name' => 'Andi Pratama', 'phone' => '085712345678', 'notes' => 'Pelanggan kantor sekitar toko'],
            ['name' => 'Siti Aminah', 'phone' => '081356789012', 'notes' => 'Belanja kebutuhan dapur mingguan'],
            ['name' => 'Dedi Kurniawan', 'phone' => '082112345678', 'notes' => 'Pelanggan tetap'],
            ['name' => 'Maya Lestari', 'phone' => '081912345678', 'notes' => 'Pelanggan tetap'],
            ['name' => 'Koperasi Warga Melati', 'phone' => '0215551732', 'notes' => 'Pembelian untuk kegiatan warga'],
            ['name' => 'Warung Bu Yani', 'phone' => '081377654321', 'notes' => 'Pelanggan usaha kecil'],
        ];

        foreach ($customers as $customer) {
            Customer::query()->firstOrCreate(['name' => $customer['name']], $customer);
        }
    }
}
