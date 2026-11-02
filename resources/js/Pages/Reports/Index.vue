<script setup>
import AuthenticatedLayout from '@/Layouts/AuthenticatedLayout.vue';
import Card from '@/Components/Card.vue';
import PageHeader from '@/Components/PageHeader.vue';
import FormInput from '@/Components/FormInput.vue';
import PrimaryButton from '@/Components/PrimaryButton.vue';
import SecondaryButton from '@/Components/SecondaryButton.vue';
import { Head, Link, router } from '@inertiajs/vue3';
import { formatRupiah, formatNumber } from '@/Utils/format';
import { Download, Filter } from '@lucide/vue';
import { ref } from 'vue';

const props = defineProps({
    type: String,
    title: String,
    headers: Array,
    rows: Array,
    summary: Object,
    filters: Object,
});

const filters = props.filters;
const reportTypes = [
    { key: 'sales', label: 'Penjualan' },
    { key: 'profit', label: 'Laba Kotor' },
    { key: 'products', label: 'Per Produk' },
    { key: 'cashiers', label: 'Per Kasir' },
    { key: 'payments', label: 'Pembayaran' },
    { key: 'shifts', label: 'Shift' },
    { key: 'stock', label: 'Stok' },
];

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

const formatCell = (header, value) => {
    if (typeof value === 'number' || (!isNaN(Number(value)) && value !== '')) {
        const lower = String(header).toLowerCase();
        if (lower.includes('qty') || lower.includes('transaksi') || lower.includes('total')) {
            return formatNumber(value, lower.includes('qty') ? 0 : 2);
        }
        return formatRupiah(value);
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
    router.get(route('reports.export', props.type), { date_from: filters.date_from, date_to: filters.date_to }, {
        onSuccess: () => {},
    });
};

const goPdf = () => {
    window.location.href = route('reports.pdf', props.type) + `?date_from=${filters.date_from}&date_to=${filters.date_to}`;
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
                <Link
                    v-for="report in reportTypes"
                    :key="report.key"
                    :href="route('reports.show', report.key)"
                    :class="[
                        'border-2 border-ink px-4 py-2 text-xs font-bold transition',
                        type === report.key ? 'bg-ink text-white' : 'bg-surface text-ink hover:bg-surface-2',
                    ]"
                >
                    {{ report.label }}
                </Link>
            </div>

            <Card tone="surface">
                <div class="grid gap-3 sm:grid-cols-[1fr_auto_auto] p-4">
                    <div class="relative">
                        <Filter class="absolute left-3 top-1/2 h-4 w-4 -translate-y-1/2 text-muted" />
                        <input v-model="filters.date_from" type="date" class="h-11 pl-9 border-2 border-ink px-3 text-sm" />
                    </div>
                    <div class="relative">
                        <input v-model="filters.date_to" type="date" class="h-11 pl-9 border-2 border-ink px-3 text-sm" />
                    </div>
                    <div class="flex gap-2">
                        <PrimaryButton as="link" :href="route('reports.show', props.type) + '?date_from=' + filters.date_from + '&date_to=' + filters.date_to">Tampilkan</PrimaryButton>
                    </div>
                </div>
            </Card>

            <div class="mt-6 border-2 border-ink bg-surface shadow-hard overflow-hidden">
                <div v-if="!rows.length" class="py-12 text-center text-sm text-muted">
                    Tidak ada data pada periode yang dipilih.
                </div>
                <table v-else class="w-full text-sm">
                    <thead class="bg-surface-2">
                        <tr>
                            <th v-for="header in headers" :key="header" class="px-4 py-3 text-[11px] font-bold uppercase text-muted">{{ header }}</th>
                        </tr>
                    </thead>
                    <tbody class="divide-y divide-line">
                        <tr v-for="row in rows" :key="row.join('|')" class="hover:bg-surface-2">
                            <td v-for="(cell, index) in row" :key="index" class="px-4 py-4 text-sm" :class="numericHeaders.includes(headers[index] ?? '') ? 'text-right font-bold' : 'text-left'">
                                {{ formatCell(headers[index], cell) }}
                            </td>
                        </tr>
                    </tbody>
                </table>

                <div class="p-4 border-t-2 border-ink">
                    <dl class="grid gap-2 sm:grid-cols-2">
                        <div v-for="(value, key) in summary" :key="key" class="flex justify-between">
                            <span class="text-xs text-muted">{{ summaryLabel(key) }}</span>
                            <span class="text-sm font-bold text-ink">{{ typeof value === 'number' ? formatSummary(key, value) : value }}</span>
                        </div>
                    </dl>
                </div>
            </div>
        </div>
    </AuthenticatedLayout>
</template>
