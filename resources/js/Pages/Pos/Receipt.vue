<script setup>
import { Head, Link, router } from '@inertiajs/vue3';
import { formatDateLong, formatRupiah } from '@/Utils/format';
import { ArrowLeft, Download, Printer, Copy } from '@lucide/vue';

const props = defineProps({
    sale: Object,
    store: Object,
    isCopy: Boolean,
});

const printReceipt = () => {
    router.post(route('sales.print-log', props.sale.id), { is_copy: props.isCopy }, {
        preserveScroll: true,
        onSuccess: () => window.print(),
    });
};
</script>

<template>
    <Head :title="`Struk ${sale.invoice_number}`" />

    <div class="min-h-screen bg-canvas px-4 py-8 print:bg-white print:p-0">
        <div class="mx-auto max-w-md print:max-w-none">
            <div class="mb-4 flex flex-wrap items-center justify-between gap-2 print:hidden">
                <Link :href="route('pos.index')" class="inline-flex items-center gap-2 text-sm font-semibold text-ink hover:text-violet-text">
                    <ArrowLeft class="h-4 w-4" /> Kembali ke POS
                </Link>
                <div class="flex flex-wrap gap-2">
                    <a :href="route('sales.pdf', { sale: sale.id, copy: isCopy ? 1 : 0 })" class="inline-flex h-10 items-center gap-2 border-2 border-ink bg-surface px-4 text-xs font-semibold hover:bg-hi">
                        <Download class="h-4 w-4" /> PDF
                    </a>
                    <Link :href="route('sales.receipt', { sale: sale.id, copy: 1 })" class="inline-flex h-10 items-center gap-2 border-2 border-ink bg-surface px-4 text-xs font-semibold hover:bg-hi">
                        <Copy class="h-4 w-4" /> Salinan
                    </Link>
                    <button type="button" class="inline-flex h-10 items-center gap-2 border-2 border-ink bg-lime px-4 text-xs font-semibold text-ink hover:bg-yellow-400" @click="printReceipt">
                        <Printer class="h-4 w-4" /> Cetak
                    </button>
                </div>
            </div>

            <div class="mx-auto w-full max-w-[320px] border-2 border-ink bg-white p-5 text-[11px] leading-relaxed text-ink shadow-hard print:border-0 print:shadow-none">
                <div class="text-center">
                    <p class="font-display text-lg font-bold">{{ store.name }}</p>
                    <p v-if="store.address">{{ store.address }}</p>
                    <p v-if="store.phone">{{ store.phone }}</p>
                    <p v-if="isCopy" class="mt-1 inline-block bg-ink px-2 py-0.5 text-[10px] font-bold text-lime">SALINAN</p>
                </div>

                <div class="my-3 border-t border-dashed border-ink"></div>

                <div class="space-y-0.5">
                    <div class="flex justify-between"><span>No.</span><span>{{ sale.invoice_number }}</span></div>
                    <div class="flex justify-between"><span>Tanggal</span><span>{{ formatDateLong(sale.created_at) }}</span></div>
                    <div class="flex justify-between"><span>Kasir</span><span>{{ sale.cashier?.name }}</span></div>
                    <div class="flex justify-between"><span>Pelanggan</span><span>{{ sale.customer?.name ?? 'Umum' }}</span></div>
                </div>

                <div class="my-3 border-t border-dashed border-ink"></div>

                <div class="space-y-2">
                    <div v-for="item in sale.items" :key="item.id">
                        <p class="font-semibold">{{ item.name_snapshot }}</p>
                        <div class="flex justify-between">
                            <span>{{ Number(item.qty) }} x {{ formatRupiah(item.unit_price) }}</span>
                            <span>{{ formatRupiah(item.line_total) }}</span>
                        </div>
                        <p v-if="Number(item.discount)" class="text-right text-[10px]">Diskon -{{ formatRupiah(item.discount) }}</p>
                    </div>
                </div>

                <div class="my-3 border-t border-dashed border-ink"></div>

                <div class="space-y-0.5">
                    <div class="flex justify-between"><span>Subtotal</span><span>{{ formatRupiah(sale.subtotal) }}</span></div>
                    <div v-if="Number(sale.discount_total)" class="flex justify-between"><span>Diskon</span><span>-{{ formatRupiah(sale.discount_total) }}</span></div>
                    <div class="flex justify-between"><span>Pajak</span><span>{{ formatRupiah(sale.tax_total) }}</span></div>
                    <div v-if="Number(sale.rounding)" class="flex justify-between"><span>Pembulatan</span><span>{{ formatRupiah(sale.rounding) }}</span></div>
                    <div class="flex justify-between border-t border-ink pt-1 font-bold"><span>TOTAL</span><span>{{ formatRupiah(sale.grand_total) }}</span></div>
                </div>

                <div class="my-2 border-t border-dashed border-ink"></div>

                <div class="space-y-0.5">
                    <div v-for="payment in sale.payments" :key="payment.id" class="flex justify-between">
                        <span>{{ payment.payment_method?.name }}</span>
                        <span>{{ formatRupiah(payment.amount) }}</span>
                    </div>
                    <div class="flex justify-between font-semibold"><span>Kembalian</span><span>{{ formatRupiah(sale.change_amount) }}</span></div>
                </div>

                <div class="my-3 border-t border-dashed border-ink"></div>

                <p class="text-center">{{ store.footer }}</p>
                <p class="mt-2 text-center text-[10px]">Dicetak {{ new Date().toLocaleString('id-ID') }}</p>
            </div>
        </div>
    </div>
</template>