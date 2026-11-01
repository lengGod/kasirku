<?php

declare(strict_types=1);

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class StockInItem extends Model
{
    protected $fillable = ['stock_in_id', 'product_id', 'qty', 'cost_price', 'batch_number', 'expiry_date'];

    protected $casts = [
        'qty' => 'decimal:3',
        'cost_price' => 'decimal:2',
        'expiry_date' => 'date',
    ];

    public function stockIn(): BelongsTo
    {
        return $this->belongsTo(StockIn::class);
    }

    public function product(): BelongsTo
    {
        return $this->belongsTo(Product::class);
    }
}
