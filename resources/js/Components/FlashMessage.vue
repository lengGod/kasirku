<script setup>
import { ref, onMounted, onUnmounted } from 'vue';
import { usePage, router } from '@inertiajs/vue3';
import { CircleCheck, CircleX, X } from '@lucide/vue';

const page = usePage();
const showSuccess = ref(false);
const showError = ref(false);
const successMessage = ref('');
const errorMessage = ref('');
let successTimer = null;
let errorTimer = null;

const checkFlash = (flash) => {
    if (!flash) return;

    if (flash.success || flash.message) {
        successMessage.value = flash.success || flash.message;
        showSuccess.value = true;
        clearTimeout(successTimer);
        successTimer = setTimeout(() => (showSuccess.value = false), 5000);
    }
    if (flash.error) {
        errorMessage.value = flash.error;
        showError.value = true;
        clearTimeout(errorTimer);
        errorTimer = setTimeout(() => (showError.value = false), 5000);
    }
};

// Initial load
checkFlash(page.props.flash);

// Fire on every successful Inertia visit (after redirect with flash)
const removeListener = router.on('success', (event) => {
    checkFlash(event.detail.page.props.flash);
});

onUnmounted(() => {
    removeListener();
    clearTimeout(successTimer);
    clearTimeout(errorTimer);
});
</script>

<template>
    <Teleport to="body">
        <!-- Success Toast -->
        <div v-if="showSuccess" class="fixed left-4 right-4 top-28 z-[9999] animate-slide-in sm:left-auto sm:right-6">
            <div class="flex w-full items-center gap-3 rounded border-2 border-lime bg-lime/95 px-4 py-4 text-ink shadow-hard sm:w-auto sm:min-w-[300px] sm:max-w-md">
                <CircleCheck class="h-5 w-5 flex-shrink-0" />
                <span class="min-w-0 flex-1 break-words text-sm font-semibold">{{ successMessage }}</span>
                <button @click="showSuccess = false" class="shrink-0 text-ink transition hover:text-lime" aria-label="Tutup notifikasi">
                    <X class="h-4 w-4" />
                </button>
            </div>
        </div>

        <!-- Error Toast -->
        <div v-if="showError" class="fixed left-4 right-4 top-28 z-[9999] animate-slide-in sm:left-auto sm:right-6">
            <div class="flex w-full items-center gap-3 rounded border-2 border-red-400 bg-red-400/95 px-4 py-4 text-ink shadow-hard sm:w-auto sm:min-w-[300px] sm:max-w-md">
                <CircleX class="h-5 w-5 flex-shrink-0" />
                <span class="min-w-0 flex-1 break-words text-sm font-semibold">{{ errorMessage }}</span>
                <button @click="showError = false" class="shrink-0 text-ink transition hover:text-red-400" aria-label="Tutup notifikasi">
                    <X class="h-4 w-4" />
                </button>
            </div>
        </div>
    </Teleport>
</template>