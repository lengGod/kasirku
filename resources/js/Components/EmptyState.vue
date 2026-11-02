<script setup>
import { Inbox } from '@lucide/vue';

defineProps({
    title: { type: String, default: 'Belum ada data' },
    message: { type: String, default: 'Data akan muncul di sini setelah dibuat.' },
});
</script>

<template>
    <div class="flex flex-col items-center justify-center border-2 border-dashed border-line bg-surface-2 px-6 py-12 text-center">
        <div class="mb-3 flex h-12 w-12 items-center justify-center border-2 border-ink bg-lime">
            <Inbox class="h-6 w-6 text-ink" />
        </div>
        <p class="font-display text-lg font-bold text-ink">{{ title }}</p>
        <p class="mt-1 max-w-sm text-sm text-muted">{{ message }}</p>
        <div class="mt-4">
            <slot />
        </div>
    </div>
</template>