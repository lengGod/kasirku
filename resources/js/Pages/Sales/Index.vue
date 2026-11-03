<script setup>
import AuthenticatedLayout from '@/Layouts/AuthenticatedLayout.vue';
import Card from '@/Components/Card.vue';
import FormInput from '@/Components/FormInput.vue';
import FormSelect from '@/Components/FormSelect.vue';
import Pagination from '@/Components/Pagination.vue';
import StatusChip from '@/Components/StatusChip.vue';
import PrimaryButton from '@/Components/PrimaryButton.vue';
import SecondaryButton from '@/Components/SecondaryButton.vue';
import { Head, Link, router } from '@inertiajs/vue3';
import { formatDateLong, formatRupiah } from '@/Utils/format';
import { Calendar } from '@lucide/vue';

const props = defineProps({
    sales: Object,
    filters: Object,
    statuses: Array,
});

const load = () => {
    const appliedFilters = Object.fromEntries(
        Object.entries(props.filters).filter(([, value]) => value !== null && value !== undefined && value !== '')
    );

    router.get(route('sales.index'), appliedFilters, { preserveState: true, replace: true, preserveScroll: true });
};

const reset = () => {
    router.get(route('sales.index'), null, { preserveScroll: true });
};

const statusLabel = (status) => props.statuses.find((item) => item.value === status)?.label ?? status;
</script>

<template>
    <Head title="Riwayat Penjualan" />

    <AuthenticatedLayout>
        <div class="bg-canvas min-h-screen py-8">
            <div class="mx-auto max-w-7xl px-4 py-8 sm:px-6 lg:px-8">
                <div class="mb-8 flex flex-col gap-4 sm:flex-row sm:items-center sm:justify-between">
                    <div>
                        <p class="text-sm text-muted">Penjualan</p>
                        <h1 class="text-display text-3xl font-bold text-ink">Riwayat Penjualan</h1>
                    </div>
                    <PrimaryButton as="link" :href="route('pos.index')" class="w-full sm:w-auto">+ Transaksi</PrimaryButton>
                </div>

                <Card class="mb-6 flex flex-col gap-3 sm:flex-row">
                    <div class="relative flex-1">
                        <Calendar class="absolute left-3 top-1/2 h-4 w-4 -translate-y-1/2 text-muted" />
                        <input v-model="filters.date_from" type="date" class="h-12 w-full border-2 border-line px-10 text-sm focus:border-ink focus:outline-none" />
                    </div>
                    <input v-model="filters.date_to" type="date" class="h-12 border-2 border-line px-4 text-sm focus:border-ink focus:outline-none" />
                    <FormSelect v-model="filters.status" class="sm:w-52">
                        <option value="">Semua Status</option>
                        <option v-for="status in statuses" :key="status.value" :value="status.value">{{ status.label }}</option>
                    </FormSelect>
                    <div class="flex gap-2">
                        <PrimaryButton type="button" @click="load">Filter</PrimaryButton>
                        <SecondaryButton type="button" @click="reset">Reset</SecondaryButton>
                    </div>
                </Card>

                <Card class="shadow-hard">
                    <div class="overflow-x-auto">
                        <table class="w-full text-sm">
                            <thead>
                        <tr>
                            <th class="border-b-2 border-line px-4 py-3 text-left font-semibold text-muted">Struk</th>
                            <th class="border-b-2 border-line px-4 py-3 text-left font-semibold text-muted">Tanggal</th>
                            <th class="border-b-2 border-line px-4 py-3 text-left font-semibold text-muted">Kasir</th>
                            <th class="border-b-2 border-line px-4 py-3 text-left font-semibold text-muted">Pelanggan</th>
                            <th class="border-b-2 border-line px-4 py-3 text-left font-semibold text-muted">Status</th>
                            <th class="border-b-2 border-line px-4 py-3 text-right font-semibold text-muted">Total</th>
                            <th class="border-b-2 border-line px-4 py-3 text-right font-semibold text-muted">Aksi</th>
                        </tr>
                    </thead>
                    <tbody>
                        <tr v-if="!sales.data?.length">
                            <td colspan="7" class="px-4 py-10 text-center text-sm text-muted">Belum ada transaksi penjualan.</td>
                        </tr>
                        <tr v-for="sale in sales.data" :key="sale.id" class="border-b border-surface-2 hover:bg-surface-2">
                            <td class="px-4 py-4 font-semibold text-ink">{{ sale.invoice_number }}</td>
                            <td class="px-4 py-4 text-muted">{{ formatDateLong(sale.created_at) }}</td>
                            <td class="px-4 py-4">{{ sale.cashier?.name }}</td>
                            <td class="px-4 py-4">{{ sale.customer?.name ?? 'Umum' }}</td>
                            <td class="px-4 py-4"><StatusChip :status="sale.status === 'partial_refund' ? 'adj' : sale.status">{{ statusLabel(sale.status) }}</StatusChip></td>
                            <td class="px-4 py-4 text-right font-bold text-ink">{{ formatRupiah(sale.grand_total) }}</td>
                            <td class="px-4 py-4 text-right">
                                <div class="inline-flex items-center border-2 border-ink bg-surface shadow-hard">
                                    <Link :href="route('sales.show', sale.id)" class="inline-flex h-9 items-center px-3 text-xs font-semibold text-ink hover:bg-hi">Lihat</Link>
                                </div>
                            </td>
                        </tr>
                    </tbody>
                </table>
                    </div>
                    <Pagination :paginator="sales" />
                </Card>
            </div>
        </div>
    </AuthenticatedLayout>
</template>
