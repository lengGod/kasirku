<?php

declare(strict_types=1);

namespace App\Services;

class PricingService
{
    /**
     * @param  array<int, array{product_id:int, name:string, qty:float, unit_price:float, cost_price:float, discount:float, is_taxable:bool}>  $lines
     * @return array{subtotal:float, item_discount_total:float, discount_total:float, tax_total:float, rounding:float, grand_total:float, lines:array<int, array<string, mixed>>}
     */
    public function calculate(
        array $lines,
        float $transactionDiscount = 0,
        bool $taxIncluded = false,
        float $taxRate = 0,
        int $roundingStep = 0,
    ): array {
        $subtotal = 0.0;
        $itemDiscountTotal = 0.0;
        $taxableBase = 0.0;

        foreach ($lines as $line) {
            $gross = round((float) $line['qty'] * (float) $line['unit_price'], 2);
            $discount = min(round((float) $line['discount'], 2), $gross);
            $net = max(0.0, $gross - $discount);

            $subtotal += $gross;
            $itemDiscountTotal += $discount;

            if ($line['is_taxable']) {
                $taxableBase += $net;
            }
        }

        $subtotal = round($subtotal, 2);
        $itemDiscountTotal = round($itemDiscountTotal, 2);
        $baseAfterItemDiscount = max(0.0, round($subtotal - $itemDiscountTotal, 2));
        $transactionDiscount = min(max(0.0, round($transactionDiscount, 2)), $baseAfterItemDiscount);

        $taxableRatio = $baseAfterItemDiscount > 0 ? min(1.0, $taxableBase / $baseAfterItemDiscount) : 0.0;
        $taxableAfterDiscount = max(0.0, round($taxableBase - ($transactionDiscount * $taxableRatio), 2));

        $taxTotal = $taxIncluded
            ? round($taxableAfterDiscount - ($taxableAfterDiscount / (1 + $taxRate)), 2)
            : round($taxableAfterDiscount * $taxRate, 2);

        $grandBeforeRounding = $baseAfterItemDiscount - $transactionDiscount;
        if (! $taxIncluded) {
            $grandBeforeRounding += $taxTotal;
        }
        $grandBeforeRounding = round($grandBeforeRounding, 2);

        $roundedGrand = $grandBeforeRounding;
        if ($roundingStep > 0) {
            $roundedGrand = round($grandBeforeRounding / $roundingStep) * $roundingStep;
        }
        $rounding = round($roundedGrand - $grandBeforeRounding, 2);

        $resultLines = [];
        foreach ($lines as $line) {
            $gross = round((float) $line['qty'] * (float) $line['unit_price'], 2);
            $discount = min(round((float) $line['discount'], 2), $gross);
            $net = max(0.0, $gross - $discount);
            $tax = 0.0;

            if ($line['is_taxable'] && $baseAfterItemDiscount > 0) {
                $share = $net / $baseAfterItemDiscount;
                $tax = round($taxTotal * $share, 2);
            }

            $resultLines[] = [
                ...$line,
                'gross' => $gross,
                'discount' => $discount,
                'tax' => $tax,
                'line_total' => $taxIncluded ? $net : round($net + $tax, 2),
            ];
        }

        return [
            'subtotal' => $subtotal,
            'item_discount_total' => $itemDiscountTotal,
            'discount_total' => round($itemDiscountTotal + $transactionDiscount, 2),
            'tax_total' => $taxTotal,
            'rounding' => $rounding,
            'grand_total' => round($roundedGrand, 2),
            'lines' => $resultLines,
        ];
    }
}
