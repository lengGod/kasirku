<script setup>
import { Head } from '@inertiajs/vue3';
import { formatRupiah } from '@/Utils/format';

const props = defineProps({ products: Array, copies: Number, store: String });
const appUrl = import.meta.env.VITE_APP_URL ?? '';
</script>

<template>
    <Head title="Cetak Label" />

    <div class="min-h-screen bg-canvas p-4">
        <div class="max-w-3xl mx-auto">
            <div class="mb-4 flex justify-between items-center print:hidden">
                <button type="button" class="flex items-center gap-2 border-2 border-ink px-4 py-2 text-xs font-bold text-ink hover:bg-hi" onclick="window.print()">
                    Cetak
                </button>
                <a href="/" class="inline-flex items-center gap-2 border-2 border-ink px-4 py-2 text-xs font-bold text-ink hover:bg-hi">Kembali</a>
            </div>

            <div class="grid gap-3 grid-cols-2 md:grid-cols-3 xl:grid-cols-4">
                <template v-for="copy in Array(copies).fill(0)">
                    <div v-for="product in products" :key="`${product.id}-${copy}`" class="border-2 border-ink p-3">
                        <div class="flex justify-between items-center mb-2">
                            <p class="text-[10px] font-bold uppercase text-muted">{{ store }}</p>
                        </div>
                        <div class="flex items-center justify-center mb-2">
                            <img :src="`${appUrl}/labels/barcode/${product.barcode ?? product.sku}`" alt="barcode" class="h-12 w-48" />
                        </div>
                        <p class="text-center text-xs font-bold truncate">{{ product.name }}</p>
                        <p class="text-center font-display text-sm font-bold text-ink">{{ formatRupiah(product.sell_price) }}</p>
                        <p class="text-center text-[10px] text-muted">{{ product.sku }}</p>
                    </div>
                </template>
            </div>
        </div>
    </div>
</template>