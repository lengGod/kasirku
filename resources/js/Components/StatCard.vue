<script setup>
import { computed } from 'vue';

const props = defineProps({
    label: { type: String, required: true },
    value: { type: [String, Number], default: 0 },
    hint: { type: String, default: '' },
    tone: { type: String, default: 'surface' },
});

const tones = {
    surface: 'bg-surface text-ink',
    lime: 'bg-lime text-ink',
    violet: 'bg-violet-text text-white',
    dark: 'bg-ink text-white',
};

const toneClass = computed(() => tones[props.tone] ?? tones.surface);
</script>

<template>
    <div :class="['relative border-2 border-ink p-5 shadow-hard', toneClass]">
        <div class="mb-3 flex items-start justify-between gap-2">
            <p class="text-[11px] font-bold uppercase tracking-[0.15em] opacity-80">{{ label }}</p>
            <slot name="icon" />
        </div>
        <p class="font-display text-2xl font-bold leading-tight sm:text-3xl">{{ value }}</p>
        <p v-if="hint" class="mt-2 text-xs opacity-75">{{ hint }}</p>
    </div>
</template>