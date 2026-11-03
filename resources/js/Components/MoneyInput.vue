<script setup>
import { nextTick, ref, watch } from 'vue';
import { formatRupiah } from '@/Utils/format';

const model = defineModel({ type: [String, Number], default: '' });

defineProps({
    placeholder: { type: String, default: 'Rp 0' },
    required: { type: Boolean, default: false },
    disabled: { type: Boolean, default: false },
});

const input = ref(null);
const displayValue = ref('');

const rawValue = (value) => {
    if (value === null || value === undefined || value === '') {
        return '';
    }

    return String(value).replace(/[^\d]/g, '');
};

const setFormattedValue = (value) => {
    displayValue.value = value === null || value === undefined || value === ''
        ? ''
        : formatRupiah(value);
};

watch(model, (value) => {
    if (document.activeElement !== input.value) {
        setFormattedValue(value);
    }
}, { immediate: true });

const focusInput = async () => {
    displayValue.value = rawValue(model.value);
    await nextTick();
    input.value?.select();
};

const updateValue = (event) => {
    const raw = rawValue(event.target.value);
    displayValue.value = raw;
    model.value = raw === '' ? '' : Number(raw);
};

const blurInput = () => {
    setFormattedValue(model.value);
};
</script>

<template>
    <input
        ref="input"
        v-model="displayValue"
        type="text"
        inputmode="numeric"
        :placeholder="placeholder"
        :required="required"
        :disabled="disabled"
        class="h-12 w-full border-2 border-ink bg-surface px-4 text-sm text-ink placeholder:text-muted/60 focus:border-violet-text focus:outline-none disabled:bg-surface-2 disabled:opacity-60"
        @focus="focusInput"
        @input="updateValue"
        @blur="blurInput"
    />
</template>
