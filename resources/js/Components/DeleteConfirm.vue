<script setup>
import { ref, watch } from 'vue';
import { LoaderCircle } from '@lucide/vue';
import SecondaryButton from '@/Components/SecondaryButton.vue';

const props = defineProps({
    isOpen: {
        type: Boolean,
        default: false,
    },
    title: {
        type: String,
        default: 'Konfirmasi Hapus',
    },
    message: {
        type: String,
        default: 'Apakah Anda yakin ingin menghapus data ini? Tindakan ini tidak dapat dibatalkan.',
    },
    confirmText: {
        type: String,
        default: 'Hapus',
    },
    cancelText: {
        type: String,
        default: 'Batal',
    },
    variant: {
        type: String,
        default: 'danger',
    },
    processing: {
        type: Boolean,
        default: false,
    },
});

const emit = defineEmits(['confirm', 'cancel']);

const confirm = () => {
    emit('confirm');
};

const cancel = () => {
    emit('cancel');
};

const handleKeydown = (e) => {
    if (e.key === 'Escape') cancel();
    if (e.key === 'Enter') confirm();
};

watch(() => props.isOpen, (val) => {
    if (val) {
        document.addEventListener('keydown', handleKeydown);
        document.body.style.overflow = 'hidden';
    } else {
        document.removeEventListener('keydown', handleKeydown);
        document.body.style.overflow = '';
    }
});
</script>

<template>
    <Teleport to="body">
        <div v-if="isOpen" class="fixed inset-0 z-[9999] flex items-center justify-center" @click.self="cancel">
            <!-- Backdrop -->
            <div class="absolute inset-0 bg-black/50 backdrop-blur-sm transition-opacity" />

            <!-- Modal -->
            <div class="relative bg-surface border-2 border-ink shadow-hard max-w-md w-full mx-4 animate-scale-in">
                <div class="p-6">
                    <h3 class="text-xl font-bold text-ink font-display mb-2">{{ title }}</h3>
                    <p class="text-muted text-sm">{{ message }}</p>
                </div>
                <div class="border-t-2 border-line p-4 flex justify-end gap-3">
                    <SecondaryButton @click="cancel" :disabled="processing">{{ cancelText }}</SecondaryButton>
                    <button 
                        @click="confirm"
                        :disabled="processing"
                        :class="[
                            'inline-flex items-center justify-center gap-2 px-6 h-12 text-sm font-semibold rounded transition disabled:opacity-50 disabled:cursor-not-allowed',
                            variant === 'danger' ? 'bg-red-400 text-ink hover:bg-red-500' :
                            variant === 'primary' ? 'bg-ink text-white hover:bg-ink-3' :
                            'bg-violet-text text-white hover:bg-violet-text/90'
                        ]"
                    >
                        <LoaderCircle v-if="processing" class="w-4 h-4 animate-spin" />
                        {{ confirmText }}
                    </button>
                </div>
            </div>
        </div>
    </Teleport>
</template>