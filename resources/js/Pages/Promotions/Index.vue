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
import { formatRupiah } from '@/Utils/format';
import { Plus } from '@lucide/vue';
import { ref } from 'vue';

defineProps({ promotions: Object });

const showModal = ref(false);
const editing = ref(null);
const deleting = ref(null);
const form = useForm({
    name: '',
    type: 'percentage',
    value: 0,
    target: 'product',
    target_id: '',
    category_id: '',
    start_at: '',
    end_at: '',
    is_active: true,
});

const openCreate = () => {
    editing.value = null;
    form.reset();
    showModal.value = true;
};

const openEdit = (promotion) => {
    editing.value = promotion;
    Object.assign(form, {
        name: promotion.name,
        type: promotion.type,
        value: promotion.value,
        target: promotion.target,
        target_id: promotion.target_id ?? '',
        category_id: promotion.category_id ?? '',
        start_at: promotion.start_at ?? '',
        end_at: promotion.end_at ?? '',
        is_active: promotion.is_active,
    });
    showModal.value = true;
};

const submit = () => {
    const options = { onSuccess: () => { showModal.value = false; form.reset(); } };
    editing.value ? form.put(route('promotions.update', editing.value.id), options) : form.post(route('promotions.store'), options);
};

const destroy = () => {
    router.delete(route('promotions.destroy', deleting.value.id), { onFinish: () => (deleting.value = null) });
};
</script>

<template>
    <Head title="Promo" />

    <AuthenticatedLayout>
        <div class="bg-canvas min-h-screen py-8"><div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
            <PageHeader title="Promo" subtitle="Atur diskon produk atau kategori.">
                <template #actions>
                    <PrimaryButton type="button" @click="openCreate"><Plus class="h-4 w-4" /> Tambah Promo</PrimaryButton>
                </template>
            </PageHeader>

            <Card class="shadow-hard">
                <div v-if="!promotions.data?.length" class="text-center py-8"><p class="text-muted text-sm">Belum ada promosi.</p></div>
                <div v-else class="overflow-x-auto">
                <table class="w-full text-sm">
                    <thead>
                        <tr>
                            <th class="px-4 py-3 text-[11px] font-bold uppercase text-muted">Nama</th>
                            <th class="px-4 py-3 text-[11px] font-bold uppercase text-muted">Nilai</th>
                            <th class="px-4 py-3 text-[11px] font-bold uppercase text-muted">Target</th>
                            <th class="px-4 py-3 text-[11px] font-bold uppercase text-muted">Status</th>
                            <th class="px-4 py-3 text-[11px] font-bold uppercase text-muted text-right">Aksi</th>
                        </tr>
                    </thead>
                    <tbody>
                        <tr v-for="promotion in promotions.data" :key="promotion.id" class="hover:bg-surface-2">
                            <td class="px-4 py-3 text-sm font-semibold text-ink">{{ promotion.name }}</td>
                            <td class="px-4 py-3 text-sm">{{ promotion.type === 'percentage' ? promotion.value + '%' : formatRupiah(promotion.value) }}</td>
                            <td class="px-4 py-3 text-sm">{{ promotion.target }}</td>
                            <td class="px-4 py-3"><span :class="['px-3 py-1 text-xs font-bold', promotion.is_active ? 'bg-ok-bg text-ok-fg' : 'bg-surface-2 text-muted']">{{ promotion.is_active ? 'Aktif' : 'Nonaktif' }}</span></td>
                            <td class="px-4 py-3 text-right">
                                <div class="inline-flex items-center border-2 border-ink bg-surface shadow-hard">
                                    <button type="button" class="inline-flex h-9 items-center px-3 text-xs font-semibold text-ink hover:bg-hi" @click="openEdit(promotion)">Edit</button>
                                    <button type="button" class="inline-flex h-9 items-center border-l-2 border-ink px-3 text-xs font-semibold text-bad-fg hover:bg-bad-bg" @click="deleting = promotion">Hapus</button>
                                </div>
                            </td>
                        </tr>
                    </tbody>
                </table>
                </div><Pagination :paginator="promotions" />
            </Card>
        </div>
        </div>

        <Modal :show="showModal" max-width="md" @close="showModal = false">
            <form class="p-6" @submit.prevent="submit">
                <h2 class="mb-4 font-display text-2xl font-bold text-ink">{{ editing ? 'Edit Promo' : 'Tambah Promo' }}</h2>
                <div class="space-y-3">
                    <FormInput v-model="form.name" required placeholder="Nama promo" />
                    <FormSelect v-model="form.type">
                        <option value="percentage">Persentase</option>
                        <option value="nominal">Nominal</option>
                    </FormSelect>
                    <FormInput v-model="form.value" type="number" min="0" required placeholder="Nilai" />
                    <FormSelect v-model="form.target">
                        <option value="product">Produk</option>
                        <option value="category">Kategori</option>
                    </FormSelect>
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

        <DeleteConfirm :is-open="!!deleting" :message="`Hapus promo ${deleting?.name}?`" @confirm="destroy" @cancel="deleting = null" />
    </AuthenticatedLayout>
</template>
