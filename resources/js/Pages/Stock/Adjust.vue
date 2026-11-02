<script setup>
import AuthenticatedLayout from '@/Layouts/AuthenticatedLayout.vue';
import PageHeader from '@/Components/PageHeader.vue';
import FormInput from '@/Components/FormInput.vue';
import FormSelect from '@/Components/FormSelect.vue';
import PrimaryButton from '@/Components/PrimaryButton.vue';
import SecondaryButton from '@/Components/SecondaryButton.vue';
import { Head, useForm } from '@inertiajs/vue3';
import { formatNumber } from '@/Utils/format';
import { Plus, Trash2 } from '@lucide/vue';
import { ref } from 'vue';

const props = defineProps({ products: Array });

const form = useForm({
    reason: '',
    items: [{ product_id: '', qty_after: 0 }],
});

const addItem = () => {
    form.items.push({ product_id: '', qty_after: 0 });
};

const removeItem = (index) => {
    form.items.splice(index, 1);
};

const onProductChange = (index) => {
    const product = props.products.find((row) => row.id === Number(form.items[index].product_id));
    if (product) {
        form.items[index].qty_after = Number(product.stock_quantity ?? 0);
    }
};

const submit = () => {
    form.post(route('stock.adjust.store'));
};
</script>

<template>
    <Head title="Penyesuaian Baru" />

    <AuthenticatedLayout>
        <div class="mx-auto max-w-7xl px-4 py-8 sm:px-6 lg:px-8">
            <PageHeader title="Penyesuaian Baru" subtitle="Masukkan stok hasil hitung fisik.">
                <template #actions>
                    <SecondaryButton as="link" :href="route('stock.adjust.index')">Kembali</SecondaryButton>
                </template>
            </PageHeader>

            <form class="space-y-4 border-2 border-ink bg-surface p-5 shadow-hard" @submit.prevent="submit">
                <div>
                    <label class="mb-1 block text-sm font-semibold">Alasan Penyesuaian</label>
                    <FormInput v-model="form.reason" required placeholder="Contoh: Barang rusak / selisih stock opname" />
                </div>

                <div class="space-y-2">
                    <div class="flex items-center justify-between">
                        <h2 class="font-display text-lg font-bold">Item</h2>
                        <button type="button" class="inline-flex items-center gap-1 text-sm font-semibold text-violet-text underline" @click="addItem">
                            <Plus class="h-4 w-4" /> Tambah item
                        </button>
                    </div>

                    <div v-for="(item, index) in form.items" :key="index" class="grid gap-2 border-2 border-line p-3 sm:grid-cols-[1fr_140px_auto]">
                        <FormSelect v-model="item.product_id" required @change="onProductChange(index)">
                            <option value="">Pilih produk</option>
                            <option v-for="product in products" :key="product.id" :value="product.id">
                                {{ product.name }} (stok: {{ formatNumber(product.stock_quantity, 0) }})
                            </option>
                        </FormSelect>
                        <FormInput v-model="item.qty_after" type="number" min="0" step="0.001" placeholder="Stok akhir" required />
                        <button type="button" class="flex h-12 w-12 items-center justify-center border-2 border-ink text-bad-fg hover:bg-bad-bg" @click="removeItem(index)">
                            <Trash2 class="h-4 w-4" />
                        </button>
                    </div>
                </div>

                <div class="flex gap-2">
                    <SecondaryButton as="link" :href="route('stock.adjust.index')">Batal</SecondaryButton>
                    <PrimaryButton type="submit" :processing="form.processing">Simpan Penyesuaian</PrimaryButton>
                </div>
            </form>
        </div>
    </AuthenticatedLayout>
</template>
