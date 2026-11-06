<script setup>
import AuthenticatedLayout from '@/Layouts/AuthenticatedLayout.vue';
import Card from '@/Components/Card.vue';
import PageHeader from '@/Components/PageHeader.vue';
import MoneyInput from '@/Components/MoneyInput.vue';
import PrimaryButton from '@/Components/PrimaryButton.vue';
import SecondaryButton from '@/Components/SecondaryButton.vue';
import { Head, useForm } from '@inertiajs/vue3';
import { formatRupiah } from '@/Utils/format';

const props = defineProps({ shift: Object, summary: Object });

const form = useForm({ actual_cash: props.summary?.expected_cash ?? '' });

const submit = () => {
    form.post(route('shifts.store-close'));
};
</script>

<template>
    <Head title="Tutup Shift" />

    <AuthenticatedLayout>
        <div class="mx-auto max-w-7xl px-4 py-8 sm:px-6 lg:px-8">
            <PageHeader title="Tutup Shift" subtitle="Bandirkan kas aktual dengan estimasi sistem.">
                <template #actions>
                    <SecondaryButton as="link" :href="route('shifts.show', shift.id)">Kembali</SecondaryButton>
                </template>
            </PageHeader>

            <Card tone="surface">
                <div class="mb-4 space-y-2">
                    <p class="text-[11px] font-bold uppercase tracking-wide text-muted">Kas Diperkirakan</p>
                    <p class="font-display text-2xl font-bold text-ink">{{ formatRupiah(summary.expected_cash ?? 0) }}</p>
                </div>

                <form @submit.prevent="submit" class="space-y-4">
                    <div>
                        <label class="block text-sm font-semibold text-ink mb-1">Kas Aktual (Rp)</label>
                        <MoneyInput v-model="form.actual_cash" required />
                        <p class="mt-1 text-xs text-muted">Hitung uang tunai di lemari kas saat ini.</p>
                    </div>

                    <div class="flex gap-2 mt-4">
                        <SecondaryButton type="button" as="link" :href="route('shifts.show', shift.id)">Batal</SecondaryButton>
                        <PrimaryButton type="submit" :processing="form.processing">Tutup Shift</PrimaryButton>
                    </div>
                </form>
            </Card>
        </div>
    </AuthenticatedLayout>
</template>
