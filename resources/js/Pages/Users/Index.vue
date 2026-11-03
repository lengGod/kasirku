<script setup>
import AuthenticatedLayout from '@/Layouts/AuthenticatedLayout.vue';
import Card from '@/Components/Card.vue';
import PageHeader from '@/Components/PageHeader.vue';
import Modal from '@/Components/Modal.vue';
import FormInput from '@/Components/FormInput.vue';
import PrimaryButton from '@/Components/PrimaryButton.vue';
import SecondaryButton from '@/Components/SecondaryButton.vue';
import { Head, useForm, router } from '@inertiajs/vue3';
import { Plus } from '@lucide/vue';
import { ref } from 'vue';

defineProps({ users: Object, roles: Array });

const showModal = ref(false);
const editing = ref(null);
const deleting = ref(null);
const form = useForm({
    name: '',
    email: '',
    password: '',
    role: 'cashier',
    pin: '',
    is_active: true,
});

const openCreate = () => {
    editing.value = null;
    form.reset();
    form.password = 'password';
    form.role = 'cashier';
    form.pin = '';
    showModal.value = true;
};

const openEdit = (user) => {
    editing.value = user;
    form.name = user.name;
    form.email = user.email;
    form.password = '';
    form.role = user.role;
    form.pin = '';
    form.is_active = user.is_active;
    showModal.value = true;
};

const submit = () => {
    const options = { onSuccess: () => { showModal.value = false; form.reset(); } };
    editing.value ? form.put(route('users.update', editing.value.id), options) : form.post(route('users.store'), options);
};

const destroy = () => {
    router.delete(route('users.destroy', deleting.value.id), { onFinish: () => (deleting.value = null) });
};
</script>

<template>
    <Head title="Pengguna" />

    <AuthenticatedLayout>
        <div class="bg-canvas min-h-screen py-8"><div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
            <PageHeader title="Pengguna" subtitle="Kelola akun dan PIN kasir.">
                <template #actions>
                    <PrimaryButton type="button" @click="openCreate"><Plus class="h-4 w-4" /> Tambah Pengguna</PrimaryButton>
                </template>
            </PageHeader>

            <Card class="shadow-hard">
                <div class="overflow-x-auto">
                <table class="w-full text-sm">
                    <thead>
                        <tr>
                            <th class="px-4 py-3 text-[11px] font-bold uppercase text-muted">Nama</th>
                            <th class="px-4 py-3 text-[11px] font-bold uppercase text-muted">Email</th>
                            <th class="px-4 py-3 text-[11px] font-bold uppercase text-muted">Role</th>
                            <th class="px-4 py-3 text-[11px] font-bold uppercase text-muted">Status</th>
                            <th class="px-4 py-3 text-[11px] font-bold uppercase text-muted text-right">Aksi</th>
                        </tr>
                    </thead>
                    <tbody>
                        <tr v-if="!users.data?.length">
                            <td colspan="5" class="px-4 py-10 text-center text-sm text-muted">Belum ada pengguna.</td>
                        </tr>
                        <tr v-for="user in users.data" :key="user.id" class="hover:bg-surface-2">
                            <td class="px-4 py-3 text-sm font-semibold text-ink">{{ user.name }}</td>
                            <td class="px-4 py-3 text-sm">{{ user.email }}</td>
                            <td class="px-4 py-3 text-sm capitalize">{{ user.role }}</td>
                            <td class="px-4 py-3"><span :class="['px-3 py-1 text-xs font-bold', user.is_active ? 'bg-ok-bg text-ok-fg' : 'bg-surface-2 text-muted']">{{ user.is_active ? 'Aktif' : 'Nonaktif' }}</span></td>
                            <td class="px-4 py-3 text-right">
                                <div class="inline-flex items-center border-2 border-ink bg-surface shadow-hard">
                                    <button type="button" class="inline-flex h-9 items-center px-3 text-xs font-semibold text-ink hover:bg-hi" @click="openEdit(user)">Edit</button>
                                    <button type="button" class="inline-flex h-9 items-center border-l-2 border-ink px-3 text-xs font-semibold text-bad-fg hover:bg-bad-bg" @click="deleting = user">Hapus</button>
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
                <h2 class="mb-4 font-display text-2xl font-bold text-ink">{{ editing ? 'Edit Pengguna' : 'Tambah Pengguna' }}</h2>
                <div class="space-y-3">
                    <FormInput v-model="form.name" required placeholder="Nama lengkap" />
                    <FormInput v-model="form.email" type="email" required placeholder="email@contoh.com" />
                    <FormInput v-model="form.password" type="password" :placeholder="editing ? 'Kosongkan jika tidak ingin ganti password' : 'Password'" :required="!editing" />
                    <FormSelect v-model="form.role" required>
                        <option v-for="role in roles" :key="role.value" :value="role.value">{{ role.label }}</option>
                    </FormSelect>
                    <FormInput v-model="form.pin" type="password" placeholder="PIN 4-6 digit" />
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

        <DeleteConfirm :is-open="!!deleting" :message="`Hapus pengguna ${deleting?.name}?`" @confirm="destroy" @cancel="deleting = null" />
    </AuthenticatedLayout>
</template>
