<script setup>
import AuthenticatedLayout from '@/Layouts/AuthenticatedLayout.vue';
import PageHeader from '@/Components/PageHeader.vue';
import ProductForm from './Partials/ProductForm.vue';

defineProps({ categories: Array, units: Array });
</script>

<template>
    <AuthenticatedLayout>
        <div class="mx-auto max-w-7xl px-4 py-8 sm:px-6 lg:px-8">
            <PageHeader title="Tambah Produk" subtitle="Daftarkan produk baru ke katalog toko." />
            <div class="border-2 border-ink bg-surface p-5 shadow-hard sm:p-6">
                <ProductForm :categories="categories" :units="units" />
            </div>
        </div>
    </AuthenticatedLayout>
</template>
