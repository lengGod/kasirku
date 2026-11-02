<script setup>
import AuthenticatedLayout from '@/Layouts/AuthenticatedLayout.vue';
import Card from '@/Components/Card.vue';
import PageHeader from '@/Components/PageHeader.vue';
import PrimaryButton from '@/Components/PrimaryButton.vue';
import Pagination from '@/Components/Pagination.vue';
import { Head } from '@inertiajs/vue3';
import { formatDateLong, formatNumber } from '@/Utils/format';
import { Plus } from '@lucide/vue';

defineProps({ documents: Object });
</script>

<template>
    <Head title="Penyesuaian Stok" />

    <AuthenticatedLayout>
        <div class="bg-canvas min-h-screen py-8"><div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
            <PageHeader title="Penyesuaian Stok" subtitle="Koreksi stok karena selisih hitung atau rusak.">
                <template #actions>
                    <PrimaryButton as="link" :href="route('stock.adjust.create')"><Plus class="h-4 w-4" /> Penyesuaian Baru</PrimaryButton>
                </template>
            </PageHeader>

            <Card class="shadow-hard">
                <div v-if="!documents.data?.length" class="text-center py-8"><p class="text-muted text-sm">Belum ada penyesuaian stok.</p></div>
                <div v-else class="overflow-x-auto">
                <table class="w-full text-sm">
                    <thead class="bg-surface-2">
                        <tr>
                            <th class="px-4 py-3 text-[11px] font-bold uppercase text-muted">Dokumen</th>
                            <th class="px-4 py-3 text-[11px] font-bold uppercase text-muted">Alasan</th>
                            <th class="px-4 py-3 text-[11px] font-bold uppercase text-muted">Tanggal</th>
                            <th class="px-4 py-3 text-[11px] font-bold uppercase text-muted text-right">Item</th>
                            <th class="px-4 py-3 text-[11px] font-bold uppercase text-muted">Oleh</th>
                        </tr>
                    </thead>
                    <tbody class="divide-y divide-line">
                        <tr v-for="document in documents.data" :key="document.id" class="hover:bg-surface-2">
                            <td class="px-4 py-3 text-sm font-bold text-ink">{{ document.document_number }}</td>
                            <td class="px-4 py-3 text-sm">{{ document.reason }}</td>
                            <td class="px-4 py-3 text-sm text-muted">{{ formatDateLong(document.created_at) }}</td>
                            <td class="px-4 py-3 text-sm text-right">{{ formatNumber(document.items_count, 0) }}</td>
                            <td class="px-4 py-3 text-sm">{{ document.creator?.name }}</td>
                        </tr>
                    </tbody>
                </table>
                </div>
                <Pagination :paginator="documents" />
            </Card>
        </div></div>
    </AuthenticatedLayout>
</template>
