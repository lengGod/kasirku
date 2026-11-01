<?php

namespace Tests\Feature;

use App\Models\User;
use Database\Seeders\DatabaseSeeder;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class ReportsTest extends TestCase
{
    use RefreshDatabase;

    protected function setUp(): void
    {
        parent::setUp();

        $this->seed(DatabaseSeeder::class);
    }

    public function test_inventory_report_pages_render(): void
    {
        $user = User::where('email', 'admin@gudangku.test')->firstOrFail();

        $routes = [
            'reports.index',
            'reports.stock',
            'reports.low-stock',
            'reports.expiry',
            'reports.movements',
            'batches.index',
        ];

        foreach ($routes as $route) {
            $this->actingAs($user)
                ->get(route($route))
                ->assertOk();
        }
    }

    public function test_report_pages_support_filters(): void
    {
        $user = User::where('email', 'admin@gudangku.test')->firstOrFail();

        $this->actingAs($user)
            ->get(route('reports.expiry', ['status' => 'near_expiry', 'search' => 'a']))
            ->assertOk();

        $this->actingAs($user)
            ->get(route('reports.movements', ['type' => 'in', 'date_from' => now()->subMonth()->toDateString()]))
            ->assertOk();

        $this->actingAs($user)
            ->get(route('batches.index', ['status' => 'depleted']))
            ->assertOk();
    }
}
