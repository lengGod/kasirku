<?php

declare(strict_types=1);

namespace App\Services;

use Illuminate\Support\Facades\DB;

class DocumentNumberService
{
    /**
     * Tabel dan kolom sumber nomor dokumen untuk tiap prefix.
     *
     * @var array<string, array{table: string, column: string}>
     */
    private const SOURCES = [
        'INV' => ['table' => 'sales', 'column' => 'invoice_number'],
        'RTN' => ['table' => 'refunds', 'column' => 'refund_number'],
        'IN' => ['table' => 'stock_ins', 'column' => 'document_number'],
        'ADJ' => ['table' => 'stock_adjustments', 'column' => 'document_number'],
    ];

    public function next(string $prefix, string $period, int $padding = 4): string
    {
        $key = strtolower($prefix).':'.$period;

        DB::table('document_sequences')->insertOrIgnore([
            'key' => $key,
            'value' => 0,
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        $row = DB::table('document_sequences')
            ->where('key', $key)
            ->lockForUpdate()
            ->first();

        $sequence = (int) ($row->value ?? 0);
        $existing = $this->highestExistingNumber($prefix, $period);

        $next = max($sequence, $existing) + 1;

        DB::table('document_sequences')
            ->where('key', $key)
            ->update(['value' => $next, 'updated_at' => now()]);

        return sprintf('%s-%s-%s', $prefix, $period, str_pad((string) $next, $padding, '0', STR_PAD_LEFT));
    }

    private function highestExistingNumber(string $prefix, string $period): int
    {
        $source = self::SOURCES[strtoupper($prefix)] ?? null;

        if (! $source) {
            return 0;
        }

        return DB::table($source['table'])
            ->where($source['column'], 'like', $prefix.'-'.$period.'-%')
            ->pluck($source['column'])
            ->map(fn (string $number): int => (int) substr($number, strrpos($number, '-') + 1))
            ->max() ?? 0;
    }
}
