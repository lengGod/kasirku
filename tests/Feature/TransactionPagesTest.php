<?php

namespace Tests\Feature;

use App\Models\Product;
use App\Models\Stock;
use App\Models\StockAdjustment;
use App\Models\StockMovement;
use App\Models\StockOut;
use App\Models\User;
use Database\Seeders\DatabaseSeeder;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class TransactionPagesTest extends TestCase
{
    use RefreshDatabase;

    protected function setUp(): void
    {
        parent::setUp();

        $this->seed(DatabaseSeeder::class);
    }

    public function test_seeders_produce_consistent_demo_data(): void
    {
        $this->assertSame(14, Product::count());
        $this->assertSame(56, StockMovement::count());
        $this->assertSame(6, StockOut::where('status', 'posted')->count());
        $this->assertSame(1, StockOut::where('status', 'draft')->count());
        $this->assertSame(3, StockAdjustment::where('status', 'posted')->count());
        $this->assertSame(1, StockAdjustment::where('status', 'draft')->count());

        $lowStock = Product::withSum('stocks as total_qty', 'quantity')
            ->get()
            ->filter(fn (Product $product) => (float) $product->total_qty < (float) $product->min_stock);

        $this->assertSame(4, $lowStock->count());
    }

    public function test_transaction_pages_render_with_seeded_data(): void
    {
        $user = User::where('email', 'admin@gudangku.test')->firstOrFail();
        $stockOut = StockOut::firstOrFail();
        $adjustment = StockAdjustment::firstOrFail();

        $routes = [
            ['stock-outs.index', []],
            ['stock-outs.create', []],
            ['stock-outs.show', ['stock_out' => $stockOut]],
            ['stock-adjustments.index', []],
            ['stock-adjustments.create', []],
            ['stock-adjustments.show', ['stock_adjustment' => $adjustment]],
        ];

        foreach ($routes as [$route, $parameters]) {
            $this->actingAs($user)
                ->get(route($route, $parameters))
                ->assertOk();
        }
    }

    public function test_draft_transactions_can_be_posted(): void
    {
        $user = User::where('email', 'admin@gudangku.test')->firstOrFail();
        $stockOut = StockOut::where('status', 'draft')->firstOrFail();
        $adjustment = StockAdjustment::where('status', 'draft')->firstOrFail();

        $stockBefore = (float) Stock::sum('quantity');

        $this->actingAs($user)
            ->post(route('stock-outs.post', $stockOut))
            ->assertRedirect(route('stock-outs.show', $stockOut));

        $this->assertSame('posted', $stockOut->fresh()->status);
        $this->assertLessThan($stockBefore, (float) Stock::sum('quantity'));

        $stockBeforeAdjustment = (float) Stock::sum('quantity');

        $this->actingAs($user)
            ->post(route('stock-adjustments.post', $adjustment))
            ->assertRedirect(route('stock-adjustments.show', $adjustment));

        $this->assertSame('posted', $adjustment->fresh()->status);
        $this->assertGreaterThan($stockBeforeAdjustment, (float) Stock::sum('quantity'));
    }
}
