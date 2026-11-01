<?php

declare(strict_types=1);

namespace App\Http\Controllers;

use App\Enums\MovementType;
use App\Models\Product;
use App\Models\StockAdjustment;
use App\Models\StockIn;
use App\Models\StockMovement;
use App\Services\DocumentNumberService;
use App\Services\StockService;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Inertia\Inertia;
use Inertia\Response;

class StockController extends Controller
{
    public function receiveIndex(): Response
    {
        return Inertia::render('Stock/ReceiveIndex', [
            'documents' => StockIn::query()->with('creator')->withCount('items')->latest()->paginate(15),
        ]);
    }

    public function receiveCreate(): Response
    {
        return Inertia::render('Stock/Receive', [
            'products' => Product::query()->with('unit')->where('is_active', true)->orderBy('name')->get(),
        ]);
    }

    public function receiveStore(Request $request, StockService $stock, DocumentNumberService $numbers): RedirectResponse
    {
        $validated = $request->validate([
            'supplier_name' => ['nullable', 'string', 'max:255'],
            'received_at' => ['required', 'date'],
            'note' => ['nullable', 'string'],
            'items' => ['required', 'array', 'min:1'],
            'items.*.product_id' => ['required', 'exists:products,id'],
            'items.*.qty' => ['required', 'numeric', 'gt:0'],
            'items.*.cost_price' => ['nullable', 'numeric', 'min:0'],
        ]);

        DB::transaction(function () use ($validated, $request, $stock, $numbers): void {
            $document = StockIn::create([
                'document_number' => $numbers->next('IN', now()->format('Ym')),
                'supplier_name' => $validated['supplier_name'] ?? null,
                'received_at' => $validated['received_at'],
                'note' => $validated['note'] ?? null,
                'created_by' => $request->user()->id,
            ]);

            foreach ($validated['items'] as $item) {
                $product = Product::query()->findOrFail($item['product_id']);
                $document->items()->create([
                    'product_id' => $product->id,
                    'qty' => $item['qty'],
                    'cost_price' => $item['cost_price'] ?? $product->cost_price,
                ]);

                $stock->increase(
                    $product,
                    (float) $item['qty'],
                    StockIn::class,
                    $document->id,
                    $request->user()->id,
                    $document->document_number,
                    MovementType::In,
                );
            }

            activity()->causedBy($request->user())->performedOn($document)->log('Penerimaan stok dibuat');
        });

        return redirect()->route('stock.receive.index')->with('success', 'Penerimaan stok berhasil disimpan.');
    }

    public function adjustIndex(): Response
    {
        return Inertia::render('Stock/AdjustIndex', [
            'documents' => StockAdjustment::query()->with('creator')->withCount('items')->latest()->paginate(15),
        ]);
    }

    public function adjustCreate(): Response
    {
        return Inertia::render('Stock/Adjust', [
            'products' => Product::query()
                ->with('unit')
                ->withSum('stocks as stock_quantity', 'quantity')
                ->where('is_active', true)
                ->orderBy('name')
                ->get(),
        ]);
    }

    public function adjustStore(Request $request, StockService $stock, DocumentNumberService $numbers): RedirectResponse
    {
        $validated = $request->validate([
            'reason' => ['required', 'string', 'max:255'],
            'items' => ['required', 'array', 'min:1'],
            'items.*.product_id' => ['required', 'exists:products,id'],
            'items.*.qty_after' => ['required', 'numeric', 'min:0'],
        ]);

        DB::transaction(function () use ($validated, $request, $stock, $numbers): void {
            $document = StockAdjustment::create([
                'document_number' => $numbers->next('ADJ', now()->format('Ymd')),
                'reason' => $validated['reason'],
                'created_by' => $request->user()->id,
            ]);

            foreach ($validated['items'] as $item) {
                $product = Product::query()->findOrFail($item['product_id']);
                $before = $stock->currentStock($product);
                $difference = $stock->adjust(
                    $product,
                    (float) $item['qty_after'],
                    StockAdjustment::class,
                    $document->id,
                    $request->user()->id,
                    $document->document_number,
                );

                $document->items()->create([
                    'product_id' => $product->id,
                    'qty_before' => $before,
                    'qty_after' => $item['qty_after'],
                    'difference' => $difference,
                ]);
            }

            activity()->causedBy($request->user())->performedOn($document)->log('Penyesuaian stok dibuat');
        });

        return redirect()->route('stock.adjust.index')->with('success', 'Penyesuaian stok berhasil disimpan.');
    }

    public function movements(Request $request): Response
    {
        $query = StockMovement::query()->with(['product', 'user'])->latest('created_at');

        if ($productId = $request->query('product_id')) {
            $query->where('product_id', $productId);
        }

        if ($type = $request->query('type')) {
            $query->where('type', $type);
        }

        if ($from = $request->query('date_from')) {
            $query->whereDate('created_at', '>=', $from);
        }

        if ($to = $request->query('date_to')) {
            $query->whereDate('created_at', '<=', $to);
        }

        return Inertia::render('Stock/Movements', [
            'movements' => $query->paginate(20)->withQueryString(),
            'products' => Product::query()->orderBy('name')->get(['id', 'name']),
            'types' => collect(MovementType::cases())->map(fn (MovementType $type): array => [
                'value' => $type->value,
                'label' => $type->label(),
            ]),
            'filters' => [
                'product_id' => $request->query('product_id'),
                'type' => $request->query('type'),
                'date_from' => $request->query('date_from'),
                'date_to' => $request->query('date_to'),
            ],
        ]);
    }
}
