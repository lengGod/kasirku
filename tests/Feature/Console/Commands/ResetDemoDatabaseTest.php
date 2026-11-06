<?php

namespace Tests\Feature\Console\Commands;

use Tests\TestCase;

class ResetDemoDatabaseTest extends TestCase
{
    public function test_reset_is_skipped_when_auto_reset_is_disabled(): void
    {
        config(['demo.auto_reset' => false]);

        $this->artisan('demo:reset')
            ->expectsOutputToContain('nonaktif')
            ->assertSuccessful();
    }
}
