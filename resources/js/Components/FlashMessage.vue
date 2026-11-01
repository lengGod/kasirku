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
        <div v-if="showSuccess" class="fixed top-28 right-6 z-[9999] animate-slide-in">
            <div class="bg-lime/95 border-2 border-lime text-ink px-6 py-4 rounded shadow-hard flex items-center gap-3 min-w-[300px] max-w-md">
                <CircleCheck class="w-5 h-5 flex-shrink-0" />
                <span class="text-sm font-semibold">{{ successMessage }}</span>
                <button @click="showSuccess = false" class="ml-auto text-ink hover:text-lime transition">
                    <X class="w-4 h-4" />
                </button>
            </div>
        </div>

        <!-- Error Toast -->
        <div v-if="showError" class="fixed top-28 right-6 z-[9999] animate-slide-in">
            <div class="bg-red-400/95 border-2 border-red-400 text-ink px-6 py-4 rounded shadow-hard flex items-center gap-3 min-w-[300px] max-w-md">
                <CircleX class="w-5 h-5 flex-shrink-0" />
                <span class="text-sm font-semibold">{{ errorMessage }}</span>
                <button @click="showError = false" class="ml-auto text-ink hover:text-red-400 transition">
                    <X class="w-4 h-4" />
                </button>
            </div>
        </div>
    </Teleport>
</template>