<script setup>
const model = defineModel({ type: [String, Number], default: '' });

defineProps({
    type: { type: String, default: 'text' },
    placeholder: { type: String, default: '' },
    min: { type: [String, Number], default: undefined },
    step: { type: [String, Number], default: undefined },
    required: { type: Boolean, default: false },
    disabled: { type: Boolean, default: false },
});
</script>

<template>
    <input
        v-model="model"
        :type="type"
        :placeholder="placeholder"
        :min="min"
        :step="step"
        :required="required"
        :disabled="disabled"
        class="h-12 w-full border-2 border-ink bg-surface px-4 text-sm text-ink placeholder:text-muted/60 focus:border-violet-text focus:outline-none disabled:bg-surface-2 disabled:opacity-60"
    />
</template>