<?php

declare(strict_types=1);

namespace App\Http\Controllers;

use App\Models\Category;
use App\Models\Product;
use App\Models\Unit;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Inertia\Inertia;
use Inertia\Response;

class ProductController extends Controller
{
    public function index(Request $request): Response
    {
        $query = Product::query()
            ->with(['category', 'unit'])
            ->withSum('stocks as stock_quantity', 'quantity');

        if ($search = trim((string) $request->query('search'))) {
            $query->where(function ($query) use ($search): void {
                $query->where('name', 'like', "%{$search}%")
                    ->orWhere('sku', 'like', "%{$search}%")
                    ->orWhere('barcode', 'like', "%{$search}%");
            });
        }

        if ($categoryId = $request->query('category_id')) {
            $query->where('category_id', $categoryId);
        }

        if ($request->boolean('active_only', true)) {
            $query->where('is_active', true);
        }

        return Inertia::render('Products/Index', [
            'products' => $query->orderBy('name')->paginate(15)->withQueryString(),
            'categories' => Category::query()->orderBy('name')->get(),
            'filters' => [
                'search' => $request->query('search'),
                'category_id' => $request->query('category_id'),
                'active_only' => $request->boolean('active_only', true),
            ],
        ]);
    }

    public function create(): Response
    {
        return Inertia::render('Products/Create', [
            'categories' => Category::query()->orderBy('name')->get(),
            'units' => Unit::query()->orderBy('name')->get(),
        ]);
    }

    public function store(Request $request): RedirectResponse
    {
        $validated = $request->validate([
            'sku' => ['required', 'string', 'max:50', 'unique:products'],
            'barcode' => ['nullable', 'string', 'max:255', 'unique:products'],
            'name' => ['required', 'string', 'max:255'],
            'category_id' => ['required', 'exists:categories,id'],
            'unit_id' => ['required', 'exists:units,id'],
            'cost_price' => ['nullable', 'numeric', 'min:0'],
            'sell_price' => ['nullable', 'numeric', 'min:0'],
            'is_taxable' => ['boolean'],
            'min_stock' => ['nullable', 'numeric', 'min:0'],
            'image' => ['nullable', 'string', 'max:255'],
            'track_stock' => ['boolean'],
            'track_batch' => ['boolean'],
            'track_expiry' => ['boolean'],
            'is_active' => ['boolean'],
        ]);

        Product::create([
            ...$validated,
            'is_taxable' => (bool) ($validated['is_taxable'] ?? false),
            'min_stock' => $validated['min_stock'] ?? 0,
            'cost_price' => $validated['cost_price'] ?? 0,
            'sell_price' => $validated['sell_price'] ?? 0,
            'image' => $validated['image'] ?? null,
            'track_stock' => $validated['track_stock'] ?? true,
            'track_batch' => $validated['track_batch'] ?? false,
            'track_expiry' => $validated['track_expiry'] ?? false,
            'is_active' => $validated['is_active'] ?? true,
        ]);

        return redirect()->route('products.index')->with('success', 'Produk berhasil ditambahkan.');
    }

    public function show(Product $product): Response
    {
        return Inertia::render('Products/Show', [
            'product' => $product->load(['category', 'unit', 'stocks', 'movements.user' => fn ($query) => $query->latest('created_at')->limit(10)]),
        ]);
    }

    public function edit(Product $product): Response
    {
        return Inertia::render('Products/Edit', [
            'product' => $product,
            'categories' => Category::query()->orderBy('name')->get(),
            'units' => Unit::query()->orderBy('name')->get(),
        ]);
    }

    public function update(Request $request, Product $product): RedirectResponse
    {
        $validated = $request->validate([
            'sku' => ['required', 'string', 'max:50', 'unique:products,sku,'.$product->id],
            'barcode' => ['nullable', 'string', 'max:255', 'unique:products,barcode,'.$product->id],
            'name' => ['required', 'string', 'max:255'],
            'category_id' => ['required', 'exists:categories,id'],
            'unit_id' => ['required', 'exists:units,id'],
            'cost_price' => ['nullable', 'numeric', 'min:0'],
            'sell_price' => ['nullable', 'numeric', 'min:0'],
            'is_taxable' => ['boolean'],
            'min_stock' => ['nullable', 'numeric', 'min:0'],
            'image' => ['nullable', 'string', 'max:255'],
            'track_stock' => ['boolean'],
            'track_batch' => ['boolean'],
            'track_expiry' => ['boolean'],
            'is_active' => ['boolean'],
        ]);

        $product->update([
            ...$validated,
            'is_taxable' => (bool) ($validated['is_taxable'] ?? false),
            'min_stock' => $validated['min_stock'] ?? 0,
            'cost_price' => $validated['cost_price'] ?? 0,
            'sell_price' => $validated['sell_price'] ?? 0,
            'image' => $validated['image'] ?? null,
            'track_stock' => $validated['track_stock'] ?? true,
            'track_batch' => $validated['track_batch'] ?? false,
            'track_expiry' => $validated['track_expiry'] ?? false,
            'is_active' => $validated['is_active'] ?? true,
        ]);

        return redirect()->route('products.index')->with('success', 'Produk berhasil diperbarui.');
    }

    public function destroy(Product $product): RedirectResponse
    {
        if ($product->saleItems()->exists()) {
            return back()->with('error', 'Produk yang pernah terjual tidak dapat dihapus. Nonaktifkan saja.');
        }

        $product->delete();

        return redirect()->route('products.index')->with('success', 'Produk berhasil dihapus.');
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
