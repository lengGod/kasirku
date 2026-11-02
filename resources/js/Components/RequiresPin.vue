<script setup>
import { Link } from '@inertiajs/vue3';
import { ShieldCheck } from '@lucide/vue';

export default {
    props: {
        can: { type: Boolean, default: false },
    },
};
</script>

<template>
    <div v-if="can" class="text-xs font-bold text-violet-text mt-1 flex items-center gap-1">
        <ShieldCheck class="h-3 w-3" /> Hanya bisa dilakukan oleh supervisor (PIN)
    </div>
</template>