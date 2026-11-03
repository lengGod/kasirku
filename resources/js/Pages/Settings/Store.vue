<script setup>
import AuthenticatedLayout from '@/Layouts/AuthenticatedLayout.vue';
import PageHeader from '@/Components/PageHeader.vue';
import FormInput from '@/Components/FormInput.vue';
import MoneyInput from '@/Components/MoneyInput.vue';
import PrimaryButton from '@/Components/PrimaryButton.vue';
import SecondaryButton from '@/Components/SecondaryButton.vue';
import { Head, useForm, router } from '@inertiajs/vue3';

const props = defineProps({ settings: Object });

const form = useForm({ ...props.settings });

const submit = () => {
    form.put(route('settings.store.update'));
};
</script>

<template>
    <Head title="Pengaturan Toko" />

    <AuthenticatedLayout>
        <div class="mx-auto max-w-7xl px-4 py-8 sm:px-6 lg:px-8">
            <PageHeader title="Pengaturan Toko" subtitle="Nama toko, pajak, dan cetak struk." />
            <form class="space-y-4 border-2 border-ink bg-surface p-5 shadow-hard" @submit.prevent="submit">
                <div class="grid grid-cols-1 gap-3 sm:grid-cols-2">
                    <div>
                        <label class="mb-1 block text-sm font-semibold">Nama Toko</label>
                        <FormInput v-model="form.store_name" required />
                    </div>
                    <div class="sm:col-span-2">
                        <label class="mb-1 block text-sm font-semibold">Alamat</label>
                        <FormInput v-model="form.store_address" placeholder="Jl. Merdeka No. 1, Kota" />
                    </div>
                    <div>
                        <label class="mb-1 block text-sm font-semibold">Telepon</label>
                        <FormInput v-model="form.store_phone" placeholder="021-xxx-xxxx" />
                    </div>
                    <div class="sm:col-span-2">
                        <label class="mb-1 block text-sm font-semibold">Footer Struk</label>
                        <FormInput v-model="form.receipt_footer" placeholder="Terima kasih..." />
                    </div>
                    <div>
                        <label class="mb-1 block text-sm font-semibold">Pajak (%)</label>
                        <FormInput v-model="form.tax_rate" type="number" min="0" step="0.1" />
                    </div>
                    <div>
                        <label class="flex items-center gap-2 text-sm font-semibold">
                            <input v-model="form.tax_included" type="checkbox" class="h-4 w-4 accent-lime" /> Harga termasuk pajak
                        </label>
                    </div>
                    <div>
                        <label class="mb-1 block text-sm font-semibold">Pembulatan</label>
                        <MoneyInput v-model="form.rounding_step" placeholder="Rp 0" />
                    </div>
                    <div>
                        <label class="mb-1 block text-sm font-semibold">Maks Diskon Tanpa PIN</label>
                        <MoneyInput v-model="form.max_discount_without_pin" />
                    </div>
                    <label class="flex items-center gap-2 text-sm font-semibold">
                        <input v-model="form.allow_negative_stock" type="checkbox" class="h-4 w-4 accent-lime" /> Izinkan stok negatif
                    </label>
                </div>

                <div class="flex gap-2 mt-2">
                    <SecondaryButton as="link" :href="route('dashboard')">Batal</SecondaryButton>
                    <PrimaryButton type="submit" :processing="form.processing">Simpan Pengaturan</PrimaryButton>
                </div>
            </form>
        </div>
    </AuthenticatedLayout>
</template>
