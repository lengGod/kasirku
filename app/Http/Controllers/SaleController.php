<?php

declare(strict_types=1);

namespace App\Http\Controllers;

use App\Enums\SaleStatus;
use App\Models\ReceiptPrintLog;
use App\Models\Sale;
use App\Models\Setting;
use App\Services\RefundService;
use App\Services\SupervisorPinService;
use Barryvdh\DomPDF\Facade\Pdf;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\Http\Response as HttpResponse;
use Inertia\Inertia;
use Inertia\Response;

class SaleController extends Controller
{
    public function index(Request $request): Response
    {
        $query = Sale::query()
            ->with(['cashier', 'customer'])
            ->withCount('items')
            ->latest();

        if ($search = trim((string) $request->query('search'))) {
            $query->where(function ($query) use ($search): void {
                $query->where('invoice_number', 'like', "%{$search}%")
                    ->orWhereHas('customer', fn ($query) => $query->where('name', 'like', "%{$search}%"));
            });
        }

        if ($status = $request->query('status')) {
            $query->where('status', $status);
        }

        if ($from = $request->query('date_from')) {
            $query->whereDate('created_at', '>=', $from);
        }

        if ($to = $request->query('date_to')) {
            $query->whereDate('created_at', '<=', $to);
        }

        return Inertia::render('Sales/Index', [
            'sales' => $query->paginate(15)->withQueryString(),
            'filters' => [
                'search' => $request->query('search'),
                'status' => $request->query('status'),
                'date_from' => $request->query('date_from'),
                'date_to' => $request->query('date_to'),
            ],
            'statuses' => collect(SaleStatus::cases())->map(fn (SaleStatus $status): array => [
                'value' => $status->value,
                'label' => $status->label(),
            ]),
        ]);
    }

    public function show(Sale $sale): Response
    {
        $sale->load(['items.product', 'payments.paymentMethod', 'cashier', 'customer', 'shift', 'refunds.items.saleItem', 'voidedBy']);

        return Inertia::render('Sales/Show', [
            'sale' => $sale,
        ]);
    }

    public function receipt(Sale $sale): Response
    {
        $sale->load(['items', 'payments.paymentMethod', 'cashier', 'customer']);

        return Inertia::render('Pos/Receipt', [
            'sale' => $sale,
            'store' => $this->storeData(),
            'isCopy' => request()->boolean('copy'),
        ]);
    }

    public function pdf(Sale $sale): HttpResponse
    {
        $sale->load(['items', 'payments.paymentMethod', 'cashier', 'customer']);

        $pdf = Pdf::loadView('receipts.pdf', [
            'sale' => $sale,
            'store' => $this->storeData(),
            'isCopy' => request()->boolean('copy'),
        ])->setPaper([0, 0, 226.77, 800], 'portrait');

        return $pdf->download($sale->invoice_number.'.pdf');
    }

    public function printLog(Request $request, Sale $sale): RedirectResponse
    {
        ReceiptPrintLog::create([
            'sale_id' => $sale->id,
            'printed_by' => $request->user()->id,
            'is_copy' => $request->boolean('is_copy'),
        ]);

        return back()->with('success', 'Cetak struk dicatat.');
    }

    public function void(Request $request, Sale $sale, RefundService $refunds, SupervisorPinService $pins): RedirectResponse
    {
        $validated = $request->validate([
            'reason' => ['required', 'string', 'min:5', 'max:255'],
            'pin' => ['required', 'string'],
        ]);

        $pins->verify($validated['pin']);
        $refund = $refunds->void($sale, $request->user(), $validated['reason']);

        return redirect()
            ->route('sales.show', $sale)
            ->with('success', 'Transaksi di-void. Nomor retur: '.$refund->refund_number.'.');
    }

    /**
     * @return array<string, string>
     */
    private function storeData(): array
    {
        return [
            'name' => (string) Setting::get('store_name', 'KasirKu'),
            'address' => (string) Setting::get('store_address', ''),
            'phone' => (string) Setting::get('store_phone', ''),
            'footer' => (string) Setting::get('receipt_footer', 'Terima kasih telah berbelanja.'),
        ];
    }
}
