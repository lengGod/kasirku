<script setup>
import AuthenticatedLayout from '@/Layouts/AuthenticatedLayout.vue';
import PageHeader from '@/Components/PageHeader.vue';
import Card from '@/Components/Card.vue';
import { Head, Link } from '@inertiajs/vue3';
import { formatDateLong, formatRupiah } from '@/Utils/format';

defineProps({ refund: Object });
</script>

<template>
    <Head :title="`Retur ${refund.refund_number}`" />

    <AuthenticatedLayout>
        <div class="mx-auto max-w-7xl px-4 py-8 sm:px-6 lg:px-8">
            <PageHeader :title="`Retur ${refund.refund_number}`" subtitle="Detail transaksi retur.">
                <template #actions>
                    <Link :href="route('refunds.index')" class="inline-flex h-10 items-center border-2 border-ink bg-surface px-4 text-xs font-semibold hover:bg-hi">Kembali</Link>
                </template>
            </PageHeader>

            <Card tone="surface">
                <div class="grid gap-4 sm:grid-cols-2">
                    <div>
                        <p class="text-[11px] font-bold uppercase tracking-wide text-muted">No. Retur</p>
                        <p class="font-display text-xl font-bold text-ink">{{ refund.refund_number }}</p>
                    </div>
                    <div>
                        <p class="text-[11px] font-bold uppercase tracking-wide text-muted">No. Transaksi</p>
                        <Link :href="route('sales.show', refund.sale.id)" class="font-display text-xl font-bold text-violet-text underline">{{ refund.sale?.invoice_number }}</Link>
                    </div>
                    <div>
                        <p class="text-[11px] font-bold uppercase tracking-wide text-muted">Tanggal</p>
                        <p class="font-bold text-ink">{{ formatDateLong(refund.created_at) }}</p>
                    </div>
                    <div>
                        <p class="text-[11px] font-bold uppercase tracking-wide text-muted">Total Retur</p>
                        <p class="font-display text-xl font-bold text-ink">{{ formatRupiah(refund.total) }}</p>
                    </div>
                    <div class="sm:col-span-2">
                        <p class="text-[11px] font-bold uppercase tracking-wide text-muted">Alasan</p>
                        <p class="font-bold text-ink">{{ refund.reason }}</p>
                    </div>
                    <div>
                        <p class="text-[11px] font-bold uppercase tracking-wide text-muted">Dibuat oleh</p>
                        <p class="font-bold text-ink">{{ refund.creator?.name }}</p>
                    </div>
                    <div>
                        <p class="text-[11px] font-bold uppercase tracking-wide text-muted">Disetujui oleh</p>
                        <p class="font-bold text-ink">{{ refund.approvedBy?.name }}</p>
                    </div>
                </div>
            </Card>

            <div class="mt-6 overflow-x-auto border-2 border-ink bg-surface shadow-hard">
                <div class="border-b-2 border-ink bg-surface-2 px-4 py-3">
                    <h2 class="font-display text-lg font-bold text-ink">Item Retur</h2>
                </div>
                <table class="w-full text-sm">
                    <thead>
                        <tr>
                            <th class="px-4 py-2 text-[11px] font-bold uppercase text-muted">Produk</th>
                            <th class="px-4 py-2 text-[11px] font-bold uppercase text-muted text-right">Qty</th>
                            <th class="px-4 py-2 text-[11px] font-bold uppercase text-muted text-right">Nilai</th>
                            <th class="px-4 py-2 text-[11px] font-bold uppercase text-muted">Restok</th>
                        </tr>
                    </thead>
                    <tbody class="divide-y divide-line">
                        <tr v-for="item in refund.items" :key="item.id">
                            <td class="px-4 py-3 text-sm">{{ item.sale_item?.name_snapshot }}</td>
                            <td class="px-4 py-3 text-sm text-right">{{ Number(item.qty) }}</td>
                            <td class="px-4 py-3 text-sm text-right font-bold">{{ formatRupiah(item.amount) }}</td>
                            <td class="px-4 py-3 text-sm">{{ item.restock ? 'Ya' : 'Tidak' }}</td>
                        </tr>
                    </tbody>
                </table>
            </div>
        </div>
    </AuthenticatedLayout>
</template>
