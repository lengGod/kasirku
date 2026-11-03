<script setup>
import { computed } from 'vue';

const props = defineProps({
    tone: {
        type: String,
        default: 'surface',
    },
});

const tones = {
    surface: 'bg-surface',
    'surface-2': 'bg-surface-2',
    canvas: 'bg-canvas',
    lime: 'bg-lime',
    'lime-soft': 'bg-lime/15',
    violet: 'bg-violet-text',
    'violet-soft': 'bg-violet-text/10',
    yellow: 'bg-yellow-400',
    'yellow-soft': 'bg-yellow-400/15',
    red: 'bg-red-400',
    'red-soft': 'bg-red-400/15',
};

const toneClass = computed(() => tones[props.tone] ?? tones.surface);
</script>

<template>
    <div :class="['relative min-w-0 border-2 border-ink p-4 sm:p-6', toneClass]">
        <slot />
    </div>
</template>
