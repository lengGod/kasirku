@php
use Illuminate\Support\Carbon;

$numericHeaders = ['Qty', 'Qty Terjual', 'Jumlah Transaksi', 'Jumlah Pembayaran', 'Stok'];
$currencyHeaders = ['Penjualan', 'HPP', 'Laba', 'Total', 'Total Penjualan', 'Selisih', 'Modal', 'Ekspektasi', 'Aktual', 'Nilai Stok', 'Harga Beli'];
@endphp

<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="utf-8">
    <title>{{ $title }}</title>
    <style>
        @page { margin: 12mm; size: A4; }
        body { font-family: sans-serif; font-size: 12px; color: #111; line-height: 1.4; }
        h1 { font-size: 18px; margin-bottom: 2px; text-transform: uppercase; letter-spacing: 0.05em; }
        .store { font-size: 13px; font-weight: bold; margin-bottom: 2px; }
        .subtitle { font-size: 11px; color: #555; margin-bottom: 10px; }
        table { width: 100%; border-collapse: collapse; margin-top: 12px; }
        th { background: #14123A; color: #fff; text-align: left; padding: 6px 8px; font-size: 10px; text-transform: uppercase; }
        th.numeric, td.numeric { text-align: right; }
        td { border-bottom: 1px solid #D5D7E6; padding: 5px 8px; font-size: 11px; }
        tr:nth-child(even) td { background: #F6F7FB; }
        .summary { margin-top: 16px; width: auto; float: right; }
        .summary td { text-align: right; }
        .summary tr td:first-child { text-align: left; width: 200px; }
    </style>
</head>
<body>
    <div class="store">{{ $store }}</div>
    <h1>{{ $title }}</h1>
    <div class="subtitle">{{ Carbon::now()->locale('id')->isoFormat('dddd, DD MMMM YYYY HH:mm') }}</div>

    <table>
        <thead>
            <tr>
                @foreach ($headers as $header)
                    <th class="{{ in_array($header, array_merge($numericHeaders, $currencyHeaders), true) ? 'numeric' : '' }}">{{ $header }}</th>
                @endforeach
            </tr>
        </thead>
        <tbody>
            @foreach ($rows as $row)
                <tr>
                    @foreach ($row as $index => $cell)
                        <td class="{{ in_array($headers[$index] ?? '', array_merge($numericHeaders, $currencyHeaders), true) ? 'numeric' : '' }}">
                            @if (in_array($headers[$index] ?? '', $currencyHeaders, true) && is_numeric($cell))
                                Rp {{ number_format((float) $cell, 0, ',', '.') }}
                            @else
                                {{ $cell }}
                            @endif
                        </td>
                    @endforeach
                </tr>
            @endforeach
        </tbody>
    </table>

    @if ($summary)
        <table class="summary">
            <tbody>
                @foreach ($summary as $key => $value)
                    <tr>
                        <td>{{ $key }}</td>
                        <td>{{ is_numeric($value) ? (in_array($key, ['total', 'penjualan', 'laba', 'nilai', 'selisih'], true) ? 'Rp '.number_format($value, 0, ',', '.') : number_format($value, 0, ',', '.')) : $value }}</td>
                    </tr>
                @endforeach
            </tbody>
        </table>
    @endif
</body>
</html>
