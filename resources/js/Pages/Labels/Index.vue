<script setup>
import AuthenticatedLayout from '@/Layouts/AuthenticatedLayout.vue';
import Card from '@/Components/Card.vue';
import PageHeader from '@/Components/PageHeader.vue';
import PrimaryButton from '@/Components/PrimaryButton.vue';
import SecondaryButton from '@/Components/SecondaryButton.vue';
import { Head, router } from '@inertiajs/vue3';

const props = defineProps({ products: Array, store: Object });

const checked = ref([]);

const toggle = (id) => {
    checked.value = checked.value.includes(id) ? checked.value.filter(i => i !== id) : [...checked.value, id];
};

const printLabels = () => {
    if (!checked.value.length) return;

    router.post(route('labels.print'), {
        product_ids: checked.value,
        copies: 1,
    });
};

const printPdf = () => {
    if (!checked.value.length) return;

    window.location.href = route('labels.print', { product_ids: checked.value.join(','), copies: 1, format: 'pdf' });
};
</script>

<template>
    <Head title="Label Harga" />

    <AuthenticatedLayout>
        <div class="bg-canvas min-h-screen py-8"><div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
            <PageHeader title="Label Harga" subtitle="Cetak stiker barcode untuk produk.">
                <template #actions>
                    <div class="flex gap-2">
                        <SecondaryButton v-if="checked.length" type="button" @click="printLabels">Cetak Browser</SecondaryButton>
                        <SecondaryButton v-if="checked.length" type="button" @click="printPdf">Cetak PDF</SecondaryButton>
                    </div>
                </template>
            </PageHeader>

            <Card class="shadow-hard">
                <div v-if="!products?.length" class="text-center py-8"><p class="text-muted text-sm">Belum ada produk.</p></div>
                <div v-else class="overflow-x-auto">
                <table class="w-full text-sm">
                    <thead>
                        <tr>
                            <th class="px-4 py-3 text-[11px] font-bold uppercase text-muted">Pilih</th>
                            <th class="px-4 py-3 text-[11px] font-bold uppercase text-muted">Produk</th>
                            <th class="px-4 py-3 text-[11px] font-bold uppercase text-muted">SKU / Barcode</th>
                            <th class="px-4 py-3 text-[11px] font-bold uppercase text-muted text-right">Harga</th>
                        </tr>
                    </thead>
                    <tbody>
                        <tr v-for="product in products" :key="product.id" class="hover:bg-surface-2">
                            <td class="px-4 py-3">
                                <input type="checkbox" :model-value="checked" :value="product.id" @change="toggle(product.id)" class="h-4 w-4 accent-lime border-2 border-ink rounded" />
                            </td>
                            <td class="px-4 py-3 text-sm font-semibold text-ink">{{ product.name }}</td>
                            <td class="px-4 py-3 text-sm">{{ product.sku }} · {{ product.barcode ?? '-' }}</td>
                            <td class="px-4 py-3 text-sm text-right font-bold">{{ formatRupiah(product.sell_price) }}</td>
                        </tr>
                    </tbody>
                </table>
                </div>
            </Card>

            <p class="mt-4 text-sm text-muted">Pilih produk untuk dicetak labelnya.</p>
        </div></div>
    </AuthenticatedLayout>
</template>
