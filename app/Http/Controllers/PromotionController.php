<?php

declare(strict_types=1);

namespace App\Http\Controllers;

use App\Models\Promotion;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Inertia\Inertia;
use Inertia\Response;

class PromotionController extends Controller
{
    public function index(): Response
    {
        return Inertia::render('Promotions/Index', [
            'promotions' => Promotion::query()->orderBy('name')->paginate(15),
        ]);
    }

    public function store(Request $request): RedirectResponse
    {
        $request->validate([
            'name' => ['required', 'string', 'max:100'],
            'type' => ['required', 'in:percentage,nominal'],
            'value' => ['required', 'numeric', 'min:0'],
            'target' => ['required', 'in:product,category'],
            'target_id' => ['nullable', 'exists:products,id'],
            'category_id' => ['nullable', 'exists:categories,id'],
            'start_at' => ['nullable', 'date'],
            'end_at' => ['nullable', 'date', 'after_or_equal:start_at'],
            'is_active' => ['boolean'],
        ]);

        Promotion::create($request->only([
            'name', 'type', 'value', 'target', 'target_id', 'category_id', 'start_at', 'end_at', 'is_active',
        ]) + ['is_active' => (bool) ($request->is_active ?? true)]);

        return back()->with('success', 'Promo berhasil ditambahkan.');
    }

    public function update(Request $request, Promotion $promotion): RedirectResponse
    {
        $request->validate([
            'name' => ['required', 'string', 'max:100'],
            'type' => ['required', 'in:percentage,nominal'],
            'value' => ['required', 'numeric', 'min:0'],
            'target' => ['required', 'in:product,category'],
            'target_id' => ['nullable', 'exists:products,id'],
            'category_id' => ['nullable', 'exists:categories,id'],
            'start_at' => ['nullable', 'date'],
            'end_at' => ['nullable', 'date', 'after_or_equal:start_at'],
            'is_active' => ['boolean'],
        ]);

        $promotion->update($request->only([
            'name', 'type', 'value', 'target', 'target_id', 'category_id', 'start_at', 'end_at', 'is_active',
        ]));

        return back()->with('success', 'Promo berhasil diperbarui.');
    }

    public function destroy(Promotion $promotion): RedirectResponse
    {
        $promotion->delete();

        return back()->with('success', 'Promo berhasil dihapus.');
    }
}
