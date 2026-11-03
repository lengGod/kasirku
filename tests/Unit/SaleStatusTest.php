<?php

namespace Tests\Unit;

use App\Enums\SaleStatus;
use PHPUnit\Framework\TestCase;

class SaleStatusTest extends TestCase
{
    public function test_sale_status_labels_are_in_indonesian(): void
    {
        $this->assertSame('Lunas', SaleStatus::Paid->label());
        $this->assertSame('Void', SaleStatus::Voided->label());
        $this->assertSame('Retur Penuh', SaleStatus::Refunded->label());
        $this->assertSame('Retur Sebagian', SaleStatus::PartialRefund->label());
    }

    public function test_sale_status_options_include_value_and_label(): void
    {
        $this->assertSame([
            ['value' => 'paid', 'label' => 'Lunas'],
            ['value' => 'voided', 'label' => 'Void'],
            ['value' => 'refunded', 'label' => 'Retur Penuh'],
            ['value' => 'partial_refund', 'label' => 'Retur Sebagian'],
        ], SaleStatus::options());
    }
}
