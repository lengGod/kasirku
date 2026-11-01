<?php

namespace Tests\Feature;

use App\Models\StockIn;
use App\Models\User;
use Database\Seeders\DatabaseSeeder;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class RoleAccessTest extends TestCase
{
    use RefreshDatabase;

    protected function setUp(): void
    {
        parent::setUp();

        $this->seed(DatabaseSeeder::class);
    }

    private function user(string $email): User
    {
        return User::where('email', $email)->firstOrFail();
    }

    public function test_admin_has_full_access(): void
    {
        $admin = $this->user('admin@gudangku.test');

        $paths = [
            'dashboard',
            'categories.index',
            'products.index',
            'products.create',
            'stock-ins.index',
            'stock-ins.create',
            'stock-outs.index',
            'stock-outs.create',
            'stock-adjustments.index',
            'stock-adjustments.create',
            'scan-label.index',
            'batches.index',
            'reports.index',
        ];

        foreach ($paths as $path) {
            $response = $this->actingAs($admin)->get(route($path));
            $response->assertOk();
        }
    }

    public function test_staff_can_operate_inventory_but_cannot_manage_master_data(): void
    {
        $staff = $this->user('staff@gudangku.test');

        $allowed = [
            'dashboard',
            'categories.index',
            'products.index',
            'stock-ins.index',
            'stock-ins.create',
            'stock-outs.index',
            'stock-outs.create',
            'stock-adjustments.index',
            'stock-adjustments.create',
            'scan-label.index',
            'batches.index',
            'reports.index',
        ];

        foreach ($allowed as $path) {
            $this->actingAs($staff)->get(route($path))->assertOk();
        }

        $denied = [
            'products.create',
        ];

        foreach ($denied as $path) {
            $this->actingAs($staff)->get(route($path))->assertForbidden();
        }

        $this->actingAs($staff)
            ->post(route('categories.store'), ['name' => 'Kategori Baru'])
            ->assertForbidden();
    }

    public function test_viewer_is_read_only(): void
    {
        $viewer = $this->user('viewer@gudangku.test');

        $allowed = [
            'dashboard',
            'categories.index',
            'products.index',
            'stock-ins.index',
            'stock-outs.index',
            'stock-adjustments.index',
            'batches.index',
            'reports.index',
        ];

        foreach ($allowed as $path) {
            $this->actingAs($viewer)->get(route($path))->assertOk();
        }

        $deniedPages = [
            'products.create',
            'stock-ins.create',
            'stock-outs.create',
            'stock-adjustments.create',
            'scan-label.index',
        ];

        foreach ($deniedPages as $path) {
            $this->actingAs($viewer)->get(route($path))->assertForbidden();
        }
    }

    public function test_viewer_cannot_mutate_transactions_or_print_labels(): void
    {
        $viewer = $this->user('viewer@gudangku.test');
        $stockIn = StockIn::firstOrFail();

        $this->actingAs($viewer)
            ->post(route('stock-ins.post', $stockIn))
            ->assertForbidden();

        $this->actingAs($viewer)
            ->postJson(route('scan-label.print'), [
                'label_type' => 'product',
                'reference_id' => 1,
                'copies' => 1,
            ])
            ->assertForbidden();
    }
}
