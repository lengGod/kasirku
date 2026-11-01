<?php

declare(strict_types=1);

namespace Tests\Feature;

use App\Models\StockMovement;
use App\Models\User;
use Database\Seeders\DatabaseSeeder;
use Database\Seeders\DashboardChartSeeder;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Inertia\Testing\AssertableInertia as Assert;
use Tests\TestCase;

class DashboardTest extends TestCase
{
    use RefreshDatabase;

    protected function setUp(): void
    {
        parent::setUp();

        $this->seed(DatabaseSeeder::class);
    }

    public function test_dashboard_renders_with_movement_chart_data(): void
    {
        $admin = User::where('email', 'admin@gudangku.test')->firstOrFail();

        $this->actingAs($admin)
            ->get(route('dashboard'))
            ->assertOk()
            ->assertInertia(fn (Assert $page) => $page
                ->component('Dashboard')
                ->has('movementChart')
                ->has('movementChart.labels', 30)
                ->has('movementChart.in', 30)
                ->has('movementChart.out', 30)
                ->has('expiringBatches')
                ->has('lowStockItems')
                ->has('recentMovements'));
    }

    public function test_expiring_batches_include_expiry_date(): void
    {
        $admin = User::where('email', 'admin@gudangku.test')->firstOrFail();

        $this->actingAs($admin)
            ->get(route('dashboard'))
            ->assertInertia(fn (Assert $page) => $page
                ->component('Dashboard')
                ->has('expiringBatches')
                ->has('expiringBatches.0.expiry_date'));
    }

    public function test_dashboard_chart_seeder_fills_data_when_no_recent_movements(): void
    {
        // Geser semua mutasi agar lebih tua dari 30 hari,
        // sehingga jendela grafik benar-benar kosong.
        StockMovement::query()->update([
            'created_at' => now()->subDays(90),
            'updated_at' => now()->subDays(90),
        ]);

        $this->seed(DashboardChartSeeder::class);

        $recentCount = StockMovement::whereBetween('created_at', [
            now()->subDays(29)->startOfDay(),
            now()->endOfDay(),
        ])->count();

        $this->assertGreaterThan(0, $recentCount);
    }

    public function test_dashboard_chart_seeder_is_idempotent(): void
    {
        $before = StockMovement::count();

        $this->seed(DashboardChartSeeder::class);

        $this->assertSame($before, StockMovement::count());
    }
}
