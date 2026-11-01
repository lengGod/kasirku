<?php

declare(strict_types=1);

namespace App\Enums;

enum MovementType: string
{
    case Sale = 'sale';
    case Refund = 'refund';
    case In = 'in';
    case Adjust = 'adjust';

    public function label(): string
    {
        return match ($this) {
            self::Sale => 'Penjualan',
            self::Refund => 'Retur',
            self::In => 'Penerimaan',
            self::Adjust => 'Penyesuaian',
        };
    }
}
