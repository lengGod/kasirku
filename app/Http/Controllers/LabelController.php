<?php

declare(strict_types=1);

namespace App\Http\Controllers;

use App\Models\Product;
use App\Models\Setting;
use Barryvdh\DomPDF\Facade\Pdf;
use Illuminate\Http\Request;
use Illuminate\Http\Response;
use Inertia\Inertia;
use Picqer\Barcode\BarcodeGeneratorPNG;

class LabelController extends Controller
{
    public function index(): Response
    {
        return Inertia::render('Labels/Index', [
            'products' => Product::query()
                ->with('unit')
                ->where('is_active', true)
                ->orderBy('name')
                ->get(),
            'store' => [
                'name' => Setting::get('store_name', 'KasirKu'),
            ],
        ]);
    }

    public function barcode(string $code): Response
    {
        $generator = new BarcodeGeneratorPNG();
        $png = $generator->getBarcode($code, $generator::TYPE_CODE_128, 2, 50);

        return response($png, 200, ['Content-Type' => 'image/png']);
    }

    public function printLabels(Request $request)
    {
        $validated = $request->validate([
            'product_ids' => ['required', 'array', 'min:1'],
            'product_ids.*' => ['exists:products,id'],
            'copies' => ['nullable', 'integer', 'min:1', 'max:100'],
        ]);

        $products = Product::query()
            ->with('unit')
            ->whereIn('id', $validated['product_ids'])
            ->orderBy('name')
            ->get();

        $copies = (int) ($validated['copies'] ?? 1);

        if ($request->query('format') === 'pdf') {
            return Pdf::loadView('labels.pdf', [
                'products' => $products,
                'copies' => $copies,
                'store' => Setting::get('store_name', 'KasirKu'),
            ])->setPaper('a4')->download('label-harga.pdf');
        }

        return Inertia::render('Labels/Print', [
            'products' => $products,
            'copies' => $copies,
            'store' => Setting::get('store_name', 'KasirKu'),
        ]);
    }
}
