<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('held_sales', function (Blueprint $table) {
            $table->id();
            $table->foreignId('cashier_id')->nullable()->constrained('users')->nullOnDelete();
            $table->string('label');
            $table->longText('cart_json');
            $table->timestamps();
            $table->index(['cashier_id', 'created_at']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('held_sales');
    }
};
