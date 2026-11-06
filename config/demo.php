<?php

declare(strict_types=1);

return [

    /*
    |--------------------------------------------------------------------------
    | Demo Auto Reset
    |--------------------------------------------------------------------------
    |
    | Ketika diaktifkan, database demo akan direset dan diisi ulang dengan
    | data seed secara otomatis sekali sehari. Karena InfinityFree tidak
    | menyediakan cron, reset dijalankan secara "lazy" pada request GET
    | pertama setelah jam yang ditentukan.
    |
    */

    'auto_reset' => (bool) env('DEMO_AUTO_RESET', false),

    'reset_hour' => (int) env('DEMO_RESET_HOUR', 0),

    'timezone' => env('DEMO_TIMEZONE', 'Asia/Jakarta'),

    'cache_key' => 'demo:last-reset-date',

    'attempt_key' => 'demo:last-reset-attempt',

    'attempt_cooldown_minutes' => 60,

    'lock_key' => 'demo:reset-lock',

];
