<script setup>
defineProps({
    status: {
        type: String,
        required: true,
        validator: (v) => ['ok', 'warn', 'bad', 'info', 'adj', 'active', 'near_expiry', 'expired', 'depleted'].includes(v),
    },
});

const colorMap = {
    ok: { bg: 'bg-ok-bg', fg: 'text-ok-fg' },
    warn: { bg: 'bg-warn-bg', fg: 'text-warn-fg' },
    bad: { bg: 'bg-bad-bg', fg: 'text-bad-fg' },
    info: { bg: 'bg-info-bg', fg: 'text-info-fg' },
    adj: { bg: 'bg-adj-bg', fg: 'text-adj-fg' },
    active: { bg: 'bg-lime/10', fg: 'text-lime' },
    near_expiry: { bg: 'bg-yellow-400/10', fg: 'text-yellow-400' },
    expired: { bg: 'bg-red-400/10', fg: 'text-red-400' },
    depleted: { bg: 'bg-surface-2', fg: 'text-muted' },
};
</script>

<template>
    <span :class="[colorMap[status].bg, colorMap[status].fg, 'px-3 py-1 text-xs font-semibold inline-block']">
        <slot />
    </span>
</template>
