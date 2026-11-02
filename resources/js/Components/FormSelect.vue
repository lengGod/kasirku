<script setup>
const model = defineModel({ default: '' });

defineProps({
    required: { type: Boolean, default: false },
    disabled: { type: Boolean, default: false },
});
</script>

<template>
    <select
        v-model="model"
        :required="required"
        :disabled="disabled"
        class="h-12 w-full border-2 border-ink bg-surface px-4 text-sm text-ink focus:border-violet-text focus:outline-none disabled:bg-surface-2 disabled:opacity-60"
    >
        <slot />
    </select>
</template>