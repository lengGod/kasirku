<script setup>
import AuthenticatedLayout from '@/Layouts/AuthenticatedLayout.vue';
import PrimaryButton from '@/Components/PrimaryButton.vue';
import { Head } from '@inertiajs/vue3';
import { ShieldX } from '@lucide/vue';
</script>

<template>
    <Head title="Akses Ditolak" />

    <AuthenticatedLayout>
        <div class="bg-canvas min-h-screen flex items-center justify-center py-16 px-4">
            <div class="w-full max-w-lg bg-surface border-2 border-ink shadow-hard p-8 sm:p-10 text-center">
                <div class="w-16 h-16 mx-auto mb-6 bg-red-400/10 border-2 border-red-400 flex items-center justify-center">
                    <ShieldX class="w-8 h-8 text-red-400" />
                </div>

                <p class="text-xs font-bold uppercase tracking-[0.2em] text-red-400 mb-2">Error 403</p>
                <h1 class="text-display font-bold text-3xl text-ink mb-3">Akses Ditolak</h1>
                <p class="text-sm text-muted leading-relaxed mb-8">
                    Halaman ini tidak tersedia untuk peran akun Anda. Hubungi admin jika Anda membutuhkan akses tambahan.
                </p>

                <PrimaryButton as="link" :href="route('dashboard')" class="w-full sm:w-auto">
                    Kembali ke Dashboard
                </PrimaryButton>
            </div>
        </div>
    </AuthenticatedLayout>
</template>
