<?php

declare(strict_types=1);

namespace App\Http\Controllers;

use App\Enums\SaleStatus;
use App\Models\Refund;
use App\Models\Sale;
use App\Services\RefundService;
use App\Services\SupervisorPinService;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Inertia\Inertia;
use Inertia\Response;

class RefundController extends Controller
{
    public function index(Request $request): Response
    {
        $refunds = Refund::query()
            ->with(['sale', 'creator', 'approvedBy'])
            ->withCount('items')
            ->latest()
            ->paginate(15)
            ->withQueryString();

        return Inertia::render('Refunds/Index', [
            'refunds' => $refunds,
        ]);
    }

    public function create(Request $request): Response
    {
        $sale = null;

        if ($saleId = $request->query('sale_id')) {
            $sale = Sale::query()
                ->with(['items', 'cashier', 'customer'])
                ->whereIn('status', [SaleStatus::Paid->value, SaleStatus::PartialRefund->value])
                ->find($saleId);
        }

        return Inertia::render('Refunds/Create', [
            'sale' => $sale,
            'recentSales' => Sale::query()
                ->with(['customer', 'items'])
                ->whereIn('status', [SaleStatus::Paid->value, SaleStatus::PartialRefund->value])
                ->latest()
                ->limit(15)
                ->get(),
        ]);
    }

    public function store(Request $request, RefundService $refunds, SupervisorPinService $pins): RedirectResponse
    {
        $validated = $request->validate([
            'sale_id' => ['required', 'exists:sales,id'],
            'reason' => ['required', 'string', 'min:5', 'max:255'],
            'pin' => ['required', 'string'],
            'items' => ['required', 'array', 'min:1'],
            'items.*.sale_item_id' => ['required', 'exists:sale_items,id'],
            'items.*.qty' => ['required', 'numeric', 'gt:0'],
            'items.*.restock' => ['boolean'],
        ]);

        $pins->verify($validated['pin']);
        $sale = Sale::query()->findOrFail($validated['sale_id']);
        $refund = $refunds->refund($sale, $validated['items'], $request->user(), $validated['reason']);

        return redirect()
            ->route('refunds.show', $refund)
            ->with('success', 'Retur berhasil dibuat.');
    }

    public function show(Refund $refund): Response
    {
        $refund->load(['sale', 'items.saleItem', 'creator', 'approvedBy', 'shift']);

        return Inertia::render('Refunds/Show', [
            'refund' => $refund,
        ]);
    }
}
