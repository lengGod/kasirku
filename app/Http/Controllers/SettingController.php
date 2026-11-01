<?php

declare(strict_types=1);

namespace App\Http\Controllers;

use App\Models\Setting;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Inertia\Inertia;
use Inertia\Response;

class SettingController extends Controller
{
    private const KEYS = [
        'store_name',
        'store_address',
        'store_phone',
        'receipt_footer',
        'tax_rate',
        'tax_included',
        'rounding_step',
        'max_discount_without_pin',
        'allow_negative_stock',
    ];

    public function edit(): Response
    {
        return Inertia::render('Settings/Store', [
            'settings' => collect(self::KEYS)->mapWithKeys(fn (string $key): array => [
                $key => Setting::get($key, ''),
            ])->all(),
        ]);
    }

    public function update(Request $request): RedirectResponse
    {
        $validated = $request->validate([
            'store_name' => ['required', 'string', 'max:255'],
            'store_address' => ['nullable', 'string', 'max:500'],
            'store_phone' => ['nullable', 'string', 'max:50'],
            'receipt_footer' => ['nullable', 'string', 'max:255'],
            'tax_rate' => ['nullable', 'numeric', 'min:0', 'max:100'],
            'tax_included' => ['boolean'],
            'rounding_step' => ['nullable', 'integer', 'min:0', 'max:10000'],
            'max_discount_without_pin' => ['nullable', 'numeric', 'min:0'],
            'allow_negative_stock' => ['boolean'],
        ]);

        foreach (self::KEYS as $key) {
            $value = $validated[$key] ?? null;

            if (in_array($key, ['tax_included', 'allow_negative_stock'], true)) {
                $value = $value ? '1' : '0';
            }

            Setting::put($key, $value === null ? '' : (string) $value);
        }

        return back()->with('success', 'Pengaturan toko berhasil disimpan.');
    }
}
