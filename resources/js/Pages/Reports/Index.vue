<script setup>
import AuthenticatedLayout from '@/Layouts/AuthenticatedLayout.vue';
import Card from '@/Components/Card.vue';
import PageHeader from '@/Components/PageHeader.vue';
import PrimaryButton from '@/Components/PrimaryButton.vue';
import SecondaryButton from '@/Components/SecondaryButton.vue';
import { Head, router } from '@inertiajs/vue3';
import { formatRupiah, formatNumber } from '@/Utils/format';
import { Download, Filter, LoaderCircle } from '@lucide/vue';
import { ref } from 'vue';

const props = defineProps({
    type: String,
    title: String,
    headers: Array,
    rows: Array,
    summary: Object,
    filters: Object,
});

const dateFrom = ref(props.filters.date_from);
const dateTo = ref(props.filters.date_to);
const loading = ref(false);

const reportTypes = [
    { key: 'sales', label: 'Penjualan' },
    { key: 'profit', label: 'Laba Kotor' },
    { key: 'products', label: 'Per Produk' },
    { key: 'cashiers', label: 'Per Kasir' },
    { key: 'payments', label: 'Pembayaran' },
    { key: 'shifts', label: 'Shift' },
    { key: 'stock', label: 'Stok' },
];

const loadReport = (nextType = props.type) => {
    if (loading.value) {
        return;
    }

    loading.value = true;

    router.get(route('reports.index'), {
        type: nextType,
        date_from: dateFrom.value,
        date_to: dateTo.value,
    }, {
        preserveState: true,
        preserveScroll: true,
        replace: true,
        onFinish: () => {
            loading.value = false;
        },
    });
};

const summaryLabel = (key) => ({
    total: 'Total',
    transaksi: 'Transaksi',
    penjualan: 'Penjualan',
    laba: 'Laba Kotor',
    total_qty: 'Total Qty',
    nilai: 'Nilai Stok',
    selisih: 'Selisih Kas',
}[key] ?? key);

const numericHeaders = ['Qty', 'Qty Terjual', 'Penjualan', 'HPP', 'Laba', 'Total', 'Total Penjualan', 'Jumlah Transaksi', 'Jumlah Pembayaran', 'Selisih', 'Modal', 'Ekspektasi', 'Aktual', 'Nilai Stok', 'Stok', 'Harga Beli'];
const currencyHeaders = ['Penjualan', 'HPP', 'Laba', 'Total', 'Total Penjualan', 'Selisih', 'Modal', 'Ekspektasi', 'Aktual', 'Nilai Stok', 'Harga Beli'];

const isNumericHeader = (header) => numericHeaders.includes(header);
const isCurrencyHeader = (header) => currencyHeaders.includes(header);

const formatCell = (header, value) => {
    if (isCurrencyHeader(header)) {
        return formatRupiah(value);
    }

    if (isNumericHeader(header)) {
        return formatNumber(value, 0);
    }

    return value;
};

const formatSummary = (key, value) => {
    const label = String(key).toLowerCase();

    if (label.includes('transaksi') || label.includes('qty') || label.includes('jumlah') || label.includes('count')) {
        return formatNumber(value, 0);
    }

    return formatRupiah(value);
};

const goExport = () => {
    const query = new URLSearchParams({
        date_from: dateFrom.value,
        date_to: dateTo.value,
    });

    window.location.href = `${route('reports.export', props.type)}?${query.toString()}`;
};

const goPdf = () => {
    window.location.href = route('reports.pdf', props.type) + `?date_from=${dateFrom.value}&date_to=${dateTo.value}`;
};
</script>

<template>
    <Head :title="title" />

    <AuthenticatedLayout>
        <div class="mx-auto max-w-7xl px-4 py-8 sm:px-6 lg:px-8">
            <PageHeader :title="title" subtitle="Laporan data operasi kasir.">
                <template #actions>
                    <div class="flex gap-2">
                        <SecondaryButton type="button" @click="goExport"><Download class="h-4 w-4" /> CSV</SecondaryButton>
                        <SecondaryButton type="button" @click="goPdf">PDF</SecondaryButton>
                    </div>
                </template>
            </PageHeader>

            <div class="mb-6 flex flex-wrap gap-2">
                <button
                    v-for="report in reportTypes"
                    :key="report.key"
                    type="button"
                    :disabled="loading"
                    :class="[
                        'border-2 border-ink px-4 py-2 text-xs font-bold transition disabled:cursor-wait',
                        type === report.key ? 'bg-ink text-white' : 'bg-surface text-ink hover:bg-surface-2',
                    ]"
                    @click="loadReport(report.key)"
                >
                    {{ report.label }}
                </button>
            </div>

            <Card tone="surface">
                <div class="grid grid-cols-1 gap-3 sm:grid-cols-[1fr_auto_auto] p-4">
                    <div class="relative">
                        <Filter class="absolute left-3 top-1/2 h-4 w-4 -translate-y-1/2 text-muted" />
                        <input v-model="dateFrom" type="date" class="h-11 pl-9 border-2 border-ink px-3 text-sm" />
                    </div>
                    <div class="relative">
                        <input v-model="dateTo" type="date" class="h-11 pl-9 border-2 border-ink px-3 text-sm" />
                    </div>
                    <div class="flex gap-2">
                        <PrimaryButton type="button" :loading="loading" @click="loadReport()">Tampilkan</PrimaryButton>
                    </div>
                </div>
            </Card>

            <div class="relative mt-6 border-2 border-ink bg-surface shadow-hard overflow-hidden">
                <div v-if="loading" class="absolute inset-0 z-20 flex flex-col items-center justify-center gap-2 bg-surface/85 px-4 text-center sm:gap-3">
                    <LoaderCircle class="h-8 w-8 animate-spin text-violet-text sm:h-9 sm:w-9" />
                    <p class="text-[11px] font-semibold leading-tight tracking-wide text-ink sm:text-xs">Memuat laporan...</p>
                </div>

                <div :class="loading ? 'pointer-events-none opacity-40' : ''">
                    <div class="overflow-x-auto">
                        <table class="w-full text-sm">
                            <thead class="bg-surface-2">
                                <tr>
                                    <th v-for="header in headers" :key="header" class="px-4 py-3 text-[11px] font-bold uppercase text-muted" :class="isNumericHeader(header) ? 'text-right' : 'text-left'">{{ header }}</th>
                                </tr>
                            </thead>
                            <tbody class="divide-y divide-line">
                                <tr v-if="!rows.length">
                                    <td :colspan="headers?.length || 1" class="px-4 py-12 text-center text-sm text-muted">Tidak ada data pada periode yang dipilih.</td>
                                </tr>
                                <tr v-for="row in rows" :key="row.join('|')" class="hover:bg-surface-2">
                                    <td v-for="(cell, index) in row" :key="index" class="px-4 py-4 text-sm" :class="isNumericHeader(headers[index] ?? '') ? 'text-right font-bold' : 'text-left'">
                                        {{ formatCell(headers[index], cell) }}
                                    </td>
                                </tr>
                            </tbody>
                        </table>
                    </div>

                    <div class="border-t-2 border-ink p-4">
                        <dl class="flex flex-wrap items-center justify-end gap-x-6 gap-y-2">
                            <div v-for="(value, key) in summary" :key="key" class="flex items-baseline gap-2">
                                <dt class="text-xs text-muted">{{ summaryLabel(key) }}</dt>
                                <dd class="text-sm font-bold text-ink">{{ typeof value === 'number' ? formatSummary(key, value) : value }}</dd>
                            </div>
                        </dl>
                    </div>
                </div>
            </div>
        </div>
    </AuthenticatedLayout>
</template>
