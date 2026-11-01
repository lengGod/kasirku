<script setup>
import { computed, ref, watch } from 'vue';
import { Link, usePage } from '@inertiajs/vue3';
import { ChevronDown, Menu, ScanBarcode, UserRound, X } from '@lucide/vue';
import AttributionBanner from '@/Components/AttributionBanner.vue';
import FlashMessage from '@/Components/FlashMessage.vue';
import { useAuthorization } from '@/Utils/authorization';

const page = usePage();
const user = page.props.auth.user;
const { can } = useAuthorization();
const roleLabel = computed(() => page.props.auth?.role_label ?? '');
const showProfileMenu = ref(false);
const activeDropdown = ref(null);
const showMobileMenu = ref(false);
const mobileOpenGroup = ref(null);

const navigation = [
    { label: 'Dashboard', route: 'dashboard', direct: true },
    {
        label: 'Master Data',
        items: [
            { label: 'Barang', route: 'products.index', match: 'products.*' },
            { label: 'Kategori', route: 'categories.index', match: 'categories.*' },
            { label: 'Satuan', route: 'units.index', match: 'units.*' },
            { label: 'Supplier', route: 'suppliers.index', match: 'suppliers.*' },
            { label: 'Lokasi', route: 'locations.index', match: 'locations.*' },
        ]
    },
    {
        label: 'Transaksi',
        items: [
            { label: 'Barang Masuk', route: 'stock-ins.index', match: 'stock-ins.*' },
            { label: 'Barang Keluar', route: 'stock-outs.index', match: 'stock-outs.*' },
            { label: 'Penyesuaian Stok', route: 'stock-adjustments.index', match: 'stock-adjustments.*' },
        ]
    },
    {
        label: 'Inventori',
        items: [
            { label: 'Batch & Kedaluwarsa', route: 'batches.index', match: 'batches.*' },
            { label: 'Scan & Label', route: 'scan-label.index', match: 'scan-label.*', ability: 'print_labels' },
            { label: 'Laporan', route: 'reports.index', match: 'reports.*' },
        ]
    },
];

const visibleNavigation = computed(() => navigation
    .map((group) => group.items
        ? { ...group, items: group.items.filter((item) => !item.ability || can(item.ability)) }
        : group)
    .filter((group) => group.direct || group.items.length > 0));

const toggleDropdown = (label) => {
    activeDropdown.value = activeDropdown.value === label ? null : label;
};

const closeMenus = () => {
    activeDropdown.value = null;
    showProfileMenu.value = false;
};

const toggleMobileGroup = (label) => {
    mobileOpenGroup.value = mobileOpenGroup.value === label ? null : label;
};

const closeMobileMenu = () => {
    showMobileMenu.value = false;
    mobileOpenGroup.value = null;
};

const isItemActive = (item) => {
    return route().current(item.route) || (item.match ? route().current(item.match) : false);
};

const isDropdownActive = (dropdownItems) => {
    return dropdownItems.some((item) => isItemActive(item));
};

// Lock scroll when mobile menu open
watch(showMobileMenu, (val) => {
    document.body.style.overflow = val ? 'hidden' : '';
});
</script>

<template>
    <div>
        <FlashMessage />

        <!-- Attribution Banner -->
        <AttributionBanner class="fixed top-0 left-0 right-0 z-50" />

        <!-- Topbar -->
        <nav class="fixed top-9 left-0 right-0 h-16 bg-ink flex items-center px-4 sm:px-6 z-50 shadow-hard">
            <div class="flex items-center justify-between w-full max-w-full gap-2">
                <!-- Left: Hamburger + Logo -->
                <div class="flex items-center gap-2 flex-shrink-0">
                    <!-- Hamburger (mobile) -->
                    <button @click="showMobileMenu = true" class="lg:hidden text-white hover:text-lime transition p-2 -ml-2" aria-label="Buka menu">
                        <Menu class="w-6 h-6" />
                    </button>

                    <Link :href="route('dashboard')" class="text-lime font-bold text-lg sm:text-xl font-display hover:text-yellow-300 transition flex-shrink-0">
                        GudangKu
                    </Link>
                </div>

                <!-- Navigation - Desktop Center -->
                <div class="hidden lg:flex gap-6 flex-1 justify-center ml-16">
                    <Link v-for="item in visibleNavigation.filter(n => n.direct)" :key="item.label" :href="route(item.route)" 
                        :class="['px-3 py-2 text-white text-sm font-semibold hover:text-lime hover:bg-ink-3 transition whitespace-nowrap', route().current(item.route) ? 'text-lime border-b-2 border-lime' : '']">
                        {{ item.label }}
                    </Link>

                    <div v-for="item in visibleNavigation.filter(n => !n.direct)" :key="item.label" class="relative z-50">
                        <button @click="toggleDropdown(item.label)" 
                            :class="['px-3 py-2 text-white text-sm font-semibold hover:text-lime transition flex items-center gap-1 whitespace-nowrap hover:border-b-2 hover:border-lime', activeDropdown === item.label || isDropdownActive(item.items) ? 'text-lime border-b-2 border-lime' : 'border-b-2 border-transparent']">
                            {{ item.label }}
                            <ChevronDown :class="['w-4 h-4 transition', activeDropdown === item.label ? 'rotate-180' : '']" />
                        </button>

                        <div v-show="activeDropdown === item.label" class="absolute left-0 top-full mt-1 w-52 bg-surface border-2 border-ink shadow-hard z-[9999] py-1">
                            <Link v-for="subitem in item.items" :key="subitem.label" :href="route(subitem.route)" 
                                @click="closeMenus"
                                :class="['block px-6 py-3 text-sm text-ink hover:bg-surface-2 hover:text-violet-text transition border-b border-line last:border-b-0', isItemActive(subitem) ? 'bg-surface-2 text-violet-text font-semibold' : '']">
                                {{ subitem.label }}
                            </Link>
                        </div>
                    </div>
                </div>

                <!-- Right Actions -->
                <div class="flex items-center gap-1 sm:gap-4 ml-auto">
                    <Link
                        v-if="can('print_labels')"
                        :href="route('scan-label.index')"
                        class="hidden md:inline-flex items-center justify-center gap-2 h-12 px-6 text-xs font-semibold text-ink bg-lime hover:bg-yellow-400 transition whitespace-nowrap"
                    >
                        <ScanBarcode class="w-4 h-4" />
                        Scan &amp; Label
                    </Link>

                    <div class="relative">
                        <button @click="showProfileMenu = !showProfileMenu" 
                            :class="['flex items-center gap-2 px-2 sm:px-3 py-2 text-white hover:text-lime transition text-sm font-semibold', showProfileMenu ? 'text-lime' : '']">
                            <UserRound class="w-5 h-5" />
                            <span class="hidden sm:inline">{{ user.name }}</span>
                        </button>

                        <div v-if="showProfileMenu" class="absolute right-0 top-full mt-1 w-48 bg-surface border-2 border-ink shadow-hard z-50 py-1">
                            <div class="px-6 py-3 border-b border-line">
                                <p class="text-[10px] font-semibold uppercase tracking-wide text-muted">Masuk sebagai</p>
                                <p class="text-xs font-semibold text-ink">{{ roleLabel }}</p>
                            </div>
                            <Link :href="route('logout')" method="post" as="button" @click="closeMenus" 
                                class="w-full text-left px-6 py-3 text-sm text-ink hover:bg-surface-2">
                                Keluar
                            </Link>
                        </div>
                    </div>
                </div>
            </div>
        </nav>

        <!-- Click outside to close dropdowns -->
        <div v-if="activeDropdown || showProfileMenu" @click="closeMenus" class="fixed inset-0 z-40 mt-[6.25rem]"></div>

        <!-- Mobile Drawer -->
        <Transition
            enter-active-class="transition-opacity duration-200"
            enter-from-class="opacity-0"
            leave-active-class="transition-opacity duration-200"
            leave-to-class="opacity-0"
        >
            <div v-if="showMobileMenu" class="lg:hidden fixed inset-0 z-[9998] bg-black/50" @click="closeMobileMenu"></div>
        </Transition>

        <Transition
            enter-active-class="transition-transform duration-300 ease-out"
            enter-from-class="-translate-x-full"
            leave-active-class="transition-transform duration-300 ease-in"
            leave-to-class="-translate-x-full"
        >
            <aside v-if="showMobileMenu" class="lg:hidden fixed top-0 left-0 bottom-0 w-72 max-w-[85vw] bg-ink z-[9999] flex flex-col shadow-hard">
                <!-- Drawer Header -->
                <div class="h-16 flex items-center justify-between px-4 border-b border-ink-3 flex-shrink-0">
                    <Link :href="route('dashboard')" @click="closeMobileMenu" class="text-lime font-bold text-xl font-display">
                        GudangKu
                    </Link>
                    <button @click="closeMobileMenu" class="text-white hover:text-lime transition p-2 -mr-2" aria-label="Tutup menu">
                        <X class="w-6 h-6" />
                    </button>
                </div>

                <!-- Drawer Nav -->
                <div class="flex-1 overflow-y-auto py-2">
                    <!-- Direct links -->
                    <Link v-for="item in visibleNavigation.filter(n => n.direct)" :key="item.label"
                        :href="route(item.route)" @click="closeMobileMenu"
                        :class="['block px-5 py-3 text-sm font-semibold border-b border-ink-3', route().current(item.route) ? 'text-lime bg-ink-3' : 'text-white hover:text-lime hover:bg-ink-3 transition']">
                        {{ item.label }}
                    </Link>

                    <!-- Groups (accordion) -->
                    <div v-for="item in visibleNavigation.filter(n => !n.direct)" :key="item.label" class="border-b border-ink-3">
                        <button @click="toggleMobileGroup(item.label)"
                            :class="['w-full flex items-center justify-between px-5 py-3 text-sm font-semibold', isDropdownActive(item.items) ? 'text-lime' : 'text-white hover:text-lime transition']">
                            {{ item.label }}
                            <ChevronDown :class="['w-4 h-4 transition', mobileOpenGroup === item.label ? 'rotate-180' : '']" />
                        </button>
                        <div v-show="mobileOpenGroup === item.label" class="bg-ink-2 pb-1">
                            <Link v-for="subitem in item.items" :key="subitem.label"
                                :href="route(subitem.route)" @click="closeMobileMenu"
                                :class="['block pl-8 pr-5 py-2.5 text-sm', isItemActive(subitem) ? 'text-lime font-semibold' : 'text-white/80 hover:text-lime transition']">
                                {{ subitem.label }}
                            </Link>
                        </div>
                    </div>
                </div>

                <!-- Drawer Footer -->
                <div class="border-t border-ink-3 p-4 flex-shrink-0">
                    <p class="text-white/60 text-xs mb-1">Masuk sebagai</p>
                    <p class="text-white text-sm font-semibold truncate">{{ user.name }}</p>
                    <p class="text-lime/80 text-xs font-semibold mb-3">{{ roleLabel }}</p>
                    <Link :href="route('logout')" method="post" as="button" @click="closeMobileMenu"
                        class="w-full px-4 py-2 text-sm font-semibold text-ink bg-lime hover:bg-yellow-300 transition text-center block">
                        Keluar
                    </Link>
                </div>
            </aside>
        </Transition>

        <!-- Page Content -->
        <div class="mt-[6.25rem] bg-canvas min-h-screen overflow-visible">
            <slot />
        </div>
    </div>
</template>