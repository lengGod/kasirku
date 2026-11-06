<?php

declare(strict_types=1);

namespace App\Http\Controllers;

use App\Enums\CashMovementType;
use App\Enums\SaleStatus;
use App\Enums\ShiftStatus;
use App\Models\Shift;
use App\Services\ShiftService;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Inertia\Inertia;
use Inertia\Response;

class ShiftController extends Controller
{
    public function index(Request $request, ShiftService $shifts): Response
    {
        $user = $request->user();
        $query = Shift::query()
            ->with('user')
            ->withCount(['sales as sales_count' => fn ($query) => $query->where('status', '!=', SaleStatus::Voided->value)])
            ->withSum(['sales as sales_total' => fn ($query) => $query->where('status', '!=', SaleStatus::Voided->value)], 'grand_total')
            ->latest('opened_at');

        if (! $user->canViewReports()) {
            $query->where('user_id', $user->id);
        }

        return Inertia::render('Shifts/Index', [
            'shifts' => $query->paginate(15)->withQueryString(),
            'openShift' => $shifts->openShiftFor($user),
        ]);
    }

    public function open(Request $request, ShiftService $shifts): Response|RedirectResponse
    {
        if ($shifts->openShiftFor($request->user())) {
            return redirect()->route('pos.index');
        }

        return Inertia::render('Shifts/Open');
    }

    public function storeOpen(Request $request, ShiftService $shifts): RedirectResponse
    {
        $validated = $request->validate([
            'opening_cash' => ['required', 'numeric', 'min:0'],
        ]);

        $shift = $shifts->open($request->user(), (float) $validated['opening_cash']);

        return redirect()
            ->route('pos.index')
            ->with('success', 'Shift dibuka dengan modal awal Rp '.number_format((float) $shift->opening_cash, 0, ',', '.').'.');
    }

    public function close(Request $request, ShiftService $shifts): Response|RedirectResponse
    {
        $shift = $shifts->openShiftFor($request->user());

        if (! $shift) {
            return redirect()->route('shifts.index')->with('error', 'Tidak ada shift terbuka.');
        }

        return Inertia::render('Shifts/Close', [
            'shift' => $shift,
            'summary' => $shifts->summary($shift),
        ]);
    }

    public function storeClose(Request $request, ShiftService $shifts): RedirectResponse
    {
        $validated = $request->validate([
            'actual_cash' => ['required', 'numeric', 'min:0'],
        ]);

        $shift = $shifts->openShiftFor($request->user());
        abort_unless($shift, 404);

        $closed = $shifts->close($shift, (float) $validated['actual_cash']);

        return redirect()
            ->route('shifts.show', $closed)
            ->with('success', 'Shift ditutup. Selisih kas Rp '.number_format((float) $closed->difference, 0, ',', '.').'.');
    }

    public function show(Shift $shift, ShiftService $shifts): Response
    {
        $shift->load(['user', 'sales.customer', 'cashMovements.user', 'refunds']);

        return Inertia::render('Shifts/Show', [
            'shift' => $shift,
            'summary' => $shifts->summary($shift),
            'statuses' => SaleStatus::options(),
        ]);
    }

    public function cashMovement(Request $request, Shift $shift, ShiftService $shifts): RedirectResponse
    {
        abort_unless($shift->status === ShiftStatus::Open, 403);

        $validated = $request->validate([
            'type' => ['required', 'in:in,out'],
            'amount' => ['required', 'numeric', 'gt:0'],
            'reason' => ['required', 'string', 'max:255'],
        ]);

        $shifts->recordCashMovement(
            $shift,
            CashMovementType::from($validated['type']),
            (float) $validated['amount'],
            $validated['reason'],
            $request->user(),
        );

        return back()->with('success', 'Kas masuk/keluar dicatat.');
    }
}
