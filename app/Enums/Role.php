<?php

declare(strict_types=1);

namespace App\Enums;

enum Role: string
{
    case Owner = 'owner';
    case Cashier = 'cashier';
    case Manager = 'manager';

    public function label(): string
    {
        return match ($this) {
            self::Owner => 'Owner / Admin',
            self::Cashier => 'Kasir',
            self::Manager => 'Manajer',
        };
    }

    public function canManageMasterData(): bool
    {
        return $this === self::Owner;
    }

    public function canOperatePos(): bool
    {
        return in_array($this, [self::Owner, self::Cashier], true);
    }

    public function canViewReports(): bool
    {
        return in_array($this, [self::Owner, self::Manager], true);
    }

    public function canManageUsers(): bool
    {
        return $this === self::Owner;
    }

    public function canApprove(): bool
    {
        return in_array($this, [self::Owner, self::Manager], true);
    }

    public function canManageSettings(): bool
    {
        return $this === self::Owner;
    }
}
