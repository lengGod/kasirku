<script setup>
import { ref, onUnmounted } from 'vue';
import { router } from '@inertiajs/vue3';
import { LoaderCircle } from '@lucide/vue';

const loading = ref(false);
let hideTimer = null;
let shownAt = 0;

const start = (event) => {
    const currentUrl = new URL(window.location.href);
    const nextUrl = new URL(event.detail.visit.url, window.location.origin);

    if (nextUrl.pathname === currentUrl.pathname) {
        return;
    }

    clearTimeout(hideTimer);
    shownAt = Date.now();
    loading.value = true;
};

const finish = () => {
    if (!loading.value) {
        return;
    }

    const remaining = Math.max(0, 300 - (Date.now() - shownAt));

    clearTimeout(hideTimer);
    hideTimer = setTimeout(() => {
        loading.value = false;
    }, remaining);
};

const removeStart = router.on('start', start);
const removeFinish = router.on('finish', finish);
const removeError = router.on('error', finish);
const removeInvalid = router.on('invalid', finish);
const removeException = router.on('exception', finish);
const removeCancel = router.on('cancel', finish);

onUnmounted(() => {
    removeStart();
    removeFinish();
    removeError();
    removeInvalid();
    removeException();
    removeCancel();
    clearTimeout(hideTimer);
});
</script>

<template>
    <Teleport to="body">
        <Transition
            enter-active-class="transition-opacity duration-150"
            enter-from-class="opacity-0"
            leave-active-class="transition-opacity duration-200"
            leave-to-class="opacity-0"
        >
            <div
                v-if="loading"
                class="fixed inset-0 z-[10000] flex items-center justify-center bg-ink/40 backdrop-blur-sm"
                role="status"
                aria-live="polite"
            >
                <div class="bg-surface border-2 border-ink shadow-hard px-8 py-6 flex flex-col items-center gap-3">
                    <LoaderCircle class="w-9 h-9 text-violet-text animate-spin" />
                    <p class="text-xs font-semibold text-ink tracking-wide">Memuat halaman...</p>
                </div>
            </div>
        </Transition>
    </Teleport>
</template>
