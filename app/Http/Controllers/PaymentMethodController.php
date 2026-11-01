<?php

declare(strict_types=1);

namespace App\Http\Controllers;

use App\Enums\PaymentType;
use App\Models\PaymentMethod;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Inertia\Inertia;
use Inertia\Response;

class PaymentMethodController extends Controller
{
    public function index(): Response
    {
        return Inertia::render('PaymentMethods/Index', [
            'paymentMethods' => PaymentMethod::query()->orderBy('name')->paginate(15),
            'types' => collect(PaymentType::cases())->map(fn (PaymentType $type): array => [
                'value' => $type->value,
                'label' => $type->label(),
            ]),
        ]);
    }

    public function store(Request $request): RedirectResponse
    {
        $request->validate([
            'name' => ['required', 'string', 'max:100'],
            'type' => ['required', 'in:cash,qris,transfer,card,other'],
            'is_active' => ['boolean'],
        ]);

        PaymentMethod::create([
            'name' => $request->name,
            'type' => $request->type,
            'is_active' => (bool) ($request->is_active ?? true),
        ]);

        return back()->with('success', 'Metode pembayaran berhasil ditambahkan.');
    }

    public function update(Request $request, PaymentMethod $paymentMethod): RedirectResponse
    {
        $request->validate([
            'name' => ['required', 'string', 'max:100'],
            'type' => ['required', 'in:cash,qris,transfer,card,other'],
            'is_active' => ['boolean'],
        ]);

        $paymentMethod->update([
            'name' => $request->name,
            'type' => $request->type,
            'is_active' => (bool) ($request->is_active ?? true),
        ]);

        return back()->with('success', 'Metode pembayaran berhasil diperbarui.');
    }

    public function destroy(PaymentMethod $paymentMethod): RedirectResponse
    {
        if ($paymentMethod->payments()->exists()) {
            return back()->with('error', 'Metode pembayaran sudah digunakan transaksi.');
        }

        $paymentMethod->delete();

        return back()->with('success', 'Metode pembayaran berhasil dihapus.');
    }
}
