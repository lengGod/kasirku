<script setup>
import AuthenticatedLayout from '@/Layouts/AuthenticatedLayout.vue';
import Card from '@/Components/Card.vue';
import PageHeader from '@/Components/PageHeader.vue';
import PrimaryButton from '@/Components/PrimaryButton.vue';
import Pagination from '@/Components/Pagination.vue';
import { Head, Link } from '@inertiajs/vue3';
import { formatDateLong, formatRupiah } from '@/Utils/format';

defineProps({ refunds: Object });
</script>

<template>
    <Head title="Daftar Retur" />

    <AuthenticatedLayout>
        <div class="bg-canvas min-h-screen py-8"><div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
            <PageHeader title="Daftar Retur" subtitle="Data transaksi retur barang.">
                <template #actions>
                    <PrimaryButton as="link" :href="route('refunds.create')">Buat Retur Baru</PrimaryButton>
                </template>
            </PageHeader>

            <Card class="shadow-hard">
                <div class="overflow-x-auto">
                <table class="w-full text-sm">
                    <thead>
                        <tr>
                            <th class="px-4 py-3 text-[11px] font-bold uppercase text-muted">No. Retur</th>
                            <th class="px-4 py-3 text-[11px] font-bold uppercase text-muted">No. Transaksi</th>
                            <th class="px-4 py-3 text-[11px] font-bold uppercase text-muted">Tanggal</th>
                            <th class="px-4 py-3 text-[11px] font-bold uppercase text-muted text-right">Total</th>
                            <th class="px-4 py-3 text-[11px] font-bold uppercase text-muted text-right"></th>
                        </tr>
                    </thead>
                    <tbody>
                        <tr v-if="!refunds.data?.length">
                            <td colspan="5" class="px-4 py-10 text-center text-sm text-muted">Belum ada retur.</td>
                        </tr>
                        <tr v-for="refund in refunds.data" :key="refund.id" class="hover:bg-surface-2">
                            <td class="px-4 py-3 text-sm font-bold text-ink">{{ refund.refund_number }}</td>
                            <td class="px-4 py-3 text-sm">{{ refund.sale?.invoice_number }}</td>
                            <td class="px-4 py-3 text-sm text-muted">{{ formatDateLong(refund.created_at) }}</td>
                            <td class="px-4 py-3 text-sm text-right font-bold">{{ formatRupiah(refund.total) }}</td>
                            <td class="px-4 py-3 text-right">
                                <div class="inline-flex items-center border-2 border-ink bg-surface shadow-hard">
                                    <Link :href="route('refunds.show', refund.id)" class="inline-flex h-9 items-center px-3 text-xs font-semibold text-ink hover:bg-hi">Detail</Link>
                                </div>
                            </td>
                        </tr>
                    </tbody>
                </table>
                </div>
                <Pagination :paginator="refunds" />
            </Card>
        </div></div>
    </AuthenticatedLayout>
</template>
