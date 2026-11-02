<?php

declare(strict_types=1);

namespace App\Http\Controllers;

use App\Enums\SaleStatus;
use App\Models\Customer;
use App\Models\Product;
use App\Models\Sale;
use App\Services\ShiftService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Inertia\Inertia;
use Inertia\Response;

class DashboardController extends Controller
{
    public function search(Request $request): JsonResponse
    {
        $search = trim((string) $request->query('search', ''));

        if ($search === '') {
            return response()->json(['results' => []]);
        }

        $products = Product::query()->where(function ($query) use ($search): void {
            $query->where('name', 'like', "%{$search}%")
                ->orWhere('sku', 'like', "%{$search}%")
                ->orWhere('barcode', 'like', "%{$search}%");
        })->limit(5)->get(['id', 'name', 'sku'])->map(fn (Product $product): array => [
            'type' => 'Produk', 'label' => $product->name, 'meta' => $product->sku, 'url' => route('products.show', $product),
        ]);
        $customers = Customer::query()->where(function ($query) use ($search): void {
            $query->where('name', 'like', "%{$search}%")->orWhere('phone', 'like', "%{$search}%");
        })->limit(5)->get(['id', 'name', 'phone'])->map(fn (Customer $customer): array => [
            'type' => 'Pelanggan', 'label' => $customer->name, 'meta' => $customer->phone ?: 'Data pelanggan', 'url' => route('customers.index', ['search' => $customer->name]),
        ]);
        $sales = Sale::query()->where('invoice_number', 'like', "%{$search}%")->limit(5)->get(['id', 'invoice_number', 'grand_total'])->map(fn (Sale $sale): array => [
            'type' => 'Penjualan', 'label' => $sale->invoice_number, 'meta' => 'Rp '.number_format((float) $sale->grand_total, 0, ',', '.'), 'url' => route('sales.show', $sale),
        ]);

        return response()->json(['results' => $products->concat($customers)->concat($sales)->values()->all()]);
    }

    public function index(Request $request, ShiftService $shifts): Response
    {
        $today = Sale::query()->whereDate('created_at', today())->where('status', '!=', SaleStatus::Voided->value);
        $yesterday = Sale::query()->whereDate('created_at', today()->subDay())->where('status', '!=', SaleStatus::Voided->value);

        $todayTotal = round((float) (clone $today)->sum('grand_total'), 2);
        $todayCount = (clone $today)->count();
        $yesterdayTotal = round((float) $yesterday->sum('grand_total'), 2);

        $chart = collect(range(6, 0))->map(function (int $daysAgo): array {
            $date = today()->subDays($daysAgo);

            return [
                'label' => $date->translatedFormat('d M'),
                'total' => round((float) Sale::query()
                    ->whereDate('created_at', $date)
                    ->where('status', '!=', SaleStatus::Voided->value)
                    ->sum('grand_total'), 2),
            ];
        })->values();

        $topProducts = DB::table('sale_items')
            ->join('sales', 'sales.id', '=', 'sale_items.sale_id')
            ->where('sales.status', '!=', SaleStatus::Voided->value)
            ->where('sales.created_at', '>=', now()->subDays(30))
            ->groupBy('sale_items.product_id', 'sale_items.name_snapshot')
            ->selectRaw('sale_items.product_id, sale_items.name_snapshot as name, SUM(sale_items.qty) as qty, SUM(sale_items.line_total) as total')
            ->orderByDesc('qty')
            ->limit(5)
            ->get();

        $lowStock = Product::query()
            ->with(['unit', 'category'])
            ->withSum('stocks as stock_quantity', 'quantity')
            ->where('track_stock', true)
            ->where('is_active', true)
            ->get()
            ->filter(fn (Product $product): bool => (float) $product->stock_quantity <= (float) $product->min_stock)
            ->take(6)
            ->values();

        return Inertia::render('Dashboard', [
            'summary' => [
                'today_total' => $todayTotal,
                'today_count' => $todayCount,
                'today_average' => $todayCount > 0 ? round($todayTotal / $todayCount, 2) : 0,
                'yesterday_total' => $yesterdayTotal,
                'growth' => $yesterdayTotal > 0 ? round((($todayTotal - $yesterdayTotal) / $yesterdayTotal) * 100, 1) : null,
            ],
            'chart' => $chart->values()->all(),
            'topProducts' => $topProducts,
            'lowStock' => $lowStock,
            'openShift' => $shifts->openShiftFor($request->user()),
            'recentSales' => Sale::query()
                ->with(['cashier', 'customer'])
                ->latest()
                ->limit(6)
                ->get(),
        ]);
    }
}
