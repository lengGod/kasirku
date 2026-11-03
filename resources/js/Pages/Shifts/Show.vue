<script setup>
import AuthenticatedLayout from '@/Layouts/AuthenticatedLayout.vue';
import PageHeader from '@/Components/PageHeader.vue';
import { Head } from '@inertiajs/vue3';
import { formatDateLong, formatRupiah, formatNumber } from '@/Utils/format';

const props = defineProps({
    shift: Object,
    summary: Object,
    statuses: {
        type: Array,
        default: () => [],
    },
});

const statusLabel = (status) => props.statuses.find((item) => item.value === status)?.label ?? status;
</script>

<template>
    <Head :title="`Shift ${shift.id}`" />

    <AuthenticatedLayout>
        <div class="mx-auto max-w-7xl px-4 py-8 sm:px-6 lg:px-8">
            <PageHeader :title="`Shift ${shift.id}`" subtitle="Ringkasan transaksi dan kas shift ini.">
                <template #actions>
                    <PrimaryButton as="link" :href="route('shifts.index')">Kembali ke Daftar</PrimaryButton>
                </template>
            </PageHeader>

            <div class="grid grid-cols-1 gap-4 sm:grid-cols-3 lg:grid-cols-4">
                <div class="border-2 border-ink bg-surface p-5 shadow-hard">
                    <p class="text-[11px] font-bold uppercase tracking-wide text-muted">Jumlah Transaksi</p>
                    <p class="font-display text-3xl font-bold text-ink">{{ formatNumber(summary.transaction_count ?? 0, 0) }}</p>
                </div>
                <div class="border-2 border-ink bg-lime p-5 shadow-hard">
                    <p class="text-[11px] font-bold uppercase tracking-wide text-ink/70">Total Penjualan</p>
                    <p class="font-display text-3xl font-bold text-ink">{{ formatRupiah(summary.sales_total ?? 0) }}</p>
                </div>
                <div class="border-2 border-ink bg-surface p-5 shadow-hard">
                    <p class="text-[11px] font-bold uppercase tracking-wide text-muted">Ekspektasi Tunai</p>
                    <p class="font-display text-2xl font-bold text-ink">{{ formatRupiah(summary.expected_cash ?? 0) }}</p>
                </div>
                <div class="border-2 border-ink bg-ink p-5 shadow-hard">
                    <p class="text-[11px] font-bold uppercase tracking-wide text-lime">Selisih</p>
                    <p class="font-display text-2xl font-bold text-white">{{ shift.difference ? formatRupiah(shift.difference) : '0' }}</p>
                </div>
            </div>

            <div class="mt-6 grid grid-cols-1 gap-6 lg:grid-cols-2">
                <Card tone="surface">
                    <div class="mb-4 flex items-center justify-between">
                        <h2 class="font-display text-lg font-bold text-ink">Detail Shift</h2>
                        <span class="bg-surface-2 px-3 py-1 text-[10px] font-bold text-muted">{{ shift.status === 'open' ? 'Terbuka' : 'Ditutup' }}</span>
                    </div>
                    <dl class="grid grid-cols-1 gap-3 sm:grid-cols-2 text-sm">
                        <dt class="text-muted">Kasir</dt><dd class="font-semibold text-ink">{{ shift.user?.name }}</dd>
                        <dt class="text-muted">Dibuka</dt><dd class="font-semibold text-ink">{{ formatDateLong(shift.opened_at) }}</dd>
                        <dt class="text-muted">Ditutup</dt><dd class="font-semibold text-ink">{{ shift.closed_at ? formatDateLong(shift.closed_at) : 'Belum ditutup' }}</dd>
                        <dt class="text-muted">Modal Awal</dt><dd class="font-bold text-ink">{{ formatRupiah(shift.opening_cash) }}</dd>
                        <dt class="text-muted">Kas Aktual</dt><dd class="font-bold text-ink">{{ shift.actual_cash ? formatRupiah(shift.actual_cash) : '-' }}</dd>
                        <dt class="text-muted">Selisih</dt><dd class="font-bold text-ink">{{ shift.difference ? formatRupiah(shift.difference) : '-' }}</dd>
                    </dl>
                </Card>

                <Card tone="surface">
                    <h2 class="mb-4 font-display text-lg font-bold text-ink">Pembayaran per Metode</h2>
                    <div v-if="summary.by_method?.length" class="space-y-3">
                        <div v-for="row in summary.by_method" :key="row.name" class="flex items-center justify-between border-b border-line pb-2 last:border-0 last:pb-0">
                            <span class="text-sm text-ink">{{ row.name }}</span>
                            <span class="text-sm font-bold text-ink">{{ formatRupiah(row.total) }}</span>
                        </div>
                    </div>
                    <p v-else class="text-sm text-muted">Belum ada pembayaran.</p>
                </Card>
            </div>

            <div class="mt-6 overflow-x-auto border-2 border-ink bg-surface shadow-hard">
                <table class="w-full text-sm">
                    <thead class="bg-surface-2">
                        <tr>
                            <th class="px-4 py-3 text-[11px] font-bold uppercase text-muted">Struk</th>
                            <th class="px-4 py-3 text-[11px] font-bold uppercase text-muted">Tanggal</th>
                            <th class="px-4 py-3 text-[11px] font-bold uppercase text-muted">Pelanggan</th>
                            <th class="px-4 py-3 text-[11px] font-bold uppercase text-muted">Total</th>
                            <th class="px-4 py-3 text-[11px] font-bold uppercase text-muted">Status</th>
                        </tr>
                    </thead>
                    <tbody class="divide-y divide-line">
                        <tr v-if="!shift.sales?.length">
                            <td colspan="5" class="px-4 py-10 text-center text-sm text-muted">Belum ada transaksi pada shift ini.</td>
                        </tr>
                        <tr v-for="sale in shift.sales" :key="sale.id" class="hover:bg-surface-2">
                            <td class="px-4 py-3 text-sm">{{ sale.invoice_number }}</td>
                            <td class="px-4 py-3 text-sm text-muted">{{ formatDateLong(sale.created_at) }}</td>
                            <td class="px-4 py-3 text-sm">{{ sale.customer?.name ?? 'Umum' }}</td>
                            <td class="px-4 py-3 text-sm font-bold text-ink">{{ formatRupiah(sale.grand_total) }}</td>
                            <td class="px-4 py-3 text-xs font-bold">{{ statusLabel(sale.status) }}</td>
                        </tr>
                    </tbody>
                </table>
            </div>
        </div>
    </AuthenticatedLayout>
</template>
