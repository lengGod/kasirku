<?php

declare(strict_types=1);

namespace Database\Seeders;

use App\Enums\Role;
use App\Models\User;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;

class UserSeeder extends Seeder
{
    public function run(): void
    {
        $users = [
            [
                'name' => 'Owner KasirKu',
                'email' => 'owner@kasirku.test',
                'password' => bcrypt('password'),
                'role' => Role::Owner->value,
                'pin_hash' => Hash::make('1234'),
                'is_active' => true,
            ],
            [
                'name' => 'Kasir Utama',
                'email' => 'kasir@kasirku.test',
                'password' => bcrypt('password'),
                'role' => Role::Cashier->value,
                'pin_hash' => null,
                'is_active' => true,
            ],
            [
                'name' => 'Manajer Toko',
                'email' => 'manager@kasirku.test',
                'password' => bcrypt('password'),
                'role' => Role::Manager->value,
                'pin_hash' => Hash::make('1234'),
                'is_active' => true,
            ],
        ];

        foreach ($users as $user) {
            User::query()->updateOrCreate(['email' => $user['email']], $user);
        }
    }
}
