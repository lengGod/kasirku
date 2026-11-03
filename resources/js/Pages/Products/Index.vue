<script setup>
import AuthenticatedLayout from '@/Layouts/AuthenticatedLayout.vue';
import PageHeader from '@/Components/PageHeader.vue';
import FormInput from '@/Components/FormInput.vue';
import FormSelect from '@/Components/FormSelect.vue';
import PrimaryButton from '@/Components/PrimaryButton.vue';
import Pagination from '@/Components/Pagination.vue';
import DeleteConfirm from '@/Components/DeleteConfirm.vue';
import { Head, Link, router } from '@inertiajs/vue3';
import { formatNumber, formatRupiah } from '@/Utils/format';
import { useAuthorization } from '@/Utils/authorization';
import { Plus, Search } from '@lucide/vue';
import { ref, watch } from 'vue';

const props = defineProps({ products: Object, categories: Array, filters: Object });
const { can } = useAuthorization();

const search = ref(props.filters?.search ?? '');
const categoryId = ref(props.filters?.category_id ?? '');
const activeOnly = ref(props.filters?.active_only ?? true);
const deleting = ref(null);

const applyFilters = () => {
    router.get(route('products.index'), {
        search: search.value,
        category_id: categoryId.value,
        active_only: activeOnly.value ? 1 : 0,
    }, { preserveState: true, replace: true, preserveScroll: true });
};

watch([categoryId, activeOnly], applyFilters);

let timer = null;
watch(search, () => {
    clearTimeout(timer);
    timer = setTimeout(applyFilters, 350);
});

const destroy = () => {
    if (!deleting.value) return;
    router.delete(route('products.destroy', deleting.value.id), {
        onFinish: () => (deleting.value = null),
    });
};
</script>

<template>
    <Head title="Produk" />

    <AuthenticatedLayout>
        <div class="mx-auto max-w-7xl px-4 py-8 sm:px-6 lg:px-8">
            <PageHeader title="Produk" subtitle="Kelola katalog produk dan harga jual.">
                <template #actions>
                    <PrimaryButton v-if="can('manage_master_data')" as="link" :href="route('products.create')">
                        <Plus class="h-4 w-4" /> Tambah Produk
                    </PrimaryButton>
                </template>
            </PageHeader>

            <div class="mb-4 grid grid-cols-1 gap-3 border-2 border-ink bg-surface p-4 sm:grid-cols-[1fr_200px_auto]">
                <div class="relative">
                    <Search class="absolute left-3 top-1/2 h-4 w-4 -translate-y-1/2 text-muted" />
                    <input v-model="search" type="text" placeholder="Cari nama, SKU, barcode..." class="h-12 w-full border-2 border-ink bg-surface pl-10 pr-4 text-sm focus:border-violet-text focus:outline-none" />
                </div>
                <FormSelect v-model="categoryId">
                    <option value="">Semua Kategori</option>
                    <option v-for="category in categories" :key="category.id" :value="category.id">{{ category.name }}</option>
                </FormSelect>
                <label class="flex items-center gap-2 text-sm font-semibold text-ink">
                    <input v-model="activeOnly" type="checkbox" class="h-4 w-4 accent-lime" /> Hanya aktif
                </label>
            </div>

            <div class="relative overflow-x-auto border-2 border-ink bg-surface shadow-hard">
                <table class="w-full text-sm">
                    <thead>
                        <tr class="border-b-2 border-line">
                            <th class="py-3 px-4 font-semibold text-muted">Produk</th>
                            <th class="py-3 px-4 font-semibold text-muted">Kategori</th>
                            <th class="py-3 px-4 font-semibold text-muted text-right">Harga Jual</th>
                            <th class="py-3 px-4 font-semibold text-muted text-right">Stok</th>
                            <th class="py-3 px-4 font-semibold text-muted">Status</th>
                            <th class="py-3 px-4 font-semibold text-muted text-right">Aksi</th>
                        </tr>
                    </thead>
                    <tbody>
                        <tr v-if="!products.data.length">
                            <td colspan="6" class="px-4 py-10 text-center text-sm text-muted">Produk tidak ditemukan.</td>
                        </tr>
                        <tr v-for="product in products.data" :key="product.id" class="border-b border-surface-2 hover:bg-surface-2">
                            <td class="py-4 px-4">
                                <p class="text-sm font-bold text-ink">{{ product.name }}</p>
                                <p class="text-xs text-muted">{{ product.sku }} · {{ product.barcode ?? '-' }}</p>
                            </td>
                            <td class="py-4 px-4">{{ product.category?.name }} / {{ product.unit?.short_name }}</td>
                            <td class="py-4 px-4 text-right font-bold">{{ formatRupiah(product.sell_price) }}</td>
                            <td class="py-4 px-4 text-right">{{ formatNumber(product.stock_quantity, 0) }}</td>
                            <td class="py-4 px-4">
                                <span :class="['px-3 py-1 text-xs font-bold', product.is_active ? 'bg-ok-bg text-ok-fg' : 'bg-surface-2 text-muted']">{{ product.is_active ? 'Aktif' : 'Nonaktif' }}</span>
                            </td>
                            <td class="py-4 px-4 text-right">
                                <div class="inline-flex items-center border-2 border-ink bg-surface shadow-hard">
                                    <Link :href="route('products.show', product.id)" class="inline-flex h-9 items-center px-3 text-xs font-semibold text-ink hover:bg-hi">Detail</Link>
                                    <template v-if="can('manage_master_data')">
                                        <Link :href="route('products.edit', product.id)" class="inline-flex h-9 items-center border-l-2 border-ink px-3 text-xs font-semibold text-ink hover:bg-hi">Edit</Link>
                                        <button type="button" class="inline-flex h-9 items-center border-l-2 border-ink px-3 text-xs font-semibold text-bad-fg hover:bg-bad-bg" @click="deleting = product">Hapus</button>
                                    </template>
                                </div>
                            </td>
                        </tr>
                    </tbody>
                </table>
                <Pagination :paginator="products" />
            </div>
        </div>

        <DeleteConfirm :is-open="!!deleting" :message="`Hapus produk ${deleting?.name}?`" @confirm="destroy" @cancel="deleting = null" />
    </AuthenticatedLayout>
</template>
