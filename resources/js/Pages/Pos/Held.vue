<script setup>
import AuthenticatedLayout from '@/Layouts/AuthenticatedLayout.vue';
import PageHeader from '@/Components/PageHeader.vue';
import { Head, router } from '@inertiajs/vue3';
import { Trash2, PlayCircle } from '@lucide/vue';

defineProps({ heldSales: Array });

const resume = (held) => {
    // Implement resume logic: post to POS with items/etc? Or redirect with params?
    // Keep simple: redirect back to pos with query? 
    // Wait, POS Index needs to load it. 
    // Simple way: store held in Session or database and retrieve.
    // Let's implement resume in PosController.
    router.post(route('pos.resume', held.id));
};
</script>

<template>
    <Head title="Bill Ditahan" />
    <AuthenticatedLayout>
        <div class="mx-auto max-w-7xl px-4 py-8 sm:px-6 lg:px-8">
            <PageHeader title="Bill Ditahan" subtitle="Daftar transaksi yang ditunda." />
            <div class="space-y-4">
                <div v-for="held in heldSales" :key="held.id" class="flex items-center justify-between border-2 border-ink bg-surface p-4 shadow-hard">
                    <div>
                        <p class="font-bold text-ink">{{ held.label }}</p>
                        <p class="text-xs text-muted">{{ new Date(held.created_at).toLocaleString('id-ID') }}</p>
                    </div>
                    <div class="flex gap-2">
                        <button class="flex items-center gap-2 border-2 border-ink px-4 py-2 text-sm font-semibold hover:bg-hi" @click="resume(held)">
                            <PlayCircle class="h-4 w-4" /> Lanjutkan
                        </button>
                        <button class="flex items-center gap-2 border-2 border-ink px-4 py-2 text-sm font-semibold text-bad-fg hover:bg-bad-bg" @click="router.delete(route('pos.held.destroy', held.id))">
                            <Trash2 class="h-4 w-4" /> Hapus
                        </button>
                    </div>
                </div>
            </div>
        </div>
    </AuthenticatedLayout>
</template>
