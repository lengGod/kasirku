<script setup>
import AuthenticatedLayout from '@/Layouts/AuthenticatedLayout.vue';
import Card from '@/Components/Card.vue';
import PageHeader from '@/Components/PageHeader.vue';
import Modal from '@/Components/Modal.vue';
import FormInput from '@/Components/FormInput.vue';
import FormSelect from '@/Components/FormSelect.vue';
import PrimaryButton from '@/Components/PrimaryButton.vue';
import SecondaryButton from '@/Components/SecondaryButton.vue';
import DeleteConfirm from '@/Components/DeleteConfirm.vue';
import Pagination from '@/Components/Pagination.vue';
import { Head, useForm, router } from '@inertiajs/vue3';
import { Plus } from '@lucide/vue';
import { ref } from 'vue';

defineProps({ paymentMethods: Object, types: Array });

const showModal = ref(false);
const editing = ref(null);
const deleting = ref(null);
const form = useForm({ name: '', type: 'cash', is_active: true });

const openCreate = () => {
    editing.value = null;
    form.reset();
    showModal.value = true;
};

const openEdit = (method) => {
    editing.value = method;
    form.name = method.name;
    form.type = method.type;
    form.is_active = method.is_active;
    showModal.value = true;
};

const submit = () => {
    const options = { onSuccess: () => { showModal.value = false; form.reset(); } };
    editing.value ? form.put(route('payment-methods.update', editing.value.id), options) : form.post(route('payment-methods.store'), options);
};

const destroy = () => {
    router.delete(route('payment-methods.destroy', deleting.value.id), { onFinish: () => (deleting.value = null) });
};
</script>

<template>
    <Head title="Metode Pembayaran" />

    <AuthenticatedLayout>
        <div class="bg-canvas min-h-screen py-8"><div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
            <PageHeader title="Metode Pembayaran" subtitle="Pilihan pembayaran yang tersedia di POS.">
                <template #actions>
                    <PrimaryButton type="button" @click="openCreate"><Plus class="h-4 w-4" /> Tambah Metode</PrimaryButton>
                </template>
            </PageHeader>

            <Card class="shadow-hard">
                <div v-if="!paymentMethods.data?.length" class="text-center py-8"><p class="text-muted text-sm">Belum ada metode pembayaran.</p></div>
                <div v-else class="overflow-x-auto">
                <table class="w-full text-sm">
                    <thead>
                        <tr>
                            <th class="px-4 py-3 text-[11px] font-bold uppercase text-muted">Nama</th>
                            <th class="px-4 py-3 text-[11px] font-bold uppercase text-muted">Tipe</th>
                            <th class="px-4 py-3 text-[11px] font-bold uppercase text-muted">Status</th>
                            <th class="px-4 py-3 text-[11px] font-bold uppercase text-muted text-right">Aksi</th>
                        </tr>
                    </thead>
                    <tbody>
                        <tr v-for="method in paymentMethods.data" :key="method.id" class="hover:bg-surface-2">
                            <td class="px-4 py-3 text-sm font-semibold text-ink">{{ method.name }}</td>
                            <td class="px-4 py-3 text-sm">{{ types.find(t => t.value === method.type)?.label ?? method.type }}</td>
                            <td class="px-4 py-3">
                                <span :class="['px-3 py-1 text-xs font-bold', method.is_active ? 'bg-ok-bg text-ok-fg' : 'bg-surface-2 text-muted']">{{ method.is_active ? 'Aktif' : 'Nonaktif' }}</span>
                            </td>
                            <td class="px-4 py-3 text-right">
                                <div class="inline-flex items-center border-2 border-ink bg-surface shadow-hard">
                                    <button type="button" class="inline-flex h-9 items-center px-3 text-xs font-semibold text-ink hover:bg-hi" @click="openEdit(method)">Edit</button>
                                    <button type="button" class="inline-flex h-9 items-center border-l-2 border-ink px-3 text-xs font-semibold text-bad-fg hover:bg-bad-bg" @click="deleting = method">Hapus</button>
                                </div>
                            </td>
                        </tr>
                    </tbody>
                </table>
                </div><Pagination :paginator="paymentMethods" />
            </Card>
        </div>
        </div>

        <Modal :show="showModal" max-width="md" @close="showModal = false">
            <form class="p-6" @submit.prevent="submit">
                <h2 class="mb-4 font-display text-2xl font-bold text-ink">{{ editing ? 'Edit Metode' : 'Tambah Metode' }}</h2>
                <div class="space-y-3">
                    <div>
                        <label class="mb-1 block text-sm font-semibold text-ink">Nama</label>
                        <FormInput v-model="form.name" required />
                    </div>
                    <div>
                        <label class="mb-1 block text-sm font-semibold text-ink">Tipe</label>
                        <FormSelect v-model="form.type">
                            <option v-for="type in types" :key="type.value" :value="type.value">{{ type.label }}</option>
                        </FormSelect>
                    </div>
                    <label class="flex items-center gap-2 text-sm font-semibold text-ink">
                        <input v-model="form.is_active" type="checkbox" class="h-4 w-4 accent-lime" /> Aktif
                    </label>
                </div>
                <div class="mt-5 grid grid-cols-2 gap-2">
                    <SecondaryButton type="button" @click="showModal = false">Batal</SecondaryButton>
                    <PrimaryButton type="submit" :processing="form.processing">Simpan</PrimaryButton>
                </div>
            </form>
        </Modal>

        <DeleteConfirm :is-open="!!deleting" :message="`Hapus metode ${deleting?.name}?`" @confirm="destroy" @cancel="deleting = null" />
    </AuthenticatedLayout>
</template>
