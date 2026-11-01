<?php

declare(strict_types=1);

namespace Database\Seeders\Concerns;

use Carbon\Carbon;

/**
 * Menghasilkan nomor dokumen transaksi (IN/OUT/ADJ) per bulan sesuai
 * tanggal transaksi pada rencana seed. Urutan dihitung dari daftar
 * rencana itu sendiri sehingga idempotent: angka stabil meski seeder
 * dijalankan ulang tanpa reset database.
 */
trait GeneratesDocNumbers
{
    /**
     * @param  string  $prefix  IN | OUT | ADJ
     * @param  array<int, array<string, mixed>>  $plans  tiap rencana punya key 'days_ago'
     * @return array<int, string>
     */
    protected function planDocNumbers(string $prefix, array $plans): array
    {
        $numbers = [];
        $counts = [];

        foreach ($plans as $index => $plan) {
            $ym = Carbon::today()->subDays((int) $plan['days_ago'])->format('Ym');
            $counts[$ym] = ($counts[$ym] ?? 0) + 1;

            $numbers[$index] = sprintf('%s-%s-%04d', $prefix, $ym, $counts[$ym]);
        }

        return $numbers;
    }
}
