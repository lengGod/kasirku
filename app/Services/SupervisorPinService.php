<?php

declare(strict_types=1);

namespace App\Services;

use App\Enums\Role;
use App\Models\User;
use Illuminate\Support\Facades\Hash;
use Illuminate\Validation\ValidationException;

class SupervisorPinService
{
    public function verify(?string $pin): User
    {
        if (! $pin) {
            throw ValidationException::withMessages(['pin' => 'PIN supervisor wajib diisi.']);
        }

        $supervisors = User::query()
            ->whereIn('role', [Role::Owner->value, Role::Manager->value])
            ->whereNotNull('pin_hash')
            ->where('is_active', true)
            ->get();

        foreach ($supervisors as $supervisor) {
            if (Hash::check($pin, (string) $supervisor->pin_hash)) {
                return $supervisor;
            }
        }

        throw ValidationException::withMessages(['pin' => 'PIN supervisor tidak valid.']);
    }
}
