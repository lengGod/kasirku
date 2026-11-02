@php
use Illuminate\Support\Carbon;
@endphp

<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="utf-8">
    <title>Label Harga</title>
    <style>
        @page {
            margin: 0;
            size: [60mm, 40mm];
        }
        body {
            font-family: "Courier New", monospace;
            font-size: 11px;
            line-height: 1.3;
            margin: 0;
            padding: 4px;
            color: #000;
        }
        .sheet { max-width: 200px; margin: 0 auto; }
        .labels { columns: 3; column-gap: 4px; }
        .label {
            break-inside: avoid;
            border: 2px solid #000;
            padding: 4px;
            margin-bottom: 6px;
            text-align: center;
        }
        .store { font-size: 8px; font-weight: bold; text-transform: uppercase; margin-bottom: 2px; }
        .barcode-img { margin: 0 auto 2px; max-width: 100%; height: auto; }
        .name { font-weight: bold; margin-bottom: 2px; }
        .price { font-weight: bold; font-size: 14px; }
        .sku { font-size: 9px; color: #444; }
        .page-break { page-break-after: always; }
    </style>
</head>
<body>
    <div class="sheet">
        <div class="labels">
            @foreach ($products as $product)
                @for ($i = 0; $i < $copies; $i++)
                    <div class="label">
                        <div class="store">{{ $store }}</div>
                        @if ($product->barcode)
                            <img src="{{ route('labels.barcode', $product->barcode) }}" class="barcode-img" alt="barcode">
                        @endif
                        <div class="name">{{ $product->name }}</div>
                        <div class="price">{{ number_format($product->sell_price, 0, ',', '.') }}</div>
                        <div class="sku">{{ $product->sku }}</div>
                    </div>
                @endfor
            @endforeach
        </div>
    </div>
</body>
</html>
