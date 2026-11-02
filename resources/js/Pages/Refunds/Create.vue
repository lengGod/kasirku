<script setup>
import AuthenticatedLayout from '@/Layouts/AuthenticatedLayout.vue';
import PageHeader from '@/Components/PageHeader.vue';
import Card from '@/Components/Card.vue';
import PrimaryButton from '@/Components/PrimaryButton.vue';
import SecondaryButton from '@/Components/SecondaryButton.vue';
import FormInput from '@/Components/FormInput.vue';
import { Head, useForm } from '@inertiajs/vue3';
import { formatRupiah } from '@/Utils/format';
import { watch } from 'vue';

const props = defineProps({ sale: Object, recentSales: Array });

const form = useForm({
    sale_id: '',
    reason: '',
    pin: '',
    items: [],
});

const selectSale = (s) => {
    form.sale_id = s.id;
    form.items = s.items.map((item) => ({
        sale_item_id: item.id,
        name: item.name_snapshot,
        qty: 0,
        restock: true,
    }));
};

watch(() => props.sale, (s) => {
    if (s) {
        form.sale_id = s.id;
        form.items = s.items.map((item) => ({
            sale_item_id: item.id,
            name: item.name_snapshot,
            qty: 0,
            restock: true,
        }));
    }
});

const submit = () => {
    form.items = form.items.filter((item) => Number(item.qty) > 0);
    form.post(route('refunds.store'));
};
</script>

<template>
    <Head title="Retur Penjualan" />

    <AuthenticatedLayout>
        <div class="mx-auto max-w-7xl px-4 py-8 sm:px-6 lg:px-8">
            <PageHeader title="Retur Penjualan" subtitle="Proses retur barang atau pembatalan transaksi.">
                <template #actions>
                    <SecondaryButton as="link" :href="route('refunds.index')">Kembali</SecondaryButton>
                </template>
            </PageHeader>

            <div v-if="!form.sale_id" class="grid gap-6 lg:grid-cols-3">
                <Card class="lg:col-span-2">
                    <h2 class="mb-4 font-display text-lg font-bold">Pilih Transaksi untuk Retur</h2>
                    <div class="space-y-3">
                        <button v-for="s in recentSales" :key="s.id" @click="selectSale(s)" class="w-full flex justify-between border-2 border-ink bg-surface p-4 text-left hover:bg-hi transition">
                            <div>
                                <p class="font-bold text-ink">{{ s.invoice_number }}</p>
                                <p class="text-xs text-muted">{{ s.customer?.name ?? 'Umum' }}</p>
                            </div>
                            <div class="text-right">
                                <p class="font-bold text-ink">{{ formatRupiah(s.grand_total) }}</p>
                                <p class="text-xs text-muted">{{ s.created_at }}</p>
                            </div>
                        </button>
                    </div>
                </Card>
            </div>

            <div v-else class="grid gap-6 lg:grid-cols-2">
                <Card>
                    <h2 class="mb-4 font-display text-lg font-bold">Detail Retur</h2>
                    <form @submit.prevent="submit" class="space-y-4">
                        <div>
                            <label class="block text-sm font-semibold mb-1">Alasan Retur</label>
                            <FormInput v-model="form.reason" required placeholder="Contoh: Barang cacat" />
                        </div>
                        <div>
                            <label class="block text-sm font-semibold mb-1">PIN Supervisor</label>
                            <FormInput v-model="form.pin" type="password" required />
                        </div>

                        <div class="space-y-2">
                            <label class="block text-sm font-semibold">Pilih Item</label>
                            <div v-for="(item, index) in form.items" :key="index" class="flex items-center gap-2 border-b pb-2">
                                <input v-model="item.qty" type="number" min="0" class="w-20 border-2 border-ink h-10 px-2 text-sm" />
                                <span class="flex-1 text-sm">{{ item.name }}</span>
                                <label class="flex items-center gap-1 text-xs font-bold uppercase">
                                    <input type="checkbox" v-model="item.restock" class="border-2 border-ink" /> Restok
                                </label>
                            </div>
                        </div>

                        <PrimaryButton type="submit" :processing="form.processing">Proses Retur</PrimaryButton>
                    </form>
                </Card>
            </div>
        </div>
    </AuthenticatedLayout>
</template>
