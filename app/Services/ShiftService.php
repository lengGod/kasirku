<?php

declare(strict_types=1);

namespace App\Services;

use App\Enums\CashMovementType;
use App\Enums\PaymentType;
use App\Enums\ShiftStatus;
use App\Models\CashMovement;
use App\Models\PaymentMethod;
use App\Models\Sale;
use App\Models\SalePayment;
use App\Models\Shift;
use App\Models\User;
use Illuminate\Support\Facades\DB;
use Illuminate\Validation\ValidationException;

class ShiftService
{
    public function open(User $user, float $openingCash): Shift
    {
        $alreadyOpen = Shift::query()
            ->where('user_id', $user->id)
            ->where('status', ShiftStatus::Open->value)
            ->exists();

        if ($alreadyOpen) {
            throw ValidationException::withMessages([
                'shift' => 'Anda masih memiliki shift terbuka. Tutup shift terlebih dahulu.',
            ]);
        }

        return Shift::create([
            'user_id' => $user->id,
            'opened_at' => now(),
            'opening_cash' => $openingCash,
            'status' => ShiftStatus::Open->value,
        ]);
    }

    public function expectedCash(Shift $shift): float
    {
        $cashMethodIds = PaymentMethod::query()
            ->where('type', PaymentType::Cash->value)
            ->pluck('id');

        $cashSales = SalePayment::query()
            ->whereIn('payment_method_id', $cashMethodIds)
            ->whereHas('sale', function ($query) use ($shift): void {
                $query->where('shift_id', $shift->id)->where('status', '!=', 'voided');
            })
            ->sum('amount');

        $cashRefunds = $shift->refunds()->sum('total');

        $cashIn = $shift->cashMovements()->where('type', CashMovementType::In->value)->sum('amount');
        $cashOut = $shift->cashMovements()->where('type', CashMovementType::Out->value)->sum('amount');

        return round(
            (float) $shift->opening_cash + (float) $cashSales - (float) $cashRefunds + (float) $cashIn - (float) $cashOut,
            2,
        );
    }

    public function close(Shift $shift, float $actualCash): Shift
    {
        if ($shift->status !== ShiftStatus::Open) {
            throw ValidationException::withMessages(['shift' => 'Shift ini sudah ditutup.']);
        }

        $expected = $this->expectedCash($shift);

        $shift->update([
            'closed_at' => now(),
            'expected_cash' => $expected,
            'actual_cash' => $actualCash,
            'difference' => round($actualCash - $expected, 2),
            'status' => ShiftStatus::Closed->value,
        ]);

        return $shift->fresh();
    }

    public function recordCashMovement(Shift $shift, CashMovementType $type, float $amount, string $reason, User $user): CashMovement
    {
        if ($shift->status !== ShiftStatus::Open) {
            throw ValidationException::withMessages(['shift' => 'Shift sudah ditutup.']);
        }

        return CashMovement::create([
            'shift_id' => $shift->id,
            'type' => $type->value,
            'amount' => $amount,
            'reason' => $reason,
            'created_by' => $user->id,
        ]);
    }

    public function openShiftFor(User $user): ?Shift
    {
        return Shift::query()
            ->where('user_id', $user->id)
            ->where('status', ShiftStatus::Open->value)
            ->latest('opened_at')
            ->first();
    }

    public function summary(Shift $shift): array
    {
        $sales = Sale::query()
            ->where('shift_id', $shift->id)
            ->where('status', '!=', 'voided');

        $byMethod = DB::table('sale_payments')
            ->join('sales', 'sales.id', '=', 'sale_payments.sale_id')
            ->join('payment_methods', 'payment_methods.id', '=', 'sale_payments.payment_method_id')
            ->where('sales.shift_id', $shift->id)
            ->where('sales.status', '!=', 'voided')
            ->groupBy('payment_methods.name')
            ->selectRaw('payment_methods.name, SUM(sale_payments.amount) as total')
            ->get();

        return [
            'transaction_count' => $sales->count(),
            'sales_total' => round((float) $sales->sum('grand_total'), 2),
            'expected_cash' => $this->expectedCash($shift),
            'by_method' => $byMethod,
        ];
    }
}
