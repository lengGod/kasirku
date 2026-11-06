<?php

namespace Tests\Feature\Services;

use App\Enums\SaleStatus;
use App\Enums\ShiftStatus;
use App\Models\Sale;
use App\Models\Shift;
use App\Models\User;
use App\Services\DocumentNumberService;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class DocumentNumberServiceTest extends TestCase
{
    use RefreshDatabase;

    public function test_next_increments_sequence_for_each_call(): void
    {
        $service = app(DocumentNumberService::class);

        $this->assertSame('INV-20261104-0001', $service->next('INV', '20261104'));
        $this->assertSame('INV-20261104-0002', $service->next('INV', '20261104'));

        $this->assertDatabaseHas('document_sequences', [
            'key' => 'inv:20261104',
            'value' => 2,
        ]);
    }

    public function test_next_skips_invoice_numbers_that_already_exist(): void
    {
        $user = User::factory()->owner()->create();

        $shift = Shift::create([
            'user_id' => $user->id,
            'opened_at' => now(),
            'opening_cash' => 0,
            'status' => ShiftStatus::Open->value,
        ]);

        Sale::create([
            'invoice_number' => 'INV-20261104-0001',
            'idempotency_key' => 'existing-key',
            'shift_id' => $shift->id,
            'cashier_id' => $user->id,
            'grand_total' => 10000,
            'status' => SaleStatus::Paid->value,
        ]);

        $number = app(DocumentNumberService::class)->next('INV', '20261104');

        $this->assertSame('INV-20261104-0002', $number);
    }
}
