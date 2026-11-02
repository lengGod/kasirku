<?php

declare(strict_types=1);

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class RefundItem extends Model
{
    public $timestamps = false;

    protected $fillable = ['refund_id', 'sale_item_id', 'qty', 'amount', 'restock'];

    protected $casts = [
        'qty' => 'decimal:3',
        'amount' => 'decimal:2',
        'restock' => 'bool',
    ];

    public function refund(): BelongsTo
    {
        return $this->belongsTo(Refund::class);
    }

    public function saleItem(): BelongsTo
    {
        return $this->belongsTo(SaleItem::class);
    }
}
