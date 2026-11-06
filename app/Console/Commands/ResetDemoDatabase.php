<?php

declare(strict_types=1);

namespace App\Console\Commands;

use Illuminate\Console\Command;
use Illuminate\Support\Facades\Cache;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

class ResetDemoDatabase extends Command
{
    protected $signature = 'demo:reset
                            {--force : Jalankan walaupun DEMO_AUTO_RESET=false}';

    protected $description = 'Reset data demo dan isi ulang dengan data seed';

    /**
     * Tabel framework yang tidak boleh dikosongkan.
     *
     * @var array<int, string>
     */
    private const PRESERVED_TABLES = [
        'migrations',
        'users',
        'settings',
        'sessions',
        'cache',
        'cache_locks',
        'jobs',
        'job_batches',
        'failed_jobs',
    ];

    public function handle(): int
    {
        if (! $this->option('force') && ! config('demo.auto_reset')) {
            $this->warn('Demo auto-reset sedang nonaktif. Gunakan --force untuk menjalankan manual.');

            return self::SUCCESS;
        }

        $this->info('Memastikan struktur database terbaru...');

        $this->call('migrate', [
            '--force' => true,
        ]);

        $this->info('Mengosongkan data demo...');

        $this->truncateBusinessTables();

        $this->info('Mengisi ulang data demo...');

        $this->call('db:seed', [
            '--force' => true,
        ]);

        Cache::forever(
            config('demo.cache_key'),
            now(config('demo.timezone'))->toDateString(),
        );

        $this->info('Data demo berhasil direset dan di-seed ulang.');

        return self::SUCCESS;
    }

    private function truncateBusinessTables(): void
    {
        $connection = DB::connection();

        $schema = $connection->getDriverName() === 'sqlite'
            ? null
            : $connection->getDatabaseName();

        $tables = collect(Schema::getTableListing($schema, false))
            ->reject(fn (string $table): bool => in_array($table, self::PRESERVED_TABLES, true))
            ->values()
            ->all();

        Schema::disableForeignKeyConstraints();

        try {
            foreach ($tables as $table) {
                DB::table($table)->truncate();
            }
        } finally {
            Schema::enableForeignKeyConstraints();
        }
    }
}
