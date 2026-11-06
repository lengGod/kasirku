<script setup>
import AuthenticatedLayout from '@/Layouts/AuthenticatedLayout.vue';
import PageHeader from '@/Components/PageHeader.vue';
import { Head, Link } from '@inertiajs/vue3';
import { formatDateLong, formatNumber, formatRupiah } from '@/Utils/format';
import { ArrowLeft } from '@lucide/vue';

const props = defineProps({
    product: Object,
    types: {
        type: Array,
        default: () => [],
    },
});

const typeLabel = (type) => props.types.find((item) => item.value === type)?.label ?? type;
</script>

<template>
    <Head :title="product.name" />

    <AuthenticatedLayout>
        <div class="mx-auto max-w-7xl px-4 py-8 sm:px-6 lg:px-8">
            <PageHeader :title="product.name" :subtitle="`${product.sku} · ${product.category?.name} · ${product.unit?.name}`">
                <template #actions>
                    <Link :href="route('products.index')" class="inline-flex h-12 items-center gap-2 border-2 border-ink bg-surface px-5 text-sm font-semibold hover:bg-hi">
                        <ArrowLeft class="h-4 w-4" /> Kembali
                    </Link>
                </template>
            </PageHeader>

            <div class="grid grid-cols-1 gap-4 sm:grid-cols-3">
                <div class="border-2 border-ink bg-surface p-4 shadow-hard">
                    <p class="text-[11px] font-bold uppercase text-muted">Harga Jual</p>
                    <p class="font-display text-xl font-bold text-ink">{{ formatRupiah(product.sell_price) }}</p>
                </div>
                <div class="border-2 border-ink bg-surface p-4 shadow-hard">
                    <p class="text-[11px] font-bold uppercase text-muted">Stok Saat Ini</p>
                    <p class="font-display text-xl font-bold text-ink">{{ formatNumber(product.stocks?.reduce((sum, s) => sum + Number(s.quantity), 0), 0) }}</p>
                </div>
                <div class="border-2 border-ink bg-surface p-4 shadow-hard">
                    <p class="text-[11px] font-bold uppercase text-muted">Barcode</p>
                    <p class="font-display text-lg font-bold text-ink">{{ product.barcode ?? '-' }}</p>
                </div>
            </div>

            <div class="mt-6 overflow-x-auto border-2 border-ink bg-surface shadow-hard">
                <div class="border-b-2 border-ink bg-surface-2 px-4 py-3">
                    <h2 class="font-display text-lg font-bold text-ink">Riwayat Pergerakan Stok</h2>
                </div>
                <table class="w-full text-sm">
                    <thead>
                        <tr>
                            <th class="px-4 py-2 text-[11px] font-bold uppercase text-muted">Tanggal</th>
                            <th class="px-4 py-2 text-[11px] font-bold uppercase text-muted">Tipe</th>
                            <th class="px-4 py-2 text-[11px] font-bold uppercase text-muted text-right">Qty</th>
                            <th class="px-4 py-2 text-[11px] font-bold uppercase text-muted text-right">Saldo</th>
                        </tr>
                    </thead>
                    <tbody class="divide-y divide-line">
                        <tr v-if="!product.movements?.length">
                            <td colspan="4" class="px-4 py-10 text-center text-sm text-muted">Belum ada pergerakan stok.</td>
                        </tr>
                        <tr v-for="movement in product.movements" :key="movement.id">
                            <td class="px-4 py-2 text-sm">{{ formatDateLong(movement.created_at) }}</td>
                            <td class="px-4 py-2 text-sm">{{ typeLabel(movement.type) }}</td>
                            <td class="px-4 py-2 text-sm text-right font-bold">{{ formatNumber(movement.qty, 0) }}</td>
                            <td class="px-4 py-2 text-sm text-right">{{ formatNumber(movement.balance_after, 0) }}</td>
                        </tr>
                    </tbody>
                </table>
            </div>
        </div>
    </AuthenticatedLayout>
</template>
