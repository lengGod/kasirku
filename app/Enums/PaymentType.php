<?php

declare(strict_types=1);

namespace App\Enums;

enum PaymentType: string
{
    case Cash = 'cash';
    case Qris = 'qris';
    case Transfer = 'transfer';
    case Card = 'card';
    case Other = 'other';

    public function label(): string
    {
        return match ($this) {
            self::Cash => 'Tunai',
            self::Qris => 'QRIS',
            self::Transfer => 'Transfer',
            self::Card => 'Kartu',
            self::Other => 'Lainnya',
        };
    }
}
