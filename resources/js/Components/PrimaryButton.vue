<script setup>
import { Link } from '@inertiajs/vue3';
import { LoaderCircle } from '@lucide/vue';

defineProps({
    as: {
        type: String,
        default: 'button',
    },
    href: String,
    disabled: Boolean,
    loading: Boolean,
});
</script>

<template>
    <Link
        v-if="as === 'link'"
        :href="href"
        class="inline-flex items-center justify-center gap-2 h-12 px-6 text-sm font-semibold text-white bg-ink hover:bg-ink-3 transition duration-150 ease-in-out focus:outline-lime focus:outline-3 focus:outline-offset-2 active:bg-ink"
    >
        <slot />
    </Link>
    <button
        v-else
        :disabled="disabled || loading"
        class="inline-flex items-center justify-center gap-2 h-12 px-6 text-sm font-semibold text-white bg-ink hover:bg-ink-3 transition duration-150 ease-in-out focus:outline-lime focus:outline-3 focus:outline-offset-2 active:bg-ink disabled:opacity-50 disabled:cursor-not-allowed"
    >
        <LoaderCircle v-if="loading" class="w-4 h-4 animate-spin" />
        <slot />
    </button>
</template>