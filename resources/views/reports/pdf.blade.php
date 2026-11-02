@php
use Illuminate\Support\Carbon;
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
        .subtitle { font-size: 11px; color: #555; margin-bottom: 10px; }
        table { width: 100%; border-collapse: collapse; margin-top: 12px; }
        th { background: #14123A; color: #fff; text-align: left; padding: 6px 8px; font-size: 10px; text-transform: uppercase; }
        td { border-bottom: 1px solid #D5D7E6; padding: 5px 8px; font-size: 11px; }
        tr:nth-child(even) td { background: #F6F7FB; }
        .summary { margin-top: 16px; width: auto; float: right; }
        .summary td { text-align: right; }
        .summary tr td:first-child { text-align: left; width: 200px; }
    </style>
</head>
<body>
    <h1>{{ $title }}</h1>
    <div class="subtitle">{{ Carbon::now()->locale('id')->isoFormat('dddd, DD MMMM YYYY HH:mm') }}</div>

    <table>
        <thead>
            <tr>
                @foreach ($headers as $header)
                    <th>{{ $header }}</th>
                @endforeach
            </tr>
        </thead>
        <tbody>
            @foreach ($rows as $row)
                <tr>
                    @foreach ($row as $cell)
                        <td>{{ $cell }}</td>
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
                        <td>{{ is_numeric($value) ? number_format($value, 0, ',', '.') : $value }}</td>
                    </tr>
                @endforeach
            </tbody>
        </table>
    @endif
</body>
</html>
