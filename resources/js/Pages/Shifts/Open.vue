<script setup>
import AuthenticatedLayout from '@/Layouts/AuthenticatedLayout.vue';
import Card from '@/Components/Card.vue';
import PageHeader from '@/Components/PageHeader.vue';
import MoneyInput from '@/Components/MoneyInput.vue';
import PrimaryButton from '@/Components/PrimaryButton.vue';
import SecondaryButton from '@/Components/SecondaryButton.vue';
import { Head, useForm } from '@inertiajs/vue3';

defineProps({});

const form = useForm({ opening_cash: '' });

const submit = () => {
    form.post(route('shifts.store-open'));
};
</script>

<template>
    <Head title="Buka Shift" />

    <AuthenticatedLayout>
        <div class="mx-auto max-w-7xl px-4 py-8 sm:px-6 lg:px-8">
            <PageHeader title="Buka Shift" subtitle="Setor modal awal sebelum memulai transaksi hari ini.">
                <template #actions>
                    <SecondaryButton as="link" :href="route('shifts.index')">Kembali</SecondaryButton>
                </template>
            </PageHeader>

            <Card tone="surface">
                <form @submit.prevent="submit" class="space-y-4">
                    <div>
                        <label class="block text-sm font-semibold text-ink mb-1">Modal Awal (Rp)</label>
                        <MoneyInput v-model="form.opening_cash" required />
                        <p class="mt-1 text-xs text-muted">Nominal uang tunai yang siap di kasir saat shift dimulai.</p>
                    </div>

                    <div class="flex gap-2 mt-2">
                        <SecondaryButton type="button" as="link" :href="route('shifts.index')">Batal</SecondaryButton>
                        <PrimaryButton type="submit" :processing="form.processing">Buka Shift</PrimaryButton>
                    </div>
                </form>
            </Card>
        </div>
    </AuthenticatedLayout>
</template>
