<script setup>
import AuthenticatedLayout from '@/Layouts/AuthenticatedLayout.vue';
import Card from '@/Components/Card.vue';
import PageHeader from '@/Components/PageHeader.vue';
import { Head } from '@inertiajs/vue3';
import { formatDateLong, formatRupiah, formatNumber } from '@/Utils/format';
import { Link } from '@inertiajs/vue3';
import { Package, CheckCircle } from '@lucide/vue';

defineProps({ shifts: Object, openShift: Object });
</script>

<template>
    <Head title="Shift Kasir" />

    <AuthenticatedLayout>
        <div class="bg-canvas min-h-screen py-8"><div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
            <PageHeader title="Shift Kasir" subtitle="Kelola pengaturan kas harian.">
                <template #actions>
                    <PrimaryButton as="link" :href="route('shifts.open')">
                        <Package class="h-4 w-4" /> Buka Shift
                    </PrimaryButton>
                </template>
            </PageHeader>

            <div class="mb-6">
                <div v-if="openShift" class="border-2 border-ink bg-ink p-4 text-white shadow-hard">
                    <div class="mb-2 font-display text-lg font-bold">Shift Saat Ini</div>
                    <div class="grid gap-2 sm:grid-cols-2 lg:grid-cols-4 text-sm">
                        <div>
                            <p class="text-white/70">Kasir</p>
                            <p class="font-semibold">{{ openShift.user?.name }}</p>
                        </div>
                        <div>
                            <p class="text-white/70">Dibuka</p>
                            <p class="font-semibold">{{ formatDateLong(openShift.opened_at) }}</p>
                        </div>
                        <div>
                            <p class="text-white/70">Modal Awal</p>
                            <p class="font-bold text-lime">{{ formatRupiah(openShift.opening_cash) }}</p>
                        </div>
                        <div>
                            <p class="text-white/70">Status</p>
                            <span class="inline-flex h-7 items-center gap-1 px-2 py-0.5 border border-lime text-xs font-bold text-lime bg-lime/10">
                                <CheckCircle class="h-3 w-3" /> Terbuka
                            </span>
                        </div>
                    </div>
                    <div class="mt-4 flex gap-2">
                        <Link :href="route('pos.index')" class="flex-1 inline-flex items-center justify-center border border-lime bg-lime px-4 py-2 text-xs font-bold text-ink hover:bg-yellow-400 transition">Buka Layar Kasir</Link>
                        <Link :href="route('shifts.close')" class="flex-1 inline-flex items-center justify-center border-2 border-ink px-4 py-2 text-xs font-bold text-ink hover:bg-hi transition">Tutup Shift</Link>
                    </div>
                </div>

                <div v-else class="mb-6 border-2 border-ink bg-surface p-4 shadow-hard text-sm text-muted">
                    Tidak ada shift terbuka. <Link :href="route('shifts.open')" class="font-bold underline">Buka shift</Link> untuk memulai penjualan.
                </div>
            </div>

            <Card class="shadow-hard">
                <div class="overflow-x-auto">
                <table class="w-full text-sm">
                    <thead class="bg-ink">
                        <tr>
                            <th class="px-4 py-3 text-[11px] font-bold uppercase text-white">ID</th>
                            <th class="px-4 py-3 text-[11px] font-bold uppercase text-white">Kasir</th>
                            <th class="px-4 py-3 text-[11px] font-bold uppercase text-white">Dibuka</th>
                            <th class="px-4 py-3 text-[11px] font-bold uppercase text-white">Ditutup</th>
                            <th class="px-4 py-3 text-[11px] font-bold uppercase text-white">Transaksi</th>
                            <th class="px-4 py-3 text-[11px] font-bold uppercase text-white">Total</th>
                            <th class="px-4 py-3 text-[11px] font-bold uppercase text-white">Status</th>
                            <th class="px-4 py-3 text-[11px] font-bold uppercase text-white"></th>
                        </tr>
                    </thead>
                    <tbody class="divide-y divide-line">
                        <tr v-for="shift in shifts.data" :key="shift.id" class="hover:bg-surface-2">
                            <td class="px-4 py-3 text-sm text-ink">{{ shift.id }}</td>
                            <td class="px-4 py-3 text-sm">{{ shift.user?.name }}</td>
                            <td class="px-4 py-3 text-sm">{{ formatDateLong(shift.opened_at) }}</td>
                            <td class="px-4 py-3 text-sm">{{ shift.closed_at ? formatDateLong(shift.closed_at) : '-' }}</td>
                            <td class="px-4 py-3 text-sm">{{ formatNumber(shift.sales_count ?? 0, 0) }}</td>
                            <td class="px-4 py-3 text-sm">{{ formatRupiah(shift.sales_total ?? 0) }}</td>
                            <td class="px-4 py-3">
                                <span :class="['inline-flex h-7 items-center gap-1 px-2 py-0.5 border text-xs font-bold', shift.status === 'open' ? 'border-lime bg-lime/10 text-lime' : 'border-ink text-ink']">
                                    {{ shift.status === 'open' ? 'Terbuka' : 'Ditutup' }}
                                </span>
                            </td>
                            <td class="px-4 py-3">
                                <Link :href="route('shifts.show', shift.id)" class="text-sm font-semibold text-violet-text underline">Detail</Link>
                            </td>
                        </tr>
                    </tbody>
                </table>

                <div v-if="shifts.last_page > 1" class="mt-4 flex justify-center">
                    <pagination :paginator="shifts" />
                </div>
                </div>
            </Card>
        </div>
        </div>
    </AuthenticatedLayout>
</template>
