<?php

use App\Http\Controllers\CategoryController;
use App\Http\Controllers\CustomerController;
use App\Http\Controllers\DashboardController;
use App\Http\Controllers\LabelController;
use App\Http\Controllers\PaymentMethodController;
use App\Http\Controllers\PosController;
use App\Http\Controllers\ProductController;
use App\Http\Controllers\ProfileController;
use App\Http\Controllers\PromotionController;
use App\Http\Controllers\RefundController;
use App\Http\Controllers\ReportController;
use App\Http\Controllers\SaleController;
use App\Http\Controllers\SettingController;
use App\Http\Controllers\ShiftController;
use App\Http\Controllers\StockController;
use App\Http\Controllers\UnitController;
use App\Http\Controllers\UserController;
use Illuminate\Support\Facades\Route;

Route::get('/', function () {
    return redirect('/dashboard');
});

Route::get('/dashboard', [DashboardController::class, 'index'])->middleware(['auth', 'verified'])->name('dashboard');
Route::get('/dashboard/search', [DashboardController::class, 'search'])->middleware(['auth', 'verified'])->name('dashboard.search');

Route::middleware('auth')->group(function () {
    // Layar Kasir (POS)
    Route::prefix('pos')->name('pos.')->group(function () {
        Route::get('/', [PosController::class, 'index'])->name('index');
        Route::get('search', [PosController::class, 'search'])->name('search');
        Route::get('lookup', [PosController::class, 'lookup'])->name('lookup');
        Route::post('checkout', [PosController::class, 'checkout'])->name('checkout');
        Route::get('held', [PosController::class, 'held'])->name('held');
        Route::post('hold', [PosController::class, 'hold'])->name('hold');
        Route::post('held/{heldSale}/resume', [PosController::class, 'resume'])->name('resume');
        Route::delete('held/{heldSale}', [PosController::class, 'destroyHeld'])->name('held.destroy');
    });

    // Shift Kasir
    Route::prefix('shifts')->name('shifts.')->group(function () {
        Route::get('/', [ShiftController::class, 'index'])->name('index');
        Route::get('open', [ShiftController::class, 'open'])->name('open');
        Route::post('open', [ShiftController::class, 'storeOpen'])->name('store-open');
        Route::get('close', [ShiftController::class, 'close'])->name('close');
        Route::post('close', [ShiftController::class, 'storeClose'])->name('store-close');
        Route::get('{shift}', [ShiftController::class, 'show'])->name('show');
        Route::post('{shift}/movement', [ShiftController::class, 'cashMovement'])->name('movement');
    });

    // Master Data
    Route::resource('products', ProductController::class)
        ->middlewareFor(['create', 'store', 'edit', 'update', 'destroy'], 'role:owner');
    Route::resource('categories', CategoryController::class)
        ->except(['create', 'edit', 'show'])
        ->middlewareFor(['store', 'update', 'destroy'], 'role:owner');
    Route::resource('units', UnitController::class)
        ->except(['create', 'edit', 'show'])
        ->middlewareFor(['store', 'update', 'destroy'], 'role:owner');
    Route::resource('customers', CustomerController::class)
        ->except(['create', 'edit', 'show'])
        ->middlewareFor(['store', 'update', 'destroy'], 'role:owner');
    Route::resource('payment-methods', PaymentMethodController::class)
        ->except(['create', 'edit', 'show'])
        ->middlewareFor(['store', 'update', 'destroy'], 'role:owner');
    Route::resource('promotions', PromotionController::class)
        ->except(['create', 'edit', 'show'])
        ->middlewareFor(['store', 'update', 'destroy'], 'role:owner');

    // Penjualan & Retur
    Route::prefix('sales')->name('sales.')->group(function () {
        Route::get('/', [SaleController::class, 'index'])->name('index');
        Route::get('{sale}', [SaleController::class, 'show'])->name('show');
        Route::get('{sale}/receipt', [SaleController::class, 'receipt'])->name('receipt');
        Route::get('{sale}/pdf', [SaleController::class, 'pdf'])->name('pdf');
        Route::post('{sale}/print-log', [SaleController::class, 'printLog'])->name('print-log');
        Route::post('{sale}/void', [SaleController::class, 'void'])->name('void');
    });

    Route::prefix('refunds')->name('refunds.')->group(function () {
        Route::get('/', [RefundController::class, 'index'])->name('index');
        Route::get('create', [RefundController::class, 'create'])->name('create');
        Route::post('store', [RefundController::class, 'store'])->name('store');
        Route::get('{refund}', [RefundController::class, 'show'])->name('show');
    });

    // Stok Pendukung
    Route::prefix('stock')->name('stock.')->group(function () {
        Route::get('receive', [StockController::class, 'receiveIndex'])->name('receive.index');
        Route::get('receive/create', [StockController::class, 'receiveCreate'])->name('receive.create');
        Route::post('receive', [StockController::class, 'receiveStore'])->name('receive.store');
        Route::get('adjust', [StockController::class, 'adjustIndex'])->name('adjust.index');
        Route::get('adjust/create', [StockController::class, 'adjustCreate'])->name('adjust.create');
        Route::post('adjust', [StockController::class, 'adjustStore'])->name('adjust.store');
        Route::get('movements', [StockController::class, 'movements'])->name('movements');
    });

    // Label Barcode
    Route::prefix('labels')->name('labels.')->group(function () {
        Route::get('/', [LabelController::class, 'index'])->name('index');
        Route::get('barcode/{code}', [LabelController::class, 'barcode'])
            ->where('code', '[A-Za-z0-9\-_.]+')
            ->name('barcode');
        Route::match(['get', 'post'], 'print', [LabelController::class, 'printLabels'])->name('print');
    });

    // Laporan
    Route::prefix('reports')->name('reports.')->middleware('role:owner,manager')->group(function () {
        Route::get('/', [ReportController::class, 'index'])->name('index');
        Route::get('{type}/export', [ReportController::class, 'export'])->name('export');
        Route::get('{type}/pdf', [ReportController::class, 'pdf'])->name('pdf');
        Route::get('{type}', [ReportController::class, 'index'])->name('show');
    });

    // Pengguna & Pengaturan
    Route::middleware('role:owner')->group(function () {
        // Route::resource('users', UserController::class)->except(['show', 'destroy']);
        Route::get('settings/store', [SettingController::class, 'edit'])->name('settings.store');
        Route::put('settings/store', [SettingController::class, 'update'])->name('settings.store.update');
    });

    // Profil
    // Route::get('profile', [ProfileController::class, 'edit'])->name('profile.edit');
    // Route::patch('profile', [ProfileController::class, 'update'])->name('profile.update');
    // Route::delete('profile', [ProfileController::class, 'destroy'])->name('profile.destroy');
});

require __DIR__.'/auth.php';
