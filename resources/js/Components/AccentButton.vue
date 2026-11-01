<script setup>
defineProps({
    type: {
        type: String,
        default: 'button',
    },
});
</script>

<template>
    <button
        :type="type"
        class="inline-flex items-center justify-center h-12 px-6 text-sm font-semibold text-ink bg-lime hover:bg-yellow-400 transition duration-150 ease-in-out focus:outline-lime focus:outline-3 focus:outline-offset-2 disabled:opacity-50 disabled:cursor-not-allowed"
    >
        <slot />
    </button>
</template>
