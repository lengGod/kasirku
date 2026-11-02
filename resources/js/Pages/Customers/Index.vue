<script setup>
import AuthenticatedLayout from '@/Layouts/AuthenticatedLayout.vue';
import Card from '@/Components/Card.vue';
import PageHeader from '@/Components/PageHeader.vue';
import Modal from '@/Components/Modal.vue';
import FormInput from '@/Components/FormInput.vue';
import PrimaryButton from '@/Components/PrimaryButton.vue';
import SecondaryButton from '@/Components/SecondaryButton.vue';
import DeleteConfirm from '@/Components/DeleteConfirm.vue';
import Pagination from '@/Components/Pagination.vue';
import { Head, useForm, router } from '@inertiajs/vue3';
import { Plus } from '@lucide/vue';
import { ref } from 'vue';

defineProps({ customers: Object });

const showModal = ref(false);
const editing = ref(null);
const deleting = ref(null);
const form = useForm({ name: '', phone: '', notes: '' });

const openCreate = () => {
    editing.value = null;
    form.reset();
    showModal.value = true;
};

const openEdit = (customer) => {
    editing.value = customer;
    form.name = customer.name;
    form.phone = customer.phone ?? '';
    form.notes = customer.notes ?? '';
    showModal.value = true;
};

const submit = () => {
    const options = { onSuccess: () => { showModal.value = false; form.reset(); } };
    editing.value ? form.put(route('customers.update', editing.value.id), options) : form.post(route('customers.store'), options);
};

const destroy = () => {
    router.delete(route('customers.destroy', deleting.value.id), { onFinish: () => (deleting.value = null) });
};
</script>

<template>
    <Head title="Pelanggan" />

    <AuthenticatedLayout>
        <div class="bg-canvas min-h-screen py-8"><div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
            <PageHeader title="Pelanggan" subtitle="Data pelanggan untuk transaksi dan retur.">
                <template #actions>
                    <PrimaryButton type="button" @click="openCreate"><Plus class="h-4 w-4" /> Tambah Pelanggan</PrimaryButton>
                </template>
            </PageHeader>

            <Card class="shadow-hard">
                <div v-if="!customers.data?.length" class="text-center py-8"><p class="text-muted text-sm">Belum ada pelanggan.</p></div>
                <div v-else class="overflow-x-auto">
                <table class="w-full text-sm">
                    <thead>
                        <tr>
                            <th class="px-4 py-3 text-[11px] font-bold uppercase text-muted">Nama</th>
                            <th class="px-4 py-3 text-[11px] font-bold uppercase text-muted">Telepon</th>
                            <th class="px-4 py-3 text-[11px] font-bold uppercase text-muted text-right">Transaksi</th>
                            <th class="px-4 py-3 text-[11px] font-bold uppercase text-muted text-right">Aksi</th>
                        </tr>
                    </thead>
                    <tbody>
                        <tr v-for="customer in customers.data" :key="customer.id" class="hover:bg-surface-2">
                            <td class="px-4 py-3">
                                <p class="text-sm font-semibold text-ink">{{ customer.name }}</p>
                                <p class="text-xs text-muted">{{ customer.notes }}</p>
                            </td>
                            <td class="px-4 py-3 text-sm">{{ customer.phone ?? '-' }}</td>
                            <td class="px-4 py-3 text-sm text-right">{{ customer.sales_count }}</td>
                            <td class="px-4 py-3 text-right">
                                <div class="inline-flex items-center border-2 border-ink bg-surface shadow-hard">
                                    <button type="button" class="inline-flex h-9 items-center px-3 text-xs font-semibold text-ink hover:bg-hi" @click="openEdit(customer)">Edit</button>
                                    <button type="button" class="inline-flex h-9 items-center border-l-2 border-ink px-3 text-xs font-semibold text-bad-fg hover:bg-bad-bg" @click="deleting = customer">Hapus</button>
                                </div>
                            </td>
                        </tr>
                    </tbody>
                </table>
                </div><Pagination :paginator="customers" />
            </Card>
        </div>
        </div>

        <Modal :show="showModal" max-width="md" @close="showModal = false">
            <form class="p-6" @submit.prevent="submit">
                <h2 class="mb-4 font-display text-2xl font-bold text-ink">{{ editing ? 'Edit Pelanggan' : 'Tambah Pelanggan' }}</h2>
                <div class="space-y-3">
                    <div>
                        <label class="mb-1 block text-sm font-semibold text-ink">Nama</label>
                        <FormInput v-model="form.name" required />
                    </div>
                    <div>
                        <label class="mb-1 block text-sm font-semibold text-ink">Telepon</label>
                        <FormInput v-model="form.phone" />
                    </div>
                    <div>
                        <label class="mb-1 block text-sm font-semibold text-ink">Catatan</label>
                        <FormInput v-model="form.notes" />
                    </div>
                </div>
                <div class="mt-5 grid grid-cols-2 gap-2">
                    <SecondaryButton type="button" @click="showModal = false">Batal</SecondaryButton>
                    <PrimaryButton type="submit" :processing="form.processing">Simpan</PrimaryButton>
                </div>
            </form>
        </Modal>

        <DeleteConfirm :is-open="!!deleting" :message="`Hapus pelanggan ${deleting?.name}?`" @confirm="destroy" @cancel="deleting = null" />
    </AuthenticatedLayout>
</template>
