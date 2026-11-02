<script setup>
import FormInput from '@/Components/FormInput.vue';
import FormSelect from '@/Components/FormSelect.vue';
import PrimaryButton from '@/Components/PrimaryButton.vue';
import SecondaryButton from '@/Components/SecondaryButton.vue';
import InputError from '@/Components/InputError.vue';
import { useForm } from '@inertiajs/vue3';

const props = defineProps({
    product: { type: Object, default: null },
    categories: { type: Array, default: () => [] },
    units: { type: Array, default: () => [] },
});

const form = useForm({
    sku: props.product?.sku ?? '',
    barcode: props.product?.barcode ?? '',
    name: props.product?.name ?? '',
    category_id: props.product?.category_id ?? '',
    unit_id: props.product?.unit_id ?? '',
    cost_price: props.product?.cost_price ?? 0,
    sell_price: props.product?.sell_price ?? 0,
    is_taxable: props.product?.is_taxable ?? false,
    min_stock: props.product?.min_stock ?? 0,
    image: props.product?.image ?? '',
    track_stock: props.product?.track_stock ?? true,
    track_batch: props.product?.track_batch ?? false,
    track_expiry: props.product?.track_expiry ?? false,
    is_active: props.product?.is_active ?? true,
});

const submit = () => {
    if (props.product) {
        form.put(route('products.update', props.product.id));
        return;
    }

    form.post(route('products.store'));
};
</script>

<template>
    <form class="space-y-6" @submit.prevent="submit">
        <div class="grid gap-4 sm:grid-cols-2">
            <div>
                <label class="mb-1 block text-sm font-semibold text-ink">SKU <span class="text-bad-fg">*</span></label>
                <FormInput v-model="form.sku" required placeholder="MKN-001" />
                <InputError :message="form.errors.sku" class="mt-1" />
            </div>
            <div>
                <label class="mb-1 block text-sm font-semibold text-ink">Barcode</label>
                <FormInput v-model="form.barcode" placeholder="Opsional" />
                <InputError :message="form.errors.barcode" class="mt-1" />
            </div>
            <div class="sm:col-span-2">
                <label class="mb-1 block text-sm font-semibold text-ink">Nama Produk <span class="text-bad-fg">*</span></label>
                <FormInput v-model="form.name" required placeholder="Nama produk" />
                <InputError :message="form.errors.name" class="mt-1" />
            </div>
            <div>
                <label class="mb-1 block text-sm font-semibold text-ink">Kategori <span class="text-bad-fg">*</span></label>
                <FormSelect v-model="form.category_id" required>
                    <option value="">Pilih kategori</option>
                    <option v-for="category in categories" :key="category.id" :value="category.id">{{ category.name }}</option>
                </FormSelect>
                <InputError :message="form.errors.category_id" class="mt-1" />
            </div>
            <div>
                <label class="mb-1 block text-sm font-semibold text-ink">Satuan <span class="text-bad-fg">*</span></label>
                <FormSelect v-model="form.unit_id" required>
                    <option value="">Pilih satuan</option>
                    <option v-for="unit in units" :key="unit.id" :value="unit.id">{{ unit.name }} ({{ unit.short_name }})</option>
                </FormSelect>
                <InputError :message="form.errors.unit_id" class="mt-1" />
            </div>
            <div>
                <label class="mb-1 block text-sm font-semibold text-ink">Harga Beli</label>
                <FormInput v-model="form.cost_price" type="number" min="0" step="100" />
                <InputError :message="form.errors.cost_price" class="mt-1" />
            </div>
            <div>
                <label class="mb-1 block text-sm font-semibold text-ink">Harga Jual</label>
                <FormInput v-model="form.sell_price" type="number" min="0" step="100" />
                <InputError :message="form.errors.sell_price" class="mt-1" />
            </div>
            <div>
                <label class="mb-1 block text-sm font-semibold text-ink">Stok Minimum</label>
                <FormInput v-model="form.min_stock" type="number" min="0" />
                <InputError :message="form.errors.min_stock" class="mt-1" />
            </div>
            <div class="flex flex-col justify-end gap-2">
                <label class="flex items-center gap-2 text-sm font-semibold text-ink">
                    <input v-model="form.track_stock" type="checkbox" class="h-4 w-4 accent-lime" /> Lacak stok
                </label>
                <label class="flex items-center gap-2 text-sm font-semibold text-ink">
                    <input v-model="form.is_taxable" type="checkbox" class="h-4 w-4 accent-lime" /> Kena pajak
                </label>
                <label class="flex items-center gap-2 text-sm font-semibold text-ink">
                    <input v-model="form.is_active" type="checkbox" class="h-4 w-4 accent-lime" /> Aktif
                </label>
            </div>
        </div>

        <div class="flex gap-2">
            <SecondaryButton as="link" :href="route('products.index')">Batal</SecondaryButton>
            <PrimaryButton type="submit" :processing="form.processing">Simpan Produk</PrimaryButton>
        </div>
    </form>
</template>