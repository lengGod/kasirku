<?php

namespace Tests\Feature\Shifts;

use App\Enums\SaleStatus;
use App\Enums\ShiftStatus;
use App\Models\Sale;
use App\Models\Shift;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Inertia\Testing\AssertableInertia as Assert;
use Tests\TestCase;

class ShiftIndexTest extends TestCase
{
    use RefreshDatabase;

    public function test_shift_index_shows_sales_total_without_voided_sales(): void
    {
        $user = User::factory()->owner()->create();

        $shift = Shift::create([
            'user_id' => $user->id,
            'opened_at' => now(),
            'opening_cash' => 100000,
            'status' => ShiftStatus::Open->value,
        ]);

        Sale::create([
            'invoice_number' => 'INV-TEST-001',
            'idempotency_key' => 'test-key-001',
            'shift_id' => $shift->id,
            'cashier_id' => $user->id,
            'grand_total' => 50000,
            'status' => SaleStatus::Paid->value,
        ]);

        Sale::create([
            'invoice_number' => 'INV-TEST-002',
            'idempotency_key' => 'test-key-002',
            'shift_id' => $shift->id,
            'cashier_id' => $user->id,
            'grand_total' => 25000,
            'status' => SaleStatus::Voided->value,
        ]);

        $this->actingAs($user)
            ->get(route('shifts.index'))
            ->assertOk()
            ->assertInertia(fn (Assert $page) => $page
                ->component('Shifts/Index')
                ->where('shifts.data.0.sales_count', 1)
                ->where('shifts.data.0.sales_total', fn ($total) => (float) $total === 50000.0)
            );
    }
}
