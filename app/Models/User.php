<?php

namespace App\Models;

// use Illuminate\Contracts\Auth\MustVerifyEmail;
use App\Enums\Role;
use Database\Factories\UserFactory;
use Illuminate\Database\Eloquent\Attributes\Fillable;
use Illuminate\Database\Eloquent\Attributes\Hidden;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;

#[Fillable(['name', 'email', 'password', 'role', 'pin_hash', 'is_active'])]
#[Hidden(['password', 'pin_hash', 'remember_token'])]
class User extends Authenticatable
{
    /** @use HasFactory<UserFactory> */
    use HasFactory, Notifiable;

    /**
     * Get the attributes that should be cast.
     *
     * @return array<string, string>
     */
    protected function casts(): array
    {
        return [
            'email_verified_at' => 'datetime',
            'password' => 'hashed',
            'role' => Role::class,
            'is_active' => 'boolean',
        ];
    }

    public function hasRole(Role|string ...$roles): bool
    {
        if (! $this->role instanceof Role) {
            return false;
        }

        foreach ($roles as $role) {
            $value = $role instanceof Role ? $role->value : $role;

            if ($this->role->value === $value) {
                return true;
            }
        }

        return false;
    }

    public function canManageMasterData(): bool
    {
        return $this->hasRole(Role::Owner);
    }

    public function canOperatePos(): bool
    {
        return $this->hasRole(Role::Owner, Role::Cashier);
    }

    public function canViewReports(): bool
    {
        return $this->hasRole(Role::Owner, Role::Manager);
    }

    public function canApprove(): bool
    {
        return $this->hasRole(Role::Owner, Role::Manager);
    }

    public function canManageUsers(): bool
    {
        return $this->hasRole(Role::Owner);
    }

    public function canManageSettings(): bool
    {
        return $this->hasRole(Role::Owner);
    }

    public function shifts(): HasMany
    {
        return $this->hasMany(Shift::class);
    }

    public function sales(): HasMany
    {
        return $this->hasMany(Sale::class, 'cashier_id');
    }
}
