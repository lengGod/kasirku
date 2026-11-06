<?php

declare(strict_types=1);

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Artisan;
use Illuminate\Support\Facades\Cache;
use Illuminate\Support\Facades\Log;
use Symfony\Component\HttpFoundation\Response;
use Throwable;

class AutoResetDemoDatabase
{
    public function handle(Request $request, Closure $next): Response
    {
        if (! config('demo.auto_reset') || ! $request->isMethod('GET')) {
            return $next($request);
        }

        $now = now(config('demo.timezone'));
        $today = $now->toDateString();
        $resetMoment = $now->copy()->setTime((int) config('demo.reset_hour'), 0);

        $alreadyResetToday = Cache::get(config('demo.cache_key')) === $today;

        if ($alreadyResetToday || $now->lessThan($resetMoment)) {
            return $next($request);
        }

        $lastAttempt = (int) Cache::get(config('demo.attempt_key'), 0);
        $cooldown = (int) config('demo.attempt_cooldown_minutes') * 60;

        if ($lastAttempt > 0 && ($now->getTimestamp() - $lastAttempt) < $cooldown) {
            return $next($request);
        }

        if (! Cache::add(config('demo.lock_key'), true, now()->addMinutes(10))) {
            return $next($request);
        }

        try {
            Cache::put(config('demo.attempt_key'), $now->getTimestamp(), now()->addDay());

            @set_time_limit(0);
            @ignore_user_abort(true);

            Artisan::call('demo:reset', ['--force' => true]);

            Log::info('Demo database auto-reset berhasil dijalankan.');
        } catch (Throwable $exception) {
            report($exception);
        } finally {
            Cache::forget(config('demo.lock_key'));
        }

        return $next($request);
    }
}
