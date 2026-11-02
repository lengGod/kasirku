<script setup>
import AuthenticatedLayout from '@/Layouts/AuthenticatedLayout.vue';
import Card from '@/Components/Card.vue';
import PageHeader from '@/Components/PageHeader.vue';
import FormSelect from '@/Components/FormSelect.vue';
import PrimaryButton from '@/Components/PrimaryButton.vue';
import SecondaryButton from '@/Components/SecondaryButton.vue';
import Pagination from '@/Components/Pagination.vue';
import { Head, router } from '@inertiajs/vue3';
import { formatDateLong, formatNumber } from '@/Utils/format';
import { ref } from 'vue';

const props = defineProps({ movements: Object, products: Array, types: Array, filters: Object });

const productId = ref(props.filters?.product_id ?? '');
const type = ref(props.filters?.type ?? '');
const dateFrom = ref(props.filters?.date_from ?? '');
const dateTo = ref(props.filters?.date_to ?? '');

const load = () => {
    router.get(route('stock.movements'), {
        product_id: productId.value,
        type: type.value,
        date_from: dateFrom.value,
        date_to: dateTo.value,
    }, { preserveState: true, replace: true, preserveScroll: true });
};

const reset = () => {
    productId.value = '';
    type.value = '';
    dateFrom.value = '';
    dateTo.value = '';
    load();
};
</script>

<template>
    <Head title="Riwayat Stok" />

    <AuthenticatedLayout>
        <div class="bg-canvas min-h-screen py-8"><div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
            <PageHeader title="Riwayat Stok" subtitle="Semua pergerakan stok masuk dan keluar." />

            <Card class="mb-6 grid gap-3 sm:grid-cols-2 lg:grid-cols-5">
                <FormSelect v-model="productId">
                    <option value="">Semua produk</option>
                    <option v-for="product in products" :key="product.id" :value="product.id">{{ product.name }}</option>
                </FormSelect>
                <FormSelect v-model="type">
                    <option value="">Semua tipe</option>
                    <option v-for="row in types" :key="row.value" :value="row.value">{{ row.label }}</option>
                </FormSelect>
                <input v-model="dateFrom" type="date" class="h-12 border-2 border-ink px-3 text-sm" />
                <input v-model="dateTo" type="date" class="h-12 border-2 border-ink px-3 text-sm" />
                <div class="flex gap-2">
                    <PrimaryButton type="button" @click="load">Filter</PrimaryButton>
                    <SecondaryButton type="button" @click="reset">Reset</SecondaryButton>
                </div>
            </Card>

            <Card class="shadow-hard">
                <div v-if="!movements.data?.length" class="text-center py-8"><p class="text-muted text-sm">Belum ada pergerakan stok.</p></div>
                <div v-else class="overflow-x-auto">
                <table class="w-full text-sm">
                    <thead class="bg-surface-2">
                        <tr>
                            <th class="px-4 py-3 text-[11px] font-bold uppercase text-muted">Waktu</th>
                            <th class="px-4 py-3 text-[11px] font-bold uppercase text-muted">Produk</th>
                            <th class="px-4 py-3 text-[11px] font-bold uppercase text-muted">Tipe</th>
                            <th class="px-4 py-3 text-[11px] font-bold uppercase text-muted text-right">Qty</th>
                            <th class="px-4 py-3 text-[11px] font-bold uppercase text-muted text-right">Saldo</th>
                            <th class="px-4 py-3 text-[11px] font-bold uppercase text-muted">Catatan</th>
                        </tr>
                    </thead>
                    <tbody class="divide-y divide-line">
                        <tr v-for="movement in movements.data" :key="movement.id" class="hover:bg-surface-2">
                            <td class="px-4 py-3 text-sm text-muted">{{ formatDateLong(movement.created_at) }}</td>
                            <td class="px-4 py-3 text-sm font-semibold text-ink">{{ movement.product?.name }}</td>
                            <td class="px-4 py-3 text-sm">{{ types.find(t => t.value === movement.type)?.label ?? movement.type }}</td>
                            <td :class="['px-4 py-3 text-sm text-right font-bold', Number(movement.qty) < 0 ? 'text-bad-fg' : 'text-ok-fg']">{{ formatNumber(movement.qty, 0) }}</td>
                            <td class="px-4 py-3 text-sm text-right">{{ formatNumber(movement.balance_after, 0) }}</td>
                            <td class="px-4 py-3 text-xs text-muted">{{ movement.note }}</td>
                        </tr>
                    </tbody>
                </table>
                </div>
                <Pagination :paginator="movements" />
            </Card>
        </div></div>
    </AuthenticatedLayout>
</template>
