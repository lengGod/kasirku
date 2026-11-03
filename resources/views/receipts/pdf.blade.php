@php
use Illuminate\Support\Carbon;
@endphp

<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="utf-8">
    <title>Struk {{ $sale->invoice_number }}</title>
    <style>
        @page {
            margin: 0;
            size: [80mm, 120mm];
        }
        body {
            font-family: "Courier New", monospace;
            font-size: 11px;
            line-height: 1.3;
            margin: 0;
            padding: 8px;
            color: #111;
        }
        .receipt {
            max-width: 320px;
            margin: 0 auto;
        }
        .center { text-align: center; }
        .title { font-weight: bold; font-size: 16px; margin-bottom: 4px; }
        .bold { font-weight: bold; }
        .sep { border-bottom: 1px dashed #000; margin: 6px 0; }
        .sep-solid { border-bottom: 2px solid #000; margin: 6px 0; }
        .right { text-align: right; }
        .row { display: flex; justify-content: space-between; }
        .row span { white-space: nowrap; }
        .right-col { text-align: right; }
        .small { font-size: 9px; color: #444; }
        .copy { display: inline-block; padding: 2px 4px; background: #000; color: #ffd3c7; font-size: 9px; font-weight: bold; margin-bottom: 6px; }
        .page-break { page-break-after: always; }
    </style>
</head>
<body>
    <div class="receipt">
        <div class="center">
            <div class="title">{{ $store['name'] ?? 'KasirKu' }}</div>
            @if ($store['address']) <div class="center small">{{ $store['address'] }}</div>@endif
            @if ($store['phone']) <div class="center small">{{ $store['phone'] }}</div>@endif
            @if ($isCopy) <div class="copy">SALINAN</div>@endif
        </div>

        <div class="sep"></div>

        <div class="row"><span>No.</span><span class="right-col">{{ $sale->invoice_number }}</span></div>
        <div class="row"><span>Tanggal</span><span class="right-col">{{ \Carbon\Carbon::parse($sale->created_at)->locale('id')->isoFormat('dddd, DD MMMM YYYY HH:mm') }}</span></div>
        <div class="row"><span>Kasir</span><span class="right-col">{{ optional($sale->cashier)->name }}</span></div>
        <div class="row"><span>Pelanggan</span><span class="right-col">{{ $sale->customer?->name ?? 'Umum' }}</span></div>

        <div class="sep"></div>

        <div class="row"><span>Produk</span><span class="right-col">Harga</span></div>
        <div class="row small"><span>Qty x Satuan</span><span class="right-col">Total</span></div>
        @foreach ($sale->items as $item)
            <div class="row">
                <span>{{ $item->name_snapshot }}</span>
                <span class="right-col">{{ $item->qty }} x Rp {{ number_format($item->unit_price, 0, ',', '.') }}</span>
            </div>
            <div class="row small">
                <span></span>
                <span class="right-col">Rp {{ number_format($item->line_total, 0, ',', '.') }}</span>
            </div>
            @if ($item->discount)
                <div class="row small"><span>Diskon</span><span class="right-col">-Rp {{ number_format($item->discount, 0, ',', '.') }}</span></div>
            @endif
        @endforeach

        <div class="sep-solid"></div>

        <div class="row bold"><span>Subtotal</span><span class="right-col">Rp {{ number_format($sale->subtotal, 0, ',', '.') }}</span></div>
        @if ($sale->discount_total)
            <div class="row bold"><span>Diskon</span><span class="right-col">-Rp {{ number_format($sale->discount_total, 0, ',', '.') }}</span></div>
        @endif
        <div class="row bold"><span>Pajak</span><span class="right-col">Rp {{ number_format($sale->tax_total, 0, ',', '.') }}</span></div>
        @if ($sale->rounding)
            <div class="row bold"><span>Pembulatan</span><span class="right-col">Rp {{ number_format($sale->rounding, 0, ',', '.') }}</span></div>
        @endif
        <div class="row bold sep-solid"><span>TOTAL</span><span class="right-col">Rp {{ number_format($sale->grand_total, 0, ',', '.') }}</span></div>

        <div class="sep"></div>

        @foreach ($sale->payments as $payment)
            <div class="row">
                <span>{{ optional($payment->paymentMethod)->name }}</span>
                <span class="right-col">Rp {{ number_format($payment->amount, 0, ',', '.') }}</span>
            </div>
        @endforeach
        <div class="row bold"><span>Kembalian</span><span class="right-col">Rp {{ number_format($sale->change_amount, 0, ',', '.') }}</span></div>

        <div class="sep"></div>

        <div class="center small">{{ $store['footer'] ?? 'Terima kasih telah berbelanja.' }}</div>
        <div class="center small">Dicetak {{ Carbon::now()->locale('id')->isoFormat('dddd, DD MMMM YYYY HH:mm') }}</div>
    </div>
</body>
</html>
