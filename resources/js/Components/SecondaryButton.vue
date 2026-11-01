<script setup>
import { Link } from '@inertiajs/vue3';
import { LoaderCircle } from '@lucide/vue';

defineProps({
    as: {
        type: String,
        default: 'button',
    },
    href: String,
    type: {
        type: String,
        default: 'button',
    },
    disabled: Boolean,
    loading: Boolean,
});
</script>

<template>
    <Link
        v-if="as === 'link'"
        :href="href"
        class="inline-flex items-center justify-center gap-2 h-12 px-6 text-sm font-semibold text-ink border-2 border-ink bg-transparent hover:bg-hi transition duration-150 ease-in-out focus:outline-lime focus:outline-3 focus:outline-offset-2"
    >
        <slot />
    </Link>
    <button
        v-else
        :type="type"
        :disabled="disabled || loading"
        class="inline-flex items-center justify-center gap-2 h-12 px-6 text-sm font-semibold text-ink border-2 border-ink bg-transparent hover:bg-hi transition duration-150 ease-in-out focus:outline-lime focus:outline-3 focus:outline-offset-2 disabled:opacity-50 disabled:cursor-not-allowed"
    >
        <LoaderCircle v-if="loading" class="w-4 h-4 animate-spin" />
        <slot />
    </button>
</template>