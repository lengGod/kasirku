<?php

namespace Tests\Feature;

use App\Models\Batch;
use App\Models\Location;
use App\Models\Product;
use App\Models\User;
use Database\Seeders\DatabaseSeeder;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class ScanLabelTest extends TestCase
{
    use RefreshDatabase;

    private User $user;

    protected function setUp(): void
    {
        parent::setUp();

        $this->seed(DatabaseSeeder::class);
        $this->user = User::where('email', 'admin@gudangku.test')->firstOrFail();
    }

    public function test_scan_label_page_renders(): void
    {
        $this->actingAs($this->user)
            ->get(route('scan-label.index'))
            ->assertOk()
            ->assertSee('ScanLabels', false);
    }

    public function test_lookup_resolves_product_batch_and_location(): void
    {
        $product = Product::whereNotNull('barcode')->firstOrFail();
        $batch = Batch::firstOrFail();
        $location = Location::whereNotNull('barcode')->firstOrFail();

        $this->actingAs($this->user)
            ->getJson(route('scan-label.lookup', ['code' => $product->barcode]))
            ->assertOk()
            ->assertJsonPath('type', 'product')
            ->assertJsonPath('product.id', $product->id);

        $this->actingAs($this->user)
            ->getJson(route('scan-label.lookup', ['code' => $batch->batch_number]))
            ->assertOk()
            ->assertJsonPath('type', 'batch')
            ->assertJsonPath('batch.batch_number', $batch->batch_number);

        $this->actingAs($this->user)
            ->getJson(route('scan-label.lookup', ['code' => $location->barcode]))
            ->assertOk()
            ->assertJsonPath('type', 'location')
            ->assertJsonPath('location.id', $location->id);
    }

    public function test_lookup_returns_not_found_for_unknown_code(): void
    {
        $this->actingAs($this->user)
            ->getJson(route('scan-label.lookup', ['code' => 'TIDAK-ADA-123']))
            ->assertNotFound();
    }

    public function test_printing_a_label_creates_a_log(): void
    {
        $product = Product::firstOrFail();

        $this->actingAs($this->user)
            ->postJson(route('scan-label.print'), [
                'label_type' => 'product',
                'reference_id' => $product->id,
                'copies' => 3,
            ])
            ->assertOk()
            ->assertJsonPath('log.copies', 3)
            ->assertJsonPath('log.printed_by', $this->user->name);

        $this->assertDatabaseHas('label_print_logs', [
            'label_type' => 'product',
            'reference_id' => $product->id,
            'copies' => 3,
            'printed_by' => $this->user->id,
        ]);
    }

    public function test_printing_rejects_invalid_copies(): void
    {
        $product = Product::firstOrFail();

        $this->actingAs($this->user)
            ->postJson(route('scan-label.print'), [
                'label_type' => 'product',
                'reference_id' => $product->id,
                'copies' => 0,
            ])
            ->assertUnprocessable()
            ->assertJsonValidationErrors('copies');
    }

    public function test_barcode_endpoint_returns_svg(): void
    {
        $this->actingAs($this->user)
            ->get(route('scan-label.barcode', ['code' => 'OBAT001']))
            ->assertOk()
            ->assertHeader('Content-Type', 'image/svg+xml; charset=UTF-8');
    }
}
