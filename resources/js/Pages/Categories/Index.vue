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

defineProps({ categories: Object });

const showModal = ref(false);
const editing = ref(null);
const deleting = ref(null);
const form = useForm({ name: '' });

const openCreate = () => {
    editing.value = null;
    form.reset();
    form.clearErrors();
    showModal.value = true;
};

const openEdit = (category) => {
    editing.value = category;
    form.name = category.name;
    form.clearErrors();
    showModal.value = true;
};

const submit = () => {
    if (editing.value) {
        form.put(route('categories.update', editing.value.id), {
            onSuccess: () => { showModal.value = false; form.reset(); },
        });
        return;
    }

    form.post(route('categories.store'), {
        onSuccess: () => { showModal.value = false; form.reset(); },
    });
};

const destroy = () => {
    router.delete(route('categories.destroy', deleting.value.id), { onFinish: () => (deleting.value = null) });
};
</script>

<template>
    <Head title="Kategori" />

    <AuthenticatedLayout>
        <div class="bg-canvas min-h-screen py-8"><div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
            <PageHeader title="Kategori" subtitle="Kelompokkan produk agar mudah dicari di POS.">
                <template #actions>
                    <PrimaryButton type="button" @click="openCreate"><Plus class="h-4 w-4" /> Tambah Kategori</PrimaryButton>
                </template>
            </PageHeader>

            <Card class="shadow-hard">
                <div class="overflow-x-auto">
                <table class="w-full text-sm">
                    <thead>
                        <tr class="border-b-2 border-line">
                            <th class="py-3 px-4 font-semibold text-muted">Nama</th>
                            <th class="py-3 px-4 font-semibold text-muted text-right">Produk</th>
                            <th class="py-3 px-4 font-semibold text-muted text-right">Aksi</th>
                        </tr>
                    </thead>
                    <tbody>
                        <tr v-if="!categories.data?.length">
                            <td colspan="3" class="px-4 py-10 text-center text-sm text-muted">Belum ada kategori.</td>
                        </tr>
                        <tr v-for="category in categories.data" :key="category.id" class="border-b border-surface-2 hover:bg-surface-2">
                            <td class="py-4 px-4 font-semibold text-ink">{{ category.name }}</td>
                            <td class="py-4 px-4 text-right">{{ category.products_count }}</td>
                            <td class="py-4 px-4 text-right">
                                <div class="inline-flex items-center border-2 border-ink bg-surface shadow-hard">
                                    <button type="button" class="inline-flex h-9 items-center px-3 text-xs font-semibold text-ink hover:bg-hi" @click="openEdit(category)">Edit</button>
                                    <button type="button" class="inline-flex h-9 items-center border-l-2 border-ink px-3 text-xs font-semibold text-bad-fg hover:bg-bad-bg" @click="deleting = category">Hapus</button>
                                </div>
                            </td>
                        </tr>
                    </tbody>
                </table>
                </div><Pagination :paginator="categories" />
            </Card>
        </div>
        </div>

        <Modal :show="showModal" max-width="md" @close="showModal = false">
            <form class="p-6" @submit.prevent="submit">
                <h2 class="mb-4 font-display text-2xl font-bold text-ink">{{ editing ? 'Edit Kategori' : 'Tambah Kategori' }}</h2>
                <label class="mb-1 block text-sm font-semibold text-ink">Nama Kategori</label>
                <FormInput v-model="form.name" required placeholder="Contoh: Makanan" />
                <p v-if="form.errors.name" class="mt-1 text-xs font-semibold text-bad-fg">{{ form.errors.name }}</p>
                <div class="mt-5 grid grid-cols-2 gap-2">
                    <SecondaryButton type="button" @click="showModal = false">Batal</SecondaryButton>
                    <PrimaryButton type="submit" :processing="form.processing">Simpan</PrimaryButton>
                </div>
            </form>
        </Modal>

        <DeleteConfirm :is-open="!!deleting" :message="`Hapus kategori ${deleting?.name}?`" @confirm="destroy" @cancel="deleting = null" />
    </AuthenticatedLayout>
</template>
