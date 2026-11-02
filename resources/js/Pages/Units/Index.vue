<script setup>
import AuthenticatedLayout from '@/Layouts/AuthenticatedLayout.vue';
import Card from '@/Components/Card.vue';
import PageHeader from '@/Components/PageHeader.vue';
import Modal from '@/Components/Modal.vue';
import FormInput from '@/Components/FormInput.vue';
import PrimaryButton from '@/Components/PrimaryButton.vue';
import SecondaryButton from '@/Components/SecondaryButton.vue';
import DeleteConfirm from '@/Components/DeleteConfirm.vue';
import { Head, useForm, router } from '@inertiajs/vue3';
import { Plus } from '@lucide/vue';
import { ref } from 'vue';

defineProps({ units: Object });

const showModal = ref(false);
const editing = ref(null);
const deleting = ref(null);
const form = useForm({ name: '', short_name: '' });

const openCreate = () => {
    editing.value = null;
    form.reset();
    showModal.value = true;
};

const openEdit = (unit) => {
    editing.value = unit;
    form.name = unit.name;
    form.short_name = unit.short_name;
    showModal.value = true;
};

const submit = () => {
    const options = { onSuccess: () => { showModal.value = false; form.reset(); } };

    if (editing.value) {
        form.put(route('units.update', editing.value.id), options);
        return;
    }

    form.post(route('units.store'), options);
};

const destroy = () => {
    router.delete(route('units.destroy', deleting.value.id), { onFinish: () => (deleting.value = null) });
};
</script>

<template>
    <Head title="Satuan" />

    <AuthenticatedLayout>
        <div class="bg-canvas min-h-screen py-8"><div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
            <PageHeader title="Satuan" subtitle="Satuan jual produk.">
                <template #actions>
                    <PrimaryButton type="button" @click="openCreate"><Plus class="h-4 w-4" /> Tambah Satuan</PrimaryButton>
                </template>
            </PageHeader>

            <Card class="shadow-hard">
                <div class="overflow-x-auto">
                <table class="w-full text-sm">
                    <thead>
                        <tr>
                            <th class="px-4 py-3 text-[11px] font-bold uppercase text-muted">Nama</th>
                            <th class="px-4 py-3 text-[11px] font-bold uppercase text-muted">Singkatan</th>
                            <th class="px-4 py-3 text-[11px] font-bold uppercase text-muted text-right">Produk</th>
                            <th class="px-4 py-3 text-[11px] font-bold uppercase text-muted text-right">Aksi</th>
                        </tr>
                    </thead>
                    <tbody>
                        <tr v-for="unit in units.data" :key="unit.id" class="hover:bg-surface-2">
                            <td class="px-4 py-3 text-sm font-semibold text-ink">{{ unit.name }}</td>
                            <td class="px-4 py-3 text-sm">{{ unit.short_name }}</td>
                            <td class="px-4 py-3 text-sm text-right">{{ unit.products_count }}</td>
                            <td class="px-4 py-3 text-right">
                                <div class="inline-flex items-center border-2 border-ink bg-surface shadow-hard">
                                    <button type="button" class="inline-flex h-9 items-center px-3 text-xs font-semibold text-ink hover:bg-hi" @click="openEdit(unit)">Edit</button>
                                    <button type="button" class="inline-flex h-9 items-center border-l-2 border-ink px-3 text-xs font-semibold text-bad-fg hover:bg-bad-bg" @click="deleting = unit">Hapus</button>
                                </div>
                            </td>
                        </tr>
                    </tbody>
                </table>
                </div>
            </Card>
        </div>
        </div>

        <Modal :show="showModal" max-width="md" @close="showModal = false">
            <form class="p-6" @submit.prevent="submit">
                <h2 class="mb-4 font-display text-2xl font-bold text-ink">{{ editing ? 'Edit Satuan' : 'Tambah Satuan' }}</h2>
                <div class="space-y-3">
                    <div>
                        <label class="mb-1 block text-sm font-semibold text-ink">Nama Satuan</label>
                        <FormInput v-model="form.name" required placeholder="Kilogram" />
                    </div>
                    <div>
                        <label class="mb-1 block text-sm font-semibold text-ink">Singkatan</label>
                        <FormInput v-model="form.short_name" required placeholder="kg" />
                    </div>
                </div>
                <div class="mt-5 grid grid-cols-2 gap-2">
                    <SecondaryButton type="button" @click="showModal = false">Batal</SecondaryButton>
                    <PrimaryButton type="submit" :processing="form.processing">Simpan</PrimaryButton>
                </div>
            </form>
        </Modal>

        <DeleteConfirm :is-open="!!deleting" :message="`Hapus satuan ${deleting?.name}?`" @confirm="destroy" @cancel="deleting = null" />
    </AuthenticatedLayout>
</template>
