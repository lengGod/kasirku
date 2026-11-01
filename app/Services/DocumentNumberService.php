<?php

declare(strict_types=1);

namespace App\Services;

use Illuminate\Support\Facades\DB;

class DocumentNumberService
{
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

        $next = ((int) ($row->value ?? 0)) + 1;

        DB::table('document_sequences')
            ->where('key', $key)
            ->update(['value' => $next, 'updated_at' => now()]);

        return sprintf('%s-%s-%s', $prefix, $period, str_pad((string) $next, $padding, '0', STR_PAD_LEFT));
    }
}
