<script setup>
import AuthenticatedLayout from '@/Layouts/AuthenticatedLayout.vue';
import Card from '@/Components/Card.vue';
import PageHeader from '@/Components/PageHeader.vue';
import PrimaryButton from '@/Components/PrimaryButton.vue';
import { Head, Link } from '@inertiajs/vue3';
import { formatRupiah, formatNumber } from '@/Utils/format';
import { ChartColumn, ShoppingCart, Wallet, Package, TrendingUp } from '@lucide/vue';
import { computed, onUnmounted, ref, watch } from 'vue';

const props = defineProps({
    summary: Object,
    chart: Array,
    topProducts: Array,
    lowStock: Array,
    openShift: Object,
    recentSales: Array,
});

const globalSearch = ref('');
const globalResults = ref([]);
let globalSearchTimer;

const runGlobalSearch = async () => {
    const search = globalSearch.value.trim();

    if (!search) {
        globalResults.value = [];
        return;
    }

    const response = await fetch(`${route('dashboard.search')}?search=${encodeURIComponent(search)}`, {
        headers: { Accept: 'application/json', 'X-Requested-With': 'XMLHttpRequest' },
    });

    if (response.ok) {
        globalResults.value = (await response.json()).results ?? [];
    }
};

watch(globalSearch, () => {
    clearTimeout(globalSearchTimer);
    globalSearchTimer = setTimeout(runGlobalSearch, 50);
});

onUnmounted(() => clearTimeout(globalSearchTimer));

const chartRows = computed(() => (Array.isArray(props.chart) ? props.chart : []).map((row) => ({
    ...row,
    total: Number(row.total) || 0,
})));

const chartMin = computed(() => chartRows.value.length ? Math.min(...chartRows.value.map((row) => row.total)) : 0);
const chartMax = computed(() => chartRows.value.length ? Math.max(...chartRows.value.map((row) => row.total)) : 1);
const chartBarHeight = (total) => {
    const range = chartMax.value - chartMin.value;

    return range > 0 ? Math.round(18 + ((total - chartMin.value) / range) * 122) : 70;
};
const growthLabel = computed(() => {
    if (props.summary.growth === null) return 'Belum ada pembanding';
    return `${props.summary.growth > 0 ? '+' : ''}${props.summary.growth}% vs kemarin`;
});
</script>

<template>
    <Head title="Dashboard" />

    <AuthenticatedLayout>
        <div class="mx-auto max-w-7xl px-4 py-8 sm:px-6 lg:px-8">
            <PageHeader title="Dashboard" subtitle="Ringkasan penjualan dan operasional toko hari ini.">
                <template #actions>
                    <div class="relative flex flex-wrap justify-end gap-2">
                        <form class="flex w-full sm:w-80" @submit.prevent="runGlobalSearch">
                            <input v-model="globalSearch" type="search" placeholder="Cari produk, pelanggan, struk..." class="h-12 min-w-0 flex-1 border-2 border-ink bg-surface px-3 text-sm text-ink focus:outline-none" />
                            <button type="submit" class="h-12 border-2 border-l-0 border-ink bg-ink px-4 text-xs font-bold text-white hover:bg-ink-3">Cari</button>
                        </form>
                        <div v-if="globalSearch.trim()" class="absolute right-0 top-14 z-30 w-full border-2 border-ink bg-surface p-2 text-left shadow-hard sm:w-80">
                            <Link v-for="result in globalResults" :key="result.type + result.url" :href="result.url" class="flex items-center justify-between gap-3 border-b border-line px-3 py-2 last:border-0 hover:bg-surface-2">
                                <span class="min-w-0"><span class="block truncate text-sm font-semibold text-ink">{{ result.label }}</span><span class="block truncate text-xs text-muted">{{ result.meta }}</span></span>
                                <span class="shrink-0 text-[10px] font-bold uppercase text-violet-text">{{ result.type }}</span>
                            </Link>
                            <p v-if="!globalResults.length" class="px-3 py-3 text-xs text-muted">Tidak ada hasil ditemukan.</p>
                        </div>
                        <PrimaryButton as="link" :href="route('pos.index')"><ShoppingCart class="h-4 w-4" /> Buka POS</PrimaryButton>
                    </div>
                </template>
            </PageHeader>

            <div v-if="!openShift" class="mb-6 border-2 border-ink bg-warn-bg p-4 text-sm text-warn-fg">
                Shift belum dibuka. Buka shift dulu sebelum transaksi.
                <a :href="route('shifts.open')" class="ml-2 font-bold underline">Buka shift</a>
            </div>

            <div class="grid grid-cols-1 gap-4 sm:grid-cols-2 lg:grid-cols-4">
                <div class="relative border-2 border-ink bg-lime p-5 shadow-hard">
                    <div class="mb-3 flex items-start justify-between">
                        <p class="text-[11px] font-bold uppercase tracking-[0.15em] text-ink/80">Penjualan Hari Ini</p>
                        <Wallet class="h-5 w-5 text-ink" />
                    </div>
                    <p class="font-display text-3xl font-bold text-ink">{{ formatRupiah(summary.today_total) }}</p>
                    <p class="mt-2 text-xs text-ink/70">{{ growthLabel }}</p>
                </div>

                <div class="relative border-2 border-ink bg-surface p-5 shadow-hard">
                    <div class="mb-3 flex items-start justify-between">
                        <p class="text-[11px] font-bold uppercase tracking-[0.15em] text-muted">Transaksi</p>
                        <ShoppingCart class="h-5 w-5 text-violet-text" />
                    </div>
                    <p class="font-display text-3xl font-bold text-ink">{{ formatNumber(summary.today_count, 0) }}</p>
                    <p class="mt-2 text-xs text-muted">Rata-rata {{ formatRupiah(summary.today_average) }}</p>
                </div>

                <div class="relative border-2 border-ink bg-surface p-5 shadow-hard">
                    <div class="mb-3 flex items-start justify-between">
                        <p class="text-[11px] font-bold uppercase tracking-[0.15em] text-muted">Kemarin</p>
                        <TrendingUp class="h-5 w-5 text-violet-text" />
                    </div>
                    <p class="font-display text-3xl font-bold text-ink">{{ formatRupiah(summary.yesterday_total) }}</p>
                    <p class="mt-2 text-xs text-muted">Total penjualan kemarin</p>
                </div>

                <div class="relative border-2 border-ink bg-ink p-5 shadow-hard">
                    <div class="mb-3 flex items-start justify-between">
                        <p class="text-[11px] font-bold uppercase tracking-[0.15em] text-lime">Shift</p>
                        <Package class="h-5 w-5 text-lime" />
                    </div>
                    <p class="font-display text-2xl font-bold text-white">{{ openShift ? 'Terbuka' : 'Tertutup' }}</p>
                    <p class="mt-2 text-xs text-white/60">
                        {{ openShift ? 'Mulai ' + new Date(openShift.opened_at).toLocaleTimeString('id-ID') : 'Buka shift untuk mulai jualan' }}
                    </p>
                </div>
            </div>

            <div class="mt-6 grid grid-cols-1 gap-6 lg:grid-cols-3">
                <Card class="lg:col-span-2">
                    <div class="mb-4 flex items-center justify-between">
                        <h2 class="font-display text-lg font-bold text-ink">Penjualan 7 Hari</h2>
                        <ChartColumn class="h-5 w-5 text-violet-text" />
                    </div>
                    <div v-if="chartRows.length" class="flex h-48 items-end gap-3">
                        <div v-for="row in chartRows" :key="row.label" class="flex min-w-0 flex-1 flex-col items-center gap-2">
                            <div class="flex h-40 w-full items-end">
                                <div class="w-full bg-violet-text transition-all" :style="{ height: `${chartBarHeight(row.total)}px` }" :title="formatRupiah(row.total)"></div>
                            </div>
                            <p class="w-full truncate text-center text-[8px] font-bold text-violet-text sm:text-[9px]" :title="formatRupiah(row.total)">{{ formatRupiah(row.total) }}</p>
                            <p class="w-full truncate text-center text-[10px] font-semibold text-muted">{{ row.label }}</p>
                        </div>
                    </div>
                    <p v-else class="py-16 text-center text-sm text-muted">Belum ada data penjualan.</p>
                </Card>

                <Card>
                    <h2 class="mb-4 font-display text-lg font-bold text-ink">Produk Terlaris</h2>
                    <div v-if="topProducts.length" class="space-y-3">
                        <div v-for="(product, index) in topProducts" :key="product.product_id" class="flex items-center gap-3 border-b border-line pb-3 last:border-0 last:pb-0">
                            <span class="flex h-7 w-7 flex-shrink-0 items-center justify-center bg-ink text-xs font-bold text-lime">{{ index + 1 }}</span>
                            <div class="min-w-0 flex-1">
                                <p class="truncate text-sm font-semibold text-ink">{{ product.name }}</p>
                                <p class="text-xs text-muted">{{ formatNumber(product.qty, 0) }} terjual</p>
                            </div>
                            <p class="shrink-0 text-xs font-bold text-ink">{{ formatRupiah(product.total) }}</p>
                        </div>
                    </div>
                    <p v-else class="text-sm text-muted">Belum ada penjualan.</p>
                </Card>
            </div>

            <div class="mt-6 grid grid-cols-1 gap-6 lg:grid-cols-2">
                <Card>
                    <h2 class="mb-4 font-display text-lg font-bold text-ink">Stok Menipis</h2>
                    <div v-if="lowStock.length" class="space-y-3">
                        <div v-for="product in lowStock" :key="product.id" class="flex items-center justify-between gap-3 border-b border-line pb-3 last:border-0 last:pb-0">
                            <div class="min-w-0">
                                <p class="truncate text-sm font-semibold text-ink">{{ product.name }}</p>
                                <p class="truncate text-xs text-muted">{{ product.category?.name }} · {{ product.unit?.short_name }}</p>
                            </div>
                            <span class="shrink-0 bg-bad-bg px-3 py-1 text-xs font-bold text-bad-fg">{{ formatNumber(product.stock_quantity, 0) }}</span>
                        </div>
                    </div>
                    <p v-else class="text-sm text-muted">Semua stok aman.</p>
                </Card>

                <Card>
                    <h2 class="mb-4 font-display text-lg font-bold text-ink">Transaksi Terakhir</h2>
                    <div v-if="recentSales.length" class="space-y-3">
                        <a v-for="sale in recentSales" :key="sale.id" :href="route('sales.show', sale.id)" class="flex items-center justify-between gap-3 border-b border-line pb-3 last:border-0 last:pb-0 hover:text-violet-text">
                            <div class="min-w-0">
                                <p class="truncate text-sm font-semibold text-ink">{{ sale.invoice_number }}</p>
                                <p class="truncate text-xs text-muted">{{ sale.cashier?.name }} · {{ sale.customer?.name ?? 'Umum' }}</p>
                            </div>
                            <p class="shrink-0 text-sm font-bold text-ink">{{ formatRupiah(sale.grand_total) }}</p>
                        </a>
                    </div>
                    <p v-else class="text-sm text-muted">Belum ada transaksi.</p>
                </Card>
            </div>
        </div>
    </AuthenticatedLayout>
</template>
