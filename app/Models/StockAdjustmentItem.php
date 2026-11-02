<?php

declare(strict_types=1);

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class StockAdjustmentItem extends Model
{
    public $timestamps = false;

    protected $fillable = ['stock_adjustment_id', 'product_id', 'qty_before', 'qty_after', 'difference'];

    protected $casts = [
        'qty_before' => 'decimal:3',
        'qty_after' => 'decimal:3',
        'difference' => 'decimal:3',
    ];

    public function stockAdjustment(): BelongsTo
    {
        return $this->belongsTo(StockAdjustment::class);
    }

    public function product(): BelongsTo
    {
        return $this->belongsTo(Product::class);
    }
}
