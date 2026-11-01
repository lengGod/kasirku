<?php

declare(strict_types=1);

namespace App\Enums;

enum CashMovementType: string
{
    case In = 'in';
    case Out = 'out';

    public function label(): string
    {
        return match ($this) {
            self::In => 'Kas Masuk',
            self::Out => 'Kas Keluar',
        };
    }
}
