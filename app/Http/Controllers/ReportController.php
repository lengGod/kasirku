<?php

declare(strict_types=1);

namespace App\Http\Controllers;

use App\Models\Sale;
use App\Models\Setting;
use App\Models\Shift;
use App\Models\StockMovement;
use Barryvdh\DomPDF\Facade\Pdf;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Inertia\Inertia;
use Inertia\Response;
use Symfony\Component\HttpFoundation\StreamedResponse;

class ReportController extends Controller
{
    private const TYPES = ['sales', 'profit', 'products', 'cashiers', 'payments', 'shifts', 'stock'];

    public function index(Request $request, string $type = 'sales'): Response
    {
        abort_unless(in_array($type, self::TYPES, true), 404);

        $report = $this->build($type, $request);

        return Inertia::render('Reports/Index', [
            'type' => $type,
            'title' => $report['title'],
            'headers' => $report['headers'],
            'rows' => $report['rows'],
            'summary' => $report['summary'],
            'filters' => [
                'date_from' => $request->query('date_from', today()->startOfMonth()->toDateString()),
                'date_to' => $request->query('date_to', today()->toDateString()),
            ],
        ]);
    }

    public function export(Request $request, string $type): StreamedResponse
    {
        abort_unless(in_array($type, self::TYPES, true), 404);

        $report = $this->build($type, $request);

        return response()->streamDownload(function () use ($report): void {
            $handle = fopen('php://output', 'w');
            fputcsv($handle, $report['headers']);

            foreach ($report['rows'] as $row) {
                fputcsv($handle, $row);
            }

            fclose($handle);
        }, "laporan-{$type}-".now()->format('Ymd').'.csv', ['Content-Type' => 'text/csv']);
    }

    public function pdf(Request $request, string $type)
    {
        abort_unless(in_array($type, self::TYPES, true), 404);

        $report = $this->build($type, $request);

        return Pdf::loadView('reports.pdf', [
            'title' => $report['title'],
            'headers' => $report['headers'],
            'rows' => $report['rows'],
            'summary' => $report['summary'],
            'store' => Setting::get('store_name', 'KasirKu'),
            'period' => $request->query('date_from').' s/d '.$request->query('date_to'),
        ])->setPaper('a4', 'landscape')->download("laporan-{$type}-".now()->format('Ymd').'.pdf');
    }

    /**
     * @return array{title:string, headers:array<int, string>, rows:array<int, array<int, mixed>>, summary:array<string, mixed>}
     */
    private function build(string $type, Request $request): array
    {
        $from = $request->query('date_from', today()->startOfMonth()->toDateString());
        $to = $request->query('date_to', today()->toDateString());

        return match ($type) {
            'sales' => $this->salesReport($from, $to),
            'profit' => $this->profitReport($from, $to),
            'products' => $this->productReport($from, $to),
            'cashiers' => $this->cashierReport($from, $to),
            'payments' => $this->paymentReport($from, $to),
            'shifts' => $this->shiftReport($from, $to),
            'stock' => $this->stockReport(),
        };
    }

    private function salesReport(string $from, string $to): array
    {
        $sales = Sale::query()
            ->with(['cashier', 'customer'])
            ->whereBetween('created_at', [$from.' 00:00:00', $to.' 23:59:59'])
            ->latest()
            ->get();

        return [
            'title' => 'Laporan Penjualan',
            'headers' => ['No. Struk', 'Tanggal', 'Kasir', 'Pelanggan', 'Status', 'Total'],
            'rows' => $sales->map(fn (Sale $sale): array => [
                $sale->invoice_number,
                $sale->created_at->format('d/m/Y H:i'),
                $sale->cashier?->name,
                $sale->customer?->name ?? 'Umum',
                $sale->status->label(),
                (float) $sale->grand_total,
            ])->all(),
            'summary' => [
                'total' => (float) $sales->where('status', '!=', 'voided')->sum('grand_total'),
                'transaksi' => $sales->where('status', '!=', 'voided')->count(),
            ],
        ];
    }

    private function profitReport(string $from, string $to): array
    {
        $rows = DB::table('sale_items')
            ->join('sales', 'sales.id', '=', 'sale_items.sale_id')
            ->whereBetween('sales.created_at', [$from.' 00:00:00', $to.' 23:59:59'])
            ->where('sales.status', '!=', 'voided')
            ->groupBy('sale_items.product_id', 'sale_items.name_snapshot')
            ->selectRaw('sale_items.name_snapshot as name, SUM(sale_items.qty) as qty, SUM(sale_items.line_total) as revenue, SUM(sale_items.qty * sale_items.cost_price) as cost')
            ->orderByDesc('revenue')
            ->get();

        return [
            'title' => 'Laporan Laba Kotor',
            'headers' => ['Produk', 'Qty', 'Penjualan', 'HPP', 'Laba'],
            'rows' => $rows->map(fn ($row): array => [
                $row->name,
                (float) $row->qty,
                (float) $row->revenue,
                (float) $row->cost,
                round((float) $row->revenue - (float) $row->cost, 2),
            ])->all(),
            'summary' => [
                'penjualan' => round((float) $rows->sum('revenue'), 2),
                'laba' => round((float) $rows->sum('revenue') - (float) $rows->sum('cost'), 2),
            ],
        ];
    }

    private function productReport(string $from, string $to): array
    {
        $rows = DB::table('sale_items')
            ->join('sales', 'sales.id', '=', 'sale_items.sale_id')
            ->whereBetween('sales.created_at', [$from.' 00:00:00', $to.' 23:59:59'])
            ->where('sales.status', '!=', 'voided')
            ->groupBy('sale_items.product_id', 'sale_items.name_snapshot')
            ->selectRaw('sale_items.name_snapshot as name, SUM(sale_items.qty) as qty, SUM(sale_items.line_total) as revenue')
            ->orderByDesc('qty')
            ->get();

        return [
            'title' => 'Laporan Penjualan per Produk',
            'headers' => ['Produk', 'Qty Terjual', 'Total Penjualan'],
            'rows' => $rows->map(fn ($row): array => [$row->name, (float) $row->qty, (float) $row->revenue])->all(),
            'summary' => ['total_qty' => (float) $rows->sum('qty'), 'total' => (float) $rows->sum('revenue')],
        ];
    }

    private function cashierReport(string $from, string $to): array
    {
        $rows = DB::table('sales')
            ->join('users', 'users.id', '=', 'sales.cashier_id')
            ->whereBetween('sales.created_at', [$from.' 00:00:00', $to.' 23:59:59'])
            ->where('sales.status', '!=', 'voided')
            ->groupBy('users.id', 'users.name')
            ->selectRaw('users.name, COUNT(sales.id) as transactions, SUM(sales.grand_total) as total')
            ->orderByDesc('total')
            ->get();

        return [
            'title' => 'Laporan Penjualan per Kasir',
            'headers' => ['Kasir', 'Jumlah Transaksi', 'Total Penjualan'],
            'rows' => $rows->map(fn ($row): array => [$row->name, (int) $row->transactions, (float) $row->total])->all(),
            'summary' => ['transaksi' => (int) $rows->sum('transactions'), 'total' => (float) $rows->sum('total')],
        ];
    }

    private function paymentReport(string $from, string $to): array
    {
        $rows = DB::table('sale_payments')
            ->join('sales', 'sales.id', '=', 'sale_payments.sale_id')
            ->join('payment_methods', 'payment_methods.id', '=', 'sale_payments.payment_method_id')
            ->whereBetween('sales.created_at', [$from.' 00:00:00', $to.' 23:59:59'])
            ->where('sales.status', '!=', 'voided')
            ->groupBy('payment_methods.id', 'payment_methods.name')
            ->selectRaw('payment_methods.name, COUNT(sale_payments.id) as transactions, SUM(sale_payments.amount) as total')
            ->orderByDesc('total')
            ->get();

        return [
            'title' => 'Laporan per Metode Pembayaran',
            'headers' => ['Metode', 'Jumlah Pembayaran', 'Total'],
            'rows' => $rows->map(fn ($row): array => [$row->name, (int) $row->transactions, (float) $row->total])->all(),
            'summary' => ['total' => (float) $rows->sum('total')],
        ];
    }

    private function shiftReport(string $from, string $to): array
    {
        $shifts = Shift::query()
            ->with('user')
            ->whereBetween('opened_at', [$from.' 00:00:00', $to.' 23:59:59'])
            ->orderByDesc('opened_at')
            ->get();

        return [
            'title' => 'Laporan Shift',
            'headers' => ['Kasir', 'Buka', 'Tutup', 'Modal', 'Ekspektasi', 'Aktual', 'Selisih'],
            'rows' => $shifts->map(fn (Shift $shift): array => [
                $shift->user?->name,
                $shift->opened_at?->format('d/m/Y H:i'),
                $shift->closed_at?->format('d/m/Y H:i') ?? '-',
                (float) $shift->opening_cash,
                (float) $shift->expected_cash,
                (float) ($shift->actual_cash ?? 0),
                (float) $shift->difference,
            ])->all(),
            'summary' => ['selisih' => (float) $shifts->sum('difference')],
        ];
    }

    private function stockReport(): array
    {
        $products = \App\Models\Product::query()
            ->with(['unit'])
            ->withSum('stocks as stock_quantity', 'quantity')
            ->orderBy('name')
            ->get();

        return [
            'title' => 'Laporan Stok',
            'headers' => ['SKU', 'Produk', 'Stok', 'Satuan', 'Harga Beli', 'Nilai Stok'],
            'rows' => $products->map(fn ($product): array => [
                $product->sku,
                $product->name,
                (float) ($product->stock_quantity ?? 0),
                $product->unit?->short_name,
                (float) $product->cost_price,
                round((float) ($product->stock_quantity ?? 0) * (float) $product->cost_price, 2),
            ])->all(),
            'summary' => [
                'nilai' => round((float) $products->sum(fn ($product) => (float) ($product->stock_quantity ?? 0) * (float) $product->cost_price), 2),
            ],
        ];
    }
}
