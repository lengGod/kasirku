<?php

namespace Tests\Feature\Http\Middleware;

use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Carbon;
use Illuminate\Support\Facades\Artisan;
use Illuminate\Support\Facades\Cache;
use Tests\TestCase;

class AutoResetDemoDatabaseTest extends TestCase
{
    use RefreshDatabase;

    public function test_reset_command_is_called_on_first_request_after_reset_hour(): void
    {
        config([
            'demo.auto_reset' => true,
            'demo.reset_hour' => 0,
            'demo.timezone' => 'Asia/Jakarta',
        ]);

        Cache::flush();
        $this->travelTo(Carbon::parse('2026-01-01 01:00:00', 'Asia/Jakarta'));
        Artisan::spy();

        $this->get('/login')->assertOk();

        Artisan::shouldHaveReceived('call')
            ->once()
            ->with('demo:reset', ['--force' => true]);
    }

    public function test_reset_command_is_not_called_before_reset_hour(): void
    {
        config([
            'demo.auto_reset' => true,
            'demo.reset_hour' => 3,
            'demo.timezone' => 'Asia/Jakarta',
        ]);

        Cache::flush();
        $this->travelTo(Carbon::parse('2026-01-01 01:00:00', 'Asia/Jakarta'));
        Artisan::spy();

        $this->get('/login')->assertOk();

        Artisan::shouldNotHaveReceived('call');
    }

    public function test_reset_command_is_not_called_when_auto_reset_is_disabled(): void
    {
        config(['demo.auto_reset' => false]);

        Cache::flush();
        Artisan::spy();

        $this->get('/login')->assertOk();

        Artisan::shouldNotHaveReceived('call');
    }

    public function test_reset_command_is_not_called_when_previous_attempt_is_within_cooldown(): void
    {
        config([
            'demo.auto_reset' => true,
            'demo.reset_hour' => 0,
            'demo.timezone' => 'Asia/Jakarta',
        ]);

        Cache::flush();
        $this->travelTo(Carbon::parse('2026-01-01 01:00:00', 'Asia/Jakarta'));
        Cache::put(config('demo.attempt_key'), now()->getTimestamp(), now()->addDay());
        Artisan::spy();

        $this->get('/login')->assertOk();

        Artisan::shouldNotHaveReceived('call');
    }
}
