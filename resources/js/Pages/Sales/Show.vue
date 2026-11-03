<script setup>
import AuthenticatedLayout from '@/Layouts/AuthenticatedLayout.vue';
import PageHeader from '@/Components/PageHeader.vue';
import Card from '@/Components/Card.vue';
import FormInput from '@/Components/FormInput.vue';
import PrimaryButton from '@/Components/PrimaryButton.vue';
import StatusChip from '@/Components/StatusChip.vue';
import { Head, Link, useForm } from '@inertiajs/vue3';
import { formatDateLong, formatRupiah } from '@/Utils/format';
import { useAuthorization } from '@/Utils/authorization';
import { AlertTriangle } from '@lucide/vue';

const props = defineProps({
    sale: Object,
    statuses: {
        type: Array,
        default: () => [],
    },
});
const { can } = useAuthorization();

const statusLabel = (status) => props.statuses.find((item) => item.value === status)?.label ?? status;

const voidForm = useForm({
    reason: '',
    pin: '',
});

const submitVoid = () => {
    voidForm.post(route('sales.void', props.sale.id), {
        preserveScroll: true,
        onSuccess: () => voidForm.reset(),
    });
};
</script>

<template>
    <Head :title="`Struk ${sale.invoice_number}`" />

    <AuthenticatedLayout>
        <div class="mx-auto max-w-7xl px-4 py-8 sm:px-6 lg:px-8">
            <PageHeader :title="`Struk ${sale.invoice_number}`" subtitle="Detail transaksi penjualan.">
                <template #actions>
                    <div class="flex flex-wrap gap-2">
                        <a :href="route('sales.pdf', sale.id)" class="inline-flex h-10 items-center gap-2 border-2 border-ink bg-surface px-4 text-xs font-semibold hover:bg-hi">Unduh PDF</a>
                        <Link :href="route('sales.receipt', sale.id)" class="inline-flex h-10 items-center gap-2 border-2 border-ink bg-surface px-4 text-xs font-semibold hover:bg-hi">Cetak Ulang</Link>
                        <Link :href="route('pos.index')" class="inline-flex h-10 items-center gap-2 border-2 border-ink bg-lime px-4 text-xs font-semibold text-ink hover:bg-yellow-400">Kembali POS</Link>
                    </div>
                </template>
            </PageHeader>

            <Card tone="surface">
                <div class="grid grid-cols-1 gap-4 sm:grid-cols-2 lg:grid-cols-4">
                    <div>
                        <p class="text-[11px] font-bold uppercase tracking-wide text-muted">No. Struk</p>
                        <p class="font-display text-2xl font-bold text-ink">{{ sale.invoice_number }}</p>
                    </div>
                    <div>
                        <p class="text-[11px] font-bold uppercase tracking-wide text-muted">Tanggal</p>
                        <p class="font-bold text-ink">{{ formatDateLong(sale.created_at) }}</p>
                    </div>
                    <div>
                        <p class="text-[11px] font-bold uppercase tracking-wide text-muted">Kasir</p>
                        <p class="font-bold text-ink">{{ sale.cashier?.name }}</p>
                    </div>
                    <div>
                        <p class="text-[11px] font-bold uppercase tracking-wide text-muted">Pelanggan</p>
                        <p class="font-bold text-ink">{{ sale.customer?.name ?? 'Umum' }}</p>
                    </div>
                    <div class="col-span-full">
                        <p class="text-[11px] font-bold uppercase tracking-wide text-muted">Status</p>
                        <StatusChip :status="sale.status === 'partial_refund' ? 'adj' : sale.status">
                            {{ statusLabel(sale.status) }}
                        </StatusChip>
                    </div>
                    <div v-if="sale.status === 'voided'" class="col-span-full border-t-2 border-ink pt-3">
                        <p class="text-[11px] font-bold uppercase tracking-wide text-muted">Alasan Void</p>
                        <p class="font-bold text-ink">{{ sale.void_reason }}</p>
                        <p class="text-[11px] text-muted">Void oleh {{ sale.voidedBy?.name }} pada {{ sale.voided_at ? formatDateLong(sale.voided_at) : '-' }}</p>
                    </div>
                </div>
            </Card>

            <Card tone="surface" class="mt-6">
                <div class="mb-4 flex items-center justify-between">
                    <h2 class="font-display text-lg font-bold text-ink">Item</h2>
                </div>
                <div class="overflow-x-auto">
                    <table class="w-full text-sm">
                        <thead class="bg-surface-2">
                            <tr>
                                <th class="px-4 py-3 text-[11px] font-bold uppercase text-muted">Produk</th>
                                <th class="px-4 py-3 text-[11px] font-bold uppercase text-muted text-right">Qty</th>
                                <th class="px-4 py-3 text-[11px] font-bold uppercase text-muted text-right">Harga</th>
                                <th class="px-4 py-3 text-[11px] font-bold uppercase text-muted text-right">Diskon</th>
                                <th class="px-4 py-3 text-[11px] font-bold uppercase text-muted text-right">Total</th>
                            </tr>
                        </thead>
                        <tbody class="divide-y divide-line">
                            <tr v-if="!sale.items?.length">
                                <td colspan="5" class="px-4 py-10 text-center text-sm text-muted">Belum ada item.</td>
                            </tr>
                            <tr v-for="item in sale.items" :key="item.id">
                                <td class="px-4 py-3 text-sm">{{ item.name_snapshot }}</td>
                                <td class="px-4 py-3 text-sm text-right">{{ Number(item.qty) }}</td>
                                <td class="px-4 py-3 text-sm text-right">{{ formatRupiah(item.unit_price) }}</td>
                                <td class="px-4 py-3 text-sm text-right">-{{ formatRupiah(item.discount) }}</td>
                                <td class="px-4 py-3 text-sm font-bold text-right">{{ formatRupiah(item.line_total) }}</td>
                            </tr>
                        </tbody>
                    </table>
                </div>
            </Card>

            <div class="mt-6 grid grid-cols-1 gap-6 sm:grid-cols-2">
                <Card tone="surface">
                    <h2 class="mb-4 font-display text-lg font-bold text-ink">Pembayaran</h2>
                    <div class="space-y-2">
                        <div v-for="payment in sale.payments" :key="payment.id" class="flex items-center justify-between gap-2 border-b border-line pb-2 last:border-0 last:pb-0">
                            <span class="text-sm text-ink">{{ payment.payment_method?.name }}</span>
                            <span class="text-sm font-bold text-right text-ink">{{ formatRupiah(payment.amount) }}</span>
                        </div>
                        <div class="mt-2 flex justify-between border-t-2 border-ink pt-2">
                            <span class="text-sm font-semibold text-muted">Dibayar</span>
                            <span class="text-sm font-bold text-right text-ink">{{ formatRupiah(sale.paid_total) }}</span>
                        </div>
                        <div class="flex justify-between border-t border-line pt-1">
                            <span class="text-sm text-muted">Kembalian</span>
                            <span class="text-sm font-bold text-right text-ink">{{ formatRupiah(sale.change_amount) }}</span>
                        </div>
                    </div>
                </Card>

                <Card tone="surface">
                    <h2 class="mb-4 font-display text-lg font-bold text-ink">Rincian Tagihan</h2>
                    <dl class="space-y-2 text-sm">
                        <div class="flex justify-between"><span class="text-muted">Subtotal</span><span class="text-right font-bold text-ink">{{ formatRupiah(sale.subtotal) }}</span></div>
                        <div v-if="Number(sale.discount_total)" class="flex justify-between"><span class="text-muted">Diskon</span><span class="text-right font-bold text-ink">-{{ formatRupiah(sale.discount_total) }}</span></div>
                        <div class="flex justify-between"><span class="text-muted">Pajak</span><span class="text-right font-bold text-ink">{{ formatRupiah(sale.tax_total) }}</span></div>
                        <div v-if="Number(sale.rounding)" class="flex justify-between"><span class="text-muted">Pembulatan</span><span class="text-right font-bold text-ink">{{ formatRupiah(sale.rounding) }}</span></div>
                        <div class="flex justify-between border-t-2 border-ink pt-2">
                            <span class="text-sm font-bold text-ink">Grand Total</span>
                            <span class="text-sm font-bold text-right text-violet-text">{{ formatRupiah(sale.grand_total) }}</span>
                        </div>
                    </dl>
                </Card>
            </div>

            <Card v-if="sale.status === 'paid' && can('approve')" tone="surface" class="mt-6">
                <div class="mb-4 flex items-center gap-2 text-bad-fg">
                    <AlertTriangle class="h-5 w-5" />
                    <h2 class="font-display text-lg font-bold">Void Transaksi</h2>
                </div>
                <form class="grid grid-cols-1 gap-3 sm:grid-cols-[1fr_180px_auto]" @submit.prevent="submitVoid">
                    <div>
                        <FormInput v-model="voidForm.reason" required placeholder="Alasan void (min. 5 karakter)" />
                        <p v-if="voidForm.errors.reason" class="mt-1 text-xs font-semibold text-bad-fg">{{ voidForm.errors.reason }}</p>
                    </div>
                    <div>
                        <FormInput v-model="voidForm.pin" type="password" required placeholder="PIN supervisor" />
                        <p v-if="voidForm.errors.pin" class="mt-1 text-xs font-semibold text-bad-fg">{{ voidForm.errors.pin }}</p>
                    </div>
                    <PrimaryButton type="submit" :processing="voidForm.processing" class="bg-bad-fg hover:bg-red-600">
                        Void
                    </PrimaryButton>
                </form>
            </Card>
        </div>
    </AuthenticatedLayout>
</template>
