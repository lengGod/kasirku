<script setup>
import { ref, onUnmounted } from 'vue';
import { Link, router } from '@inertiajs/vue3';
import { ChevronLeft, ChevronRight, LoaderCircle } from '@lucide/vue';

defineProps({
    paginator: {
        type: Object,
        required: true,
    },
});

const loading = ref(false);

const removeStart = router.on('start', (event) => {
    const currentUrl = new URL(window.location.href);
    const nextUrl = new URL(event.detail.visit.url, window.location.origin);
    if (nextUrl.pathname === currentUrl.pathname) {
        loading.value = true;
    }
});

const removeFinish = router.on('finish', () => { loading.value = false; });
const removeError = router.on('error', () => { loading.value = false; });
const removeCancel = router.on('cancel', () => { loading.value = false; });

onUnmounted(() => {
    removeStart();
    removeFinish();
    removeError();
    removeCancel();
});

const isPrev = (label) => !!label && (label === 'pagination.previous' || label.includes('Previous'));
const isNext = (label) => !!label && (label === 'pagination.next' || label.includes('Next'));
</script>

<template>
    <div>
        <!-- Loading Overlay covering the table container Card -->
        <div
            v-if="loading"
            class="absolute inset-0 bg-surface/80 backdrop-blur-[1px] flex items-center justify-center z-20"
            role="status"
            aria-live="polite"
        >
            <div class="bg-surface border-2 border-ink shadow-hard px-6 py-4 flex items-center gap-3">
                <LoaderCircle class="w-6 h-6 text-violet-text animate-spin" />
                <p class="text-xs font-semibold text-ink tracking-wide">Memuat data...</p>
            </div>
        </div>

        <div v-if="paginator.total > paginator.per_page" class="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-3 mt-6">
            <p class="text-xs text-muted">
                Menampilkan {{ paginator.from ?? 0 }}–{{ paginator.to ?? 0 }} dari {{ paginator.total }} data
            </p>
            <nav class="flex flex-wrap gap-1">
                <template v-for="(link, index) in paginator.links" :key="index">
                    <Link
                        v-if="link.url"
                        :href="link.url"
                        preserve-scroll
                        :class="[
                            'inline-flex items-center justify-center min-w-9 h-9 px-3 text-xs font-semibold border-2 transition',
                            link.active
                                ? 'bg-ink text-lime border-ink'
                                : 'bg-surface text-ink border-line hover:border-ink',
                        ]"
                    >
                        <ChevronLeft v-if="isPrev(link.label)" class="w-4 h-4" />
                        <ChevronRight v-else-if="isNext(link.label)" class="w-4 h-4" />
                        <template v-else>{{ link.label }}</template>
                    </Link>
                    <span
                        v-else
                        class="inline-flex items-center justify-center min-w-9 h-9 px-3 text-xs font-semibold border-2 border-line text-muted/50 bg-surface"
                    >
                        <ChevronLeft v-if="isPrev(link.label)" class="w-4 h-4" />
                        <ChevronRight v-else-if="isNext(link.label)" class="w-4 h-4" />
                        <template v-else>{{ link.label }}</template>
                    </span>
                </template>
            </nav>
        </div>
    </div>
</template>