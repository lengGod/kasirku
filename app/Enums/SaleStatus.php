<?php

declare(strict_types=1);

namespace App\Enums;

enum SaleStatus: string
{
    case Paid = 'paid';
    case Voided = 'voided';
    case Refunded = 'refunded';
    case PartialRefund = 'partial_refund';

    public function label(): string
    {
        return match ($this) {
            self::Paid => 'Dibayar',
            self::Voided => 'Void',
            self::Refunded => 'Retur Penuh',
            self::PartialRefund => 'Retur Sebagian',
        };
    }
}
