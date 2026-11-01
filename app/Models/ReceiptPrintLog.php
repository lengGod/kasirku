<?php

declare(strict_types=1);

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class ReceiptPrintLog extends Model
{
    protected $fillable = ['sale_id', 'printed_by', 'is_copy'];

    protected $casts = [
        'is_copy' => 'bool',
    ];

    public function sale(): BelongsTo
    {
        return $this->belongsTo(Sale::class);
    }

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class, 'printed_by');
    }
}
