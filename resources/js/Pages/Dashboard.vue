<script setup>
import AuthenticatedLayout from '@/Layouts/AuthenticatedLayout.vue';
import Card from '@/Components/Card.vue';
import PrimaryButton from '@/Components/PrimaryButton.vue';
import SecondaryButton from '@/Components/SecondaryButton.vue';
import { Head } from '@inertiajs/vue3';
import { usePage } from '@inertiajs/vue3';
import { computed } from 'vue';
import { formatDateLong, formatDateShort, formatNumber } from '@/Utils/format';
import { useAuthorization } from '@/Utils/authorization';
import MovementChart from '@/Components/MovementChart.vue';
import { ChartColumn, Clock, Package, TrendingUp, TriangleAlert, Wallet } from '@lucide/vue';

const page = usePage();
const { can } = useAuthorization();
const user = computed(() => page.props.auth.user);
const stats = computed(() => page.props.stats);
const expiringBatches = computed(() => page.props.expiringBatches);
const lowStockItems = computed(() => page.props.lowStockItems);
const recentMovements = computed(() => page.props.recentMovements);
const movementChart = computed(() => page.props.movementChart ?? { labels: [], in: [], out: [] });

const cardTone = (color) => ({
    lime: 'lime',
    'violet-text': 'violet',
    'yellow-400': 'yellow',
    'red-400': 'red',
}[color] || 'lime');

const cardTextClasses = (color) => ({
    lime: 'text-ink',
    'violet-text': 'text-white',
    'yellow-400': 'text-ink',
    'red-400': 'text-ink',
}[color] || 'text-ink');

const cardLabelClasses = (color) => ({
    lime: 'text-ink/70',
    'violet-text': 'text-white/80',
    'yellow-400': 'text-ink/70',
    'red-400': 'text-ink/70',
}[color] || 'text-ink/70');

const cardAccentClasses = (color) => ({
    lime: 'bg-ink',
    'violet-text': 'bg-white',
    'yellow-400': 'bg-ink',
    'red-400': 'bg-ink',
}[color] || 'bg-ink');

const iconMap = {
    package: Package,
    wallet: Wallet,
    alert: TriangleAlert,
    clock: Clock,
    trending: TrendingUp,
    chart: ChartColumn,
};

const getIcon = (iconName) => iconMap[iconName] || Package;

const valueClasses = (value) => (String(value).length > 9 ? 'text-2xl sm:text-3xl' : 'text-4xl');

const getMovementTypeLabel = (type) => {
    const labels = {
        'in': 'Masuk',
        'out': 'Keluar',
        'adjust': 'Penyesuaian',
    };
    return labels[type] || type;
};

const getMovementTypeColor = (type) => {
    const colors = {
        'in': 'text-lime',
        'out': 'text-red-400',
        'adjust': 'text-yellow-400',
    };
    return colors[type] || 'text-ink';
};
</script>

<template>
    <Head title="Dashboard" />

    <AuthenticatedLayout>
        <div class="bg-canvas min-h-screen py-8">
            <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
                <!-- Header -->
                <div class="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4 mb-8">
                    <div>
                        <p class="text-muted text-sm">Selamat pagi</p>
                        <h1 class="text-display font-bold text-3xl sm:text-4xl text-ink">{{ user.name }}</h1>
                    </div>
                    <div class="flex flex-col sm:flex-row gap-3 w-full sm:w-auto">
                        <SecondaryButton class="w-full sm:w-auto">Pencarian Global</SecondaryButton>
                        <PrimaryButton v-if="can('manage_transactions')" as="link" :href="route('stock-ins.create')" class="w-full sm:w-auto">+ Barang Masuk</PrimaryButton>
                    </div>
                </div>

                <!-- Stat Cards Grid -->
                <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4 mb-8">
                    <Card v-for="(stat, idx) in stats" :key="idx" :tone="cardTone(stat.color)" class="flex flex-col justify-between relative overflow-hidden group hover:shadow-hard transition">
                        <!-- Background accent -->
                        <div :class="['absolute -top-8 -right-8 w-28 h-28 rounded-full opacity-10 group-hover:opacity-20 transition', cardAccentClasses(stat.color)]"></div>

                        <div class="relative z-10">
                            <div :class="['text-xs font-semibold mb-3 flex items-center gap-2', cardLabelClasses(stat.color)]">
                                <component :is="getIcon(stat.icon)" class="w-4 h-4" />
                                {{ stat.label }}
                            </div>
                            <div :class="['font-bold font-display leading-tight', cardTextClasses(stat.color), valueClasses(stat.value)]">{{ stat.value }}</div>
                        </div>
                    </Card>
                </div>

                <!-- Charts & Quick Lists -->
                <div class="grid grid-cols-1 lg:grid-cols-2 gap-6 mb-8">
                    <!-- Grafik Masuk vs Keluar -->
                    <Card tone="lime-soft" class="relative overflow-hidden">
                        <div class="absolute top-0 left-0 w-1 h-full bg-lime"></div>
                        <div class="flex items-center gap-2 mb-4">
                            <span class="w-5 h-5 text-lime"><component :is="getIcon('trending')" class="w-5 h-5" /></span>
                            <h2 class="text-xl font-bold text-ink font-display">Masuk vs Keluar (30 hari)</h2>
                        </div>
                        <div class="bg-surface border-2 border-line p-3">
                            <MovementChart
                                :labels="movementChart.labels"
                                :in-data="movementChart.in"
                                :out-data="movementChart.out"
                            />
                        </div>
                    </Card>

                    <!-- Segera Kedaluwarsa -->
                    <Card tone="red-soft" class="relative overflow-hidden">
                        <div class="absolute top-0 left-0 w-1 h-full bg-red-400"></div>
                        <div class="flex justify-between items-center mb-4">
                            <div class="flex items-center gap-2">
                                <span class="w-5 h-5 text-red-400"><component :is="getIcon('clock')" class="w-5 h-5" /></span>
                                <h2 class="text-xl font-bold text-ink font-display">Segera Kedaluwarsa</h2>
                            </div>
                            <a href="#" class="text-violet-text text-sm font-semibold hover:underline">Lihat semua</a>
                        </div>
                        <div v-if="expiringBatches.length === 0" class="text-muted text-sm py-8 text-center">
                            <component :is="getIcon('package')" class="w-8 h-8 mx-auto mb-2" />
                            Belum ada batch yang mendekati kedaluwarsa. Bagus!
                        </div>
                        <div v-else class="space-y-2">
                            <div v-for="batch in expiringBatches" :key="batch.batch" class="flex justify-between items-center p-3 bg-surface rounded border-l-2 border-red-400">
                                <div>
                                    <p class="text-sm font-semibold text-ink">{{ batch.product }}</p>
                                    <p class="text-xs text-muted">{{ batch.batch }}</p>
                                </div>
                                <span :class="['text-sm font-semibold', batch.daysLeft <= 7 ? 'text-red-400' : 'text-muted']">{{ formatDateLong(batch.expiry_date) }}</span>
                            </div>
                        </div>
                    </Card>
                </div>

                <!-- Low Stock & Recent Movements -->
                <div class="grid grid-cols-1 lg:grid-cols-2 gap-6">
                    <!-- Stok Menipis -->
                    <Card tone="yellow-soft" class="relative overflow-hidden">
                        <div class="absolute top-0 left-0 w-1 h-full bg-yellow-400"></div>
                        <div class="flex items-center gap-2 mb-4">
                            <span class="w-5 h-5 text-yellow-400"><component :is="getIcon('alert')" class="w-5 h-5" /></span>
                            <h2 class="text-xl font-bold text-ink font-display">Stok Menipis</h2>
                        </div>
                        <div v-if="lowStockItems.length === 0" class="text-muted text-sm py-8 text-center">
                            <component :is="getIcon('package')" class="w-8 h-8 mx-auto mb-2" />
                            Tidak ada barang dengan stok menipis
                        </div>
                        <div v-else class="space-y-2">
                            <div v-for="item in lowStockItems" :key="item.name" class="flex justify-between items-center p-3 bg-surface rounded border-l-2 border-yellow-400">
                                <div>
                                    <p class="text-sm font-semibold text-ink">{{ item.name }}</p>
                                    <p class="text-xs text-muted">{{ formatNumber(item.current) }} / {{ formatNumber(item.minimum) }} unit</p>
                                </div>
                                <span class="text-red-400 font-bold text-sm">-{{ item.shortage }}</span>
                            </div>
                        </div>
                    </Card>

                    <!-- Mutasi Terbaru -->
                    <Card tone="violet-soft" class="relative overflow-hidden">
                        <div class="absolute top-0 left-0 w-1 h-full bg-violet-text"></div>
                        <div class="flex items-center gap-2 mb-4">
                            <span class="w-5 h-5 text-violet-text"><component :is="getIcon('chart')" class="w-5 h-5" /></span>
                            <h2 class="text-xl font-bold text-ink font-display">Mutasi Terbaru</h2>
                        </div>
                        <div v-if="recentMovements.length === 0" class="text-muted text-sm py-8 text-center">
                            <component :is="getIcon('package')" class="w-8 h-8 mx-auto mb-2" />
                            Belum ada transaksi
                        </div>
                        <div v-else class="space-y-2">
                            <div v-for="(movement, idx) in recentMovements" :key="idx" class="flex justify-between items-center p-3 bg-surface rounded border-l-2 border-violet-text">
                                <div>
                                    <p class="text-sm font-semibold text-ink">{{ movement.product }}</p>
                                    <p :class="['text-xs', getMovementTypeColor(movement.type)]">{{ getMovementTypeLabel(movement.type) }}</p>
                                </div>
                                <div class="text-right">
                                    <p class="text-sm font-semibold text-ink">{{ formatNumber(movement.quantity) }}</p>
                                    <p class="text-xs text-muted">{{ formatDateShort(movement.date) }}</p>
                                </div>
                            </div>
                        </div>
                    </Card>
                </div>
            </div>
        </div>
    </AuthenticatedLayout>
</template>
