<script setup>
import AuthenticatedLayout from '@/Layouts/AuthenticatedLayout.vue';
import PageHeader from '@/Components/PageHeader.vue';
import FormInput from '@/Components/FormInput.vue';
import FormSelect from '@/Components/FormSelect.vue';
import PrimaryButton from '@/Components/PrimaryButton.vue';
import SecondaryButton from '@/Components/SecondaryButton.vue';
import { Head, useForm } from '@inertiajs/vue3';
import { Plus, Trash2 } from '@lucide/vue';
import { ref } from 'vue';

const props = defineProps({ products: Array });

const form = useForm({
    supplier_name: '',
    received_at: new Date().toISOString().slice(0, 10),
    note: '',
    items: [{ product_id: '', qty: 1, cost_price: 0 }],
});

const addItem = () => {
    form.items.push({ product_id: '', qty: 1, cost_price: 0 });
};

const removeItem = (index) => {
    form.items.splice(index, 1);
};

const onProductChange = (index) => {
    const product = props.products.find((row) => row.id === Number(form.items[index].product_id));
    if (product) {
        form.items[index].cost_price = Number(product.cost_price);
    }
};

const submit = () => {
    form.post(route('stock.receive.store'));
};
</script>

<template>
    <Head title="Penerimaan Baru" />

    <AuthenticatedLayout>
        <div class="mx-auto max-w-7xl px-4 py-8 sm:px-6 lg:px-8">
            <PageHeader title="Penerimaan Baru" subtitle="Catat stok yang masuk ke toko.">
                <template #actions>
                    <SecondaryButton as="link" :href="route('stock.receive.index')">Kembali</SecondaryButton>
                </template>
            </PageHeader>

            <form class="space-y-4 border-2 border-ink bg-surface p-5 shadow-hard" @submit.prevent="submit">
                <div class="grid grid-cols-1 gap-3 sm:grid-cols-3">
                    <div>
                        <label class="mb-1 block text-sm font-semibold">Supplier</label>
                        <FormInput v-model="form.supplier_name" placeholder="Nama supplier" />
                    </div>
                    <div>
                        <label class="mb-1 block text-sm font-semibold">Tanggal Terima</label>
                        <FormInput v-model="form.received_at" type="date" required />
                    </div>
                    <div>
                        <label class="mb-1 block text-sm font-semibold">Catatan</label>
                        <FormInput v-model="form.note" placeholder="Opsional" />
                    </div>
                </div>

                <div class="space-y-2">
                    <div class="flex items-center justify-between">
                        <h2 class="font-display text-lg font-bold">Item</h2>
                        <button type="button" class="inline-flex items-center gap-1 text-sm font-semibold text-violet-text underline" @click="addItem">
                            <Plus class="h-4 w-4" /> Tambah item
                        </button>
                    </div>

                    <div v-for="(item, index) in form.items" :key="index" class="grid grid-cols-1 gap-2 border-2 border-line p-3 sm:grid-cols-[1fr_120px_140px_auto]">
                        <FormSelect v-model="item.product_id" required @change="onProductChange(index)">
                            <option value="">Pilih produk</option>
                            <option v-for="product in products" :key="product.id" :value="product.id">{{ product.name }} ({{ product.unit?.short_name }})</option>
                        </FormSelect>
                        <FormInput v-model="item.qty" type="number" min="0.001" step="0.001" placeholder="Qty" required />
                        <FormInput v-model="item.cost_price" type="number" min="0" step="100" placeholder="Harga beli" />
                        <button type="button" class="flex h-12 w-12 items-center justify-center border-2 border-ink text-bad-fg hover:bg-bad-bg" @click="removeItem(index)">
                            <Trash2 class="h-4 w-4" />
                        </button>
                    </div>
                </div>

                <div class="flex gap-2">
                    <SecondaryButton as="link" :href="route('stock.receive.index')">Batal</SecondaryButton>
                    <PrimaryButton type="submit" :processing="form.processing">Simpan Penerimaan</PrimaryButton>
                </div>
            </form>
        </div>
    </AuthenticatedLayout>
</template>
