<script setup>
defineProps({
    title: { type: String, required: true },
    subtitle: { type: String, default: '' },
    eyebrow: { type: String, default: 'KasirKu' },
});
</script>

<template>
    <div class="mb-6 flex flex-col gap-4 sm:flex-row sm:items-end sm:justify-between">
        <div>
            <p class="mb-1 text-xs font-bold uppercase tracking-[0.2em] text-violet-text">{{ eyebrow }}</p>
            <h1 class="font-display text-3xl font-bold text-ink">{{ title }}</h1>
            <p v-if="subtitle" class="mt-1 max-w-2xl text-sm text-muted">{{ subtitle }}</p>
        </div>
        <div class="flex flex-wrap items-center gap-2">
            <slot name="actions" />
        </div>
    </div>
</template>