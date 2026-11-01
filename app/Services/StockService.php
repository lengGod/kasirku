<?php

declare(strict_types=1);

namespace App\Services;

use App\Enums\MovementType;
use App\Models\Product;
use App\Models\Setting;
use App\Models\Stock;
use App\Models\StockMovement;
use Illuminate\Validation\ValidationException;

class StockService
{
    public function currentStock(Product $product): float
    {
        return (float) $product->stocks()->sum('quantity');
    }

    public function decrease(
        Product $product,
        float $qty,
        string $referenceType,
        int $referenceId,
        int $userId,
        ?string $note = null,
    ): void {
        if (! $product->track_stock) {
            return;
        }

        $stock = $this->lockedStock($product);
        $allowNegative = Setting::get('allow_negative_stock', '0') === '1';

        if (! $allowNegative && (float) $stock->quantity < $qty) {
            throw ValidationException::withMessages([
                'items' => "Stok {$product->name} tidak cukup. Tersedia ".number_format((float) $stock->quantity, 0, ',', '.').'.',
            ]);
        }

        $stock->quantity = (float) $stock->quantity - $qty;
        $stock->save();

        $this->record($product, -$qty, (float) $stock->quantity, MovementType::Sale, $referenceType, $referenceId, $userId, $note);
    }

    public function increase(
        Product $product,
        float $qty,
        string $referenceType,
        int $referenceId,
        int $userId,
        ?string $note = null,
        MovementType $type = MovementType::Refund,
    ): void {
        if (! $product->track_stock) {
            return;
        }

        $stock = $this->lockedStock($product);
        $stock->quantity = (float) $stock->quantity + $qty;
        $stock->save();

        $this->record($product, $qty, (float) $stock->quantity, $type, $referenceType, $referenceId, $userId, $note);
    }

    public function adjust(
        Product $product,
        float $qtyAfter,
        string $referenceType,
        int $referenceId,
        int $userId,
        ?string $note = null,
    ): float {
        $stock = $this->lockedStock($product);
        $before = (float) $stock->quantity;
        $difference = round($qtyAfter - $before, 3);

        if ($difference === 0.0) {
            return 0.0;
        }

        $stock->quantity = $qtyAfter;
        $stock->save();

        $this->record($product, $difference, $qtyAfter, MovementType::Adjust, $referenceType, $referenceId, $userId, $note);

        return $difference;
    }

    private function lockedStock(Product $product): Stock
    {
        $stock = Stock::query()
            ->where('product_id', $product->id)
            ->where('batch_key', 0)
            ->lockForUpdate()
            ->first();

        if (! $stock) {
            $stock = Stock::create([
                'product_id' => $product->id,
                'batch_key' => 0,
                'quantity' => 0,
            ]);
            $stock = Stock::query()->whereKey($stock->id)->lockForUpdate()->firstOrFail();
        }

        return $stock;
    }

    private function record(
        Product $product,
        float $qty,
        float $balanceAfter,
        MovementType $type,
        string $referenceType,
        int $referenceId,
        int $userId,
        ?string $note,
    ): void {
        StockMovement::create([
            'product_id' => $product->id,
            'created_by' => $userId,
            'type' => $type->value,
            'qty' => $qty,
            'balance_after' => $balanceAfter,
            'reference_type' => $referenceType,
            'reference_id' => $referenceId,
            'note' => $note,
            'created_at' => now(),
        ]);
    }
}
