<script setup>
import { Head, Link, useForm } from '@inertiajs/vue3';
import PrimaryButton from '@/Components/PrimaryButton.vue';
import AttributionBanner from '@/Components/AttributionBanner.vue';
import { ref } from 'vue';
import {
    Boxes,
    CalendarClock,
    ChartColumn,
    Eye,
    EyeOff,
    Lock,
    Mail,
    Package,
    ShieldCheck,
} from '@lucide/vue';

defineProps({
    canResetPassword: Boolean,
    status: String,
});

const form = useForm({
    email: '',
    password: '',
    remember: false,
});

const showPassword = ref(false);

const demoAccounts = [
    { label: 'Admin', email: 'admin@gudangku.test' },
    { label: 'Staf', email: 'staff@gudangku.test' },
    { label: 'Viewer', email: 'viewer@gudangku.test' },
];

const features = [
    {
        icon: Boxes,
        title: 'Pelacakan Batch & FEFO',
        description: 'Alokasi otomatis berdasarkan kedaluwarsa terdekat.',
    },
    {
        icon: CalendarClock,
        title: 'Peringatan Kedaluwarsa',
        description: 'Pantau batch yang mendekati masa simpan.',
    },
    {
        icon: ChartColumn,
        title: 'Laporan Real-time',
        description: 'Stok, mutasi, dan nilai persediaan selalu akurat.',
    },
    {
        icon: ShieldCheck,
        title: 'Akses Multi-role',
        description: 'Admin, staf, dan viewer dengan hak berbeda.',
    },
];

const fillDemo = (account) => {
    form.email = account.email;
    form.password = 'password';
};

const submit = () => {
    form.post(route('login'), {
        onFinish: () => form.reset('password'),
    });
};
</script>

<template>
    <Head title="Masuk" />

    <div class="min-h-screen flex pt-9 relative">
        <AttributionBanner class="absolute top-0 left-0 right-0 z-10" />

        <!-- Left Panel: Branding -->
        <div class="hidden lg:flex lg:w-1/2 bg-ink flex-col justify-between p-12 relative overflow-hidden">
            <!-- Decorative shapes -->
            <div class="absolute -top-28 -right-28 w-80 h-80 rounded-full bg-lime/10"></div>
            <div class="absolute -bottom-24 -left-16 w-72 h-72 rounded-full bg-violet-text/20 blur-3xl"></div>
            <div class="absolute top-1/2 right-10 w-px h-40 bg-white/10"></div>

            <div class="relative">
                <!-- Logo -->
                <div class="flex items-center gap-3 mb-12">
                    <div class="w-11 h-11 bg-lime flex items-center justify-center">
                        <Package class="w-6 h-6 text-ink" />
                    </div>
                    <span class="text-2xl font-bold text-lime font-display">GudangKu</span>
                </div>

                <h1 class="text-4xl xl:text-5xl font-bold text-white font-display leading-tight">
                    Kendalikan stok gudang
                    <span class="text-lime">tanpa ribet.</span>
                </h1>
                <p class="text-white/70 mt-5 max-w-md text-sm leading-relaxed">
                    Kelola barang masuk, barang keluar, batch, dan kedaluwarsa dalam satu sistem yang rapi dan terpercaya.
                </p>

                <!-- Features -->
                <ul class="mt-10 space-y-5">
                    <li v-for="feature in features" :key="feature.title" class="flex items-start gap-4">
                        <div class="w-10 h-10 flex-shrink-0 flex items-center justify-center bg-white/5 border border-white/10">
                            <component :is="feature.icon" class="w-5 h-5 text-lime" />
                        </div>
                        <div>
                            <p class="text-white text-sm font-semibold">{{ feature.title }}</p>
                            <p class="text-white/50 text-xs mt-0.5">{{ feature.description }}</p>
                        </div>
                    </li>
                </ul>
            </div>

            <div class="relative border-t border-white/10 pt-6 flex items-center justify-between text-white/40 text-xs">
                <span>&copy; {{ new Date().getFullYear() }} GudangKu</span>
                <span>Sistem Inventaris Gudang</span>
            </div>
        </div>

        <!-- Right Panel: Form -->
        <div class="w-full lg:w-1/2 bg-canvas flex items-center justify-center p-5 sm:p-8">
            <div class="w-full max-w-md">
                <!-- Mobile logo -->
                <div class="lg:hidden flex items-center justify-center gap-3 mb-8">
                    <div class="w-10 h-10 bg-ink flex items-center justify-center">
                        <Package class="w-5 h-5 text-lime" />
                    </div>
                    <span class="text-2xl font-bold text-ink font-display">GudangKu</span>
                </div>

                <!-- Form Card -->
                <div class="bg-surface border-2 border-ink shadow-hard p-6 sm:p-8 relative">
                    <div class="absolute top-0 left-0 right-0 h-1.5 bg-lime"></div>

                    <h2 class="text-2xl font-bold text-ink font-display">Selamat datang</h2>
                    <p class="text-muted text-sm mt-1 mb-6">Masuk untuk melanjutkan ke dashboard.</p>

                    <!-- Status message -->
                    <div v-if="status" class="mb-4 p-4 bg-ok-bg border-2 border-ok-fg text-ok-fg text-sm font-semibold">
                        {{ status }}
                    </div>

                    <!-- Error messages -->
                    <div v-if="form.errors.email || form.errors.password" class="mb-4 p-4 bg-bad-bg border-2 border-bad-fg text-bad-fg text-sm">
                        <p v-if="form.errors.email" class="font-semibold">{{ form.errors.email }}</p>
                        <p v-if="form.errors.password" class="font-semibold">{{ form.errors.password }}</p>
                    </div>

                    <form @submit.prevent="submit" class="space-y-5">
                        <!-- Email -->
                        <div>
                            <label class="block text-xs font-semibold text-muted mb-2">Email</label>
                            <div class="relative">
                                <Mail class="absolute left-4 top-1/2 -translate-y-1/2 w-4 h-4 text-muted pointer-events-none" />
                                <input
                                    v-model="form.email"
                                    type="email"
                                    placeholder="admin@gudangku.test"
                                    class="w-full h-12 pl-11 pr-4 border-2 border-line text-sm focus:border-ink focus:outline-none"
                                    required
                                    autofocus
                                />
                            </div>
                        </div>

                        <!-- Password -->
                        <div>
                            <label class="block text-xs font-semibold text-muted mb-2">Kata Sandi</label>
                            <div class="relative">
                                <Lock class="absolute left-4 top-1/2 -translate-y-1/2 w-4 h-4 text-muted pointer-events-none" />
                                <input
                                    v-model="form.password"
                                    :type="showPassword ? 'text' : 'password'"
                                    placeholder="••••••••"
                                    class="w-full h-12 pl-11 pr-12 border-2 border-line text-sm focus:border-ink focus:outline-none"
                                    required
                                />
                                <button
                                    type="button"
                                    @click="showPassword = !showPassword"
                                    class="absolute right-3 top-1/2 -translate-y-1/2 p-1.5 text-muted hover:text-ink transition"
                                    :aria-label="showPassword ? 'Sembunyikan kata sandi' : 'Tampilkan kata sandi'"
                                >
                                    <EyeOff v-if="showPassword" class="w-4 h-4" />
                                    <Eye v-else class="w-4 h-4" />
                                </button>
                            </div>
                        </div>

                        <!-- Remember + Forgot -->
                        <div class="flex items-center justify-between gap-3">
                            <label class="flex items-center gap-3 cursor-pointer">
                                <input
                                    v-model="form.remember"
                                    type="checkbox"
                                    class="w-5 h-5 border-2 border-ink accent-lime"
                                />
                                <span class="text-sm text-muted">Ingat saya</span>
                            </label>
                            <Link
                                v-if="canResetPassword"
                                :href="route('password.request')"
                                class="text-violet-text text-sm font-semibold hover:underline"
                            >
                                Lupa kata sandi?
                            </Link>
                        </div>

                        <!-- Submit -->
                        <PrimaryButton type="submit" :loading="form.processing" class="w-full">
                            Masuk
                        </PrimaryButton>
                    </form>

                    <!-- Demo accounts -->
                    <div class="mt-6 border-t-2 border-line pt-5">
                        <p class="text-xs font-semibold text-muted mb-2">Akun demo — klik untuk isi otomatis</p>
                        <div class="flex flex-wrap gap-2">
                            <button
                                v-for="account in demoAccounts"
                                :key="account.email"
                                type="button"
                                @click="fillDemo(account)"
                                class="px-3 py-1.5 text-xs font-semibold border-2 border-line hover:border-ink hover:bg-surface-2 transition"
                            >
                                {{ account.label }}
                            </button>
                        </div>
                    </div>
                </div>

                <p class="text-center text-muted text-xs mt-5">
                    Sistem Inventaris Gudang &middot; GudangKu
                </p>
            </div>
        </div>
    </div>
</template>
