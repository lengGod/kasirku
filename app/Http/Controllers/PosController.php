<?php

declare(strict_types=1);

namespace App\Http\Controllers;

use App\Models\Category;
use App\Models\Customer;
use App\Models\HeldSale;
use App\Models\PaymentMethod;
use App\Models\Product;
use App\Models\Setting;
use App\Services\CheckoutService;
use App\Services\ShiftService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Inertia\Inertia;
use Inertia\Response;

class PosController extends Controller
{
    public function index(Request $request, ShiftService $shifts): Response|RedirectResponse
    {
        $shift = $shifts->openShiftFor($request->user());

        if (! $shift) {
            return redirect()->route('shifts.open')->with('error', 'Buka shift terlebih dahulu sebelum memulai transaksi.');
        }

        return Inertia::render('Pos/Index', [
            'shift' => $shift,
            'products' => $this->productQuery()
                ->limit(120)
                ->get()
                ->map(fn (Product $product): array => $this->productPayload($product)),
            'categories' => Category::query()->orderBy('name')->get(),
            'customers' => Customer::query()->orderBy('name')->get(),
            'paymentMethods' => PaymentMethod::query()->where('is_active', true)->orderBy('name')->get(),
            'heldCount' => HeldSale::query()->where('cashier_id', $request->user()->id)->count(),
            'heldSales' => HeldSale::query()->where('cashier_id', $request->user()->id)->latest()->get(),
            'resumeCart' => $request->session()->pull('resume_cart'),
            'settings' => [
                'tax_rate' => (float) Setting::get('tax_rate', '0'),
                'tax_included' => Setting::get('tax_included', '0') === '1',
                'rounding_step' => (int) Setting::get('rounding_step', '0'),
                'max_discount_without_pin' => (float) Setting::get('max_discount_without_pin', '0'),
            ],
        ]);
    }

    public function search(Request $request): JsonResponse
    {
        $term = trim((string) $request->query('q', ''));

        $products = $this->productQuery()
            ->when($term !== '', function ($query) use ($term): void {
                $query->where(function ($query) use ($term): void {
                    $query->where('name', 'like', "%{$term}%")
                        ->orWhere('sku', 'like', "%{$term}%")
                        ->orWhere('barcode', 'like', "%{$term}%");
                });
            })
            ->orderBy('name')
            ->limit(24)
            ->get()
            ->map(fn (Product $product): array => $this->productPayload($product));

        return response()->json(['products' => $products]);
    }

    public function lookup(Request $request): JsonResponse
    {
        $code = trim((string) $request->query('code', ''));

        $product = $this->productQuery()
            ->where(function ($query) use ($code): void {
                $query->where('barcode', $code)->orWhere('sku', $code);
            })
            ->first();

        if (! $product) {
            return response()->json(['message' => 'Produk tidak ditemukan.'], 404);
        }

        return response()->json(['product' => $this->productPayload($product)]);
    }

    public function checkout(Request $request, CheckoutService $checkout): JsonResponse|RedirectResponse
    {
        $validated = $request->validate([
            'idempotency_key' => ['required', 'string', 'max:100'],
            'customer_id' => ['nullable', 'exists:customers,id'],
            'discount_total' => ['nullable', 'numeric', 'min:0'],
            'items' => ['required', 'array', 'min:1'],
            'items.*.product_id' => ['required', 'exists:products,id'],
            'items.*.qty' => ['required', 'numeric', 'gt:0'],
            'items.*.discount' => ['nullable', 'numeric', 'min:0'],
            'payments' => ['required', 'array', 'min:1'],
            'payments.*.payment_method_id' => ['required', 'exists:payment_methods,id'],
            'payments.*.amount' => ['required', 'numeric', 'min:0'],
            'payments.*.reference' => ['nullable', 'string', 'max:255'],
        ]);

        $sale = $checkout->checkout($request->user(), $validated);

        if ($request->wantsJson()) {
            return response()->json([
                'sale' => $sale,
                'receipt_url' => route('sales.receipt', $sale),
            ]);
        }

        return redirect()
            ->route('sales.receipt', $sale)
            ->with('success', 'Transaksi '.$sale->invoice_number.' berhasil disimpan.');
    }

    public function held(Request $request): Response
    {
        return Inertia::render('Pos/Held', [
            'heldSales' => HeldSale::query()
                ->where('cashier_id', $request->user()->id)
                ->latest()
                ->get(),
        ]);
    }

    public function hold(Request $request): RedirectResponse
    {
        $validated = $request->validate([
            'label' => ['required', 'string', 'max:100'],
            'cart' => ['required', 'array'],
        ]);

        HeldSale::create([
            'cashier_id' => $request->user()->id,
            'label' => $validated['label'],
            'cart_json' => $validated['cart'],
        ]);

        return back()->with('success', 'Bill berhasil ditahan.');
    }

    public function destroyHeld(Request $request, HeldSale $heldSale): RedirectResponse
    {
        abort_unless($heldSale->cashier_id === $request->user()->id, 403);
        $heldSale->delete();

        return back()->with('success', 'Bill tertahan dihapus.');
    }

    public function resume(Request $request, HeldSale $heldSale): RedirectResponse
    {
        abort_unless($heldSale->cashier_id === $request->user()->id, 403);

        $cart = $heldSale->cart_json;
        $heldSale->delete();
        $request->session()->put('resume_cart', $cart);

        return redirect()->route('pos.index')->with('success', 'Bill dilanjutkan.');
    }

    private function productQuery()
    {
        return Product::query()
            ->with(['category', 'unit'])
            ->withSum('stocks as stock_quantity', 'quantity')
            ->where('is_active', true);
    }

    /**
     * @return array<string, mixed>
     */
    private function productPayload(Product $product): array
    {
        return [
            'id' => $product->id,
            'sku' => $product->sku,
            'barcode' => $product->barcode,
            'name' => $product->name,
            'category' => $product->category?->name,
            'unit' => $product->unit?->short_name,
            'sell_price' => (float) $product->sell_price,
            'cost_price' => (float) $product->cost_price,
            'is_taxable' => (bool) $product->is_taxable,
            'track_stock' => (bool) $product->track_stock,
            'stock' => (float) ($product->stock_quantity ?? 0),
        ];
    }
}
