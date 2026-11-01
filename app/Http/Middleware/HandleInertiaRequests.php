<?php

namespace App\Http\Middleware;

use App\Models\Setting;
use Illuminate\Http\Request;
use Inertia\Middleware;

class HandleInertiaRequests extends Middleware
{
    /**
     * The root template that is loaded on the first page visit.
     *
     * @var string
     */
    protected $rootView = 'app';

    /**
     * Determine the current asset version.
     */
    public function version(Request $request): ?string
    {
        return parent::version($request);
    }

    /**
     * Define the props that are shared by default.
     *
     * @return array<string, mixed>
     */
    public function share(Request $request): array
    {
        $user = $request->user();

        return [
            ...parent::share($request),
            'auth' => [
                'user' => $user,
                'role_label' => $user?->role?->label(),
                'can' => [
                    'manage_master_data' => $user?->canManageMasterData() ?? false,
                    'operate_pos' => $user?->canOperatePos() ?? false,
                    'view_reports' => $user?->canViewReports() ?? false,
                    'approve' => $user?->canApprove() ?? false,
                    'manage_users' => $user?->canManageUsers() ?? false,
                    'manage_settings' => $user?->canManageSettings() ?? false,
                ],
            ],
            'store' => [
                'name' => Setting::get('store_name', 'KasirKu'),
                'address' => Setting::get('store_address', ''),
                'phone' => Setting::get('store_phone', ''),
            ],
            'flash' => [
                'success' => fn () => $request->session()->get('success'),
                'message' => fn () => $request->session()->get('message'),
                'error' => fn () => $request->session()->get('error'),
            ],
        ];
    }
}
