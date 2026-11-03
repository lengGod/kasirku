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
            self::Paid => 'Lunas',
            self::Voided => 'Void',
            self::Refunded => 'Retur Penuh',
            self::PartialRefund => 'Retur Sebagian',
        };
    }

    /**
     * @return array<int, array{value: string, label: string}>
     */
    public static function options(): array
    {
        return array_map(fn (self $status): array => [
            'value' => $status->value,
            'label' => $status->label(),
        ], self::cases());
    }
}
