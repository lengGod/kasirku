<?php

declare(strict_types=1);

namespace App\Http\Controllers;

use App\Models\Unit;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Inertia\Inertia;
use Inertia\Response;

class UnitController extends Controller
{
    public function index(): Response
    {
        return Inertia::render('Units/Index', [
            'units' => Unit::query()->withCount('products')->orderBy('name')->paginate(15),
        ]);
    }

    public function store(Request $request): RedirectResponse
    {
        $request->validate([
            'name' => ['required', 'string', 'max:50'],
            'short_name' => ['required', 'string', 'max:10', 'unique:units'],
        ]);

        Unit::create($request->only(['name', 'short_name']));

        return back()->with('success', 'Satuan berhasil ditambahkan.');
    }

    public function update(Request $request, Unit $unit): RedirectResponse
    {
        $request->validate([
            'name' => ['required', 'string', 'max:50'],
            'short_name' => ['required', 'string', 'max:10', 'unique:units,short_name,'.$unit->id],
        ]);

        $unit->update($request->only(['name', 'short_name']));

        return back()->with('success', 'Satuan berhasil diperbarui.');
    }

    public function destroy(Unit $unit): RedirectResponse
    {
        if ($unit->products()->exists()) {
            return back()->with('error', 'Satuan masih digunakan oleh produk.');
        }

        $unit->delete();

        return back()->with('success', 'Satuan berhasil dihapus.');
    }
}
