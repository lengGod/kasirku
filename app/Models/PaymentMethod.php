<?php

declare(strict_types=1);

namespace App\Models;

use App\Enums\PaymentType;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\HasMany;

class PaymentMethod extends Model
{
    protected $fillable = ['name', 'type', 'is_active'];

    protected $casts = [
        'type' => PaymentType::class,
        'is_active' => 'bool',
    ];

    public function payments(): HasMany
    {
        return $this->hasMany(SalePayment::class);
    }
}
