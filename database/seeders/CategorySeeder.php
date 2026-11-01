<?php

declare(strict_types=1);

namespace Database\Seeders;

use App\Models\Category;
use Illuminate\Database\Seeder;

class CategorySeeder extends Seeder
{
    public function run(): void
    {
        foreach (['Makanan', 'Minuman', 'Sembako', 'Perawatan Diri', 'Jasa'] as $name) {
            Category::query()->firstOrCreate(['name' => $name]);
        }
    }
}
