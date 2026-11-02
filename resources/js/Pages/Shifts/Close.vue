<script setup>
import AuthenticatedLayout from '@/Layouts/AuthenticatedLayout.vue';
import PageHeader from '@/Components/PageHeader.vue';
import FormInput from '@/Components/FormInput.vue';
import PrimaryButton from '@/Components/PrimaryButton.vue';
import SecondaryButton from '@/Components/SecondaryButton.vue';
import { Head, useForm } from '@inertiajs/vue3';
import { formatRupiah } from '@/Utils/format';

defineProps({ shift: Object, summary: Object });

const form = useForm({ actual_cash: summary?.expected_cash ?? '' });

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

                <form @submit="submit" class="space-y-4">
                    <div>
                        <label class="block text-sm font-semibold text-ink mb-1">Kas Aktual (Rp)</label>
                        <input v-model="form.actual_cash" type="number" step="100" min="0" required class="h-12 w-full border-2 border-ink bg-surface px-4 text-sm text-ink focus:border-violet-text focus:outline-none" />
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
