<script setup>
import AuthenticatedLayout from '@/Layouts/AuthenticatedLayout.vue';
import PageHeader from '@/Components/PageHeader.vue';
import FormInput from '@/Components/FormInput.vue';
import FormSelect from '@/Components/FormSelect.vue';
import PrimaryButton from '@/Components/PrimaryButton.vue';
import SecondaryButton from '@/Components/SecondaryButton.vue';
import Modal from '@/Components/Modal.vue';
import { Head, Link, router } from '@inertiajs/vue3';
import { formatNumber, formatRupiah } from '@/Utils/format';
import { computed, nextTick, ref, watch } from 'vue';
import {
    Banknote,
    Minus,
    Plus,
    Search,
    ShoppingCart,
    Trash2,
    PauseCircle,
    CreditCard,
    ScanBarcode,
    X,
} from '@lucide/vue';

const props = defineProps({
    shift: Object,
    products: Array,
    categories: Array,
    customers: Array,
    paymentMethods: Array,
    heldCount: Number,
    heldSales: {
        type: Array,
        default: () => [],
    },
    resumeCart: {
        type: Object,
        default: null,
    },
    settings: Object,
});

const search = ref('');
const categoryId = ref('');
const cart = ref([]);
const customerId = ref('');
const discountTotal = ref(0);
const barcodeInput = ref('');
const showPayment = ref(false);
const showHold = ref(false);
const holdLabel = ref('');
const payments = ref([]);
const errors = ref({});
const processing = ref(false);
const barcodeRef = ref(null);

if (props.resumeCart?.items) {
    cart.value = props.resumeCart.items.map((item) => ({
        ...item,
        qty: Number(item.qty),
        price: Number(item.price),
        discount: Number(item.discount ?? 0),
        stock: Number(item.stock ?? 0),
    }));
    customerId.value = props.resumeCart.customer_id ?? '';
    discountTotal.value = Number(props.resumeCart.discount_total ?? 0);
}

const filteredProducts = computed(() => {
    const term = search.value.trim().toLowerCase();

    return props.products.filter((product) => {
        const matchesCategory = !categoryId.value || product.category === categoryId.value;
        const matchesTerm = !term
            || product.name.toLowerCase().includes(term)
            || (product.sku ?? '').toLowerCase().includes(term)
            || (product.barcode ?? '').toLowerCase().includes(term);

        return matchesCategory && matchesTerm;
    });
});

const subtotal = computed(() => cart.value.reduce((sum, item) => sum + item.qty * item.price, 0));
const itemDiscount = computed(() => cart.value.reduce((sum, item) => sum + Number(item.discount || 0), 0));
const taxableBase = computed(() => cart.value
    .filter((item) => item.is_taxable)
    .reduce((sum, item) => sum + Math.max(0, item.qty * item.price - Number(item.discount || 0)), 0));
const taxRate = computed(() => Number(props.settings?.tax_rate ?? 0) / 100);
const taxIncluded = computed(() => Boolean(props.settings?.tax_included));
const taxTotal = computed(() => {
    const base = Math.max(0, taxableBase.value - Number(discountTotal.value || 0));
    if (taxIncluded.value) return Math.round(base - base / (1 + taxRate.value));
    return Math.round(base * taxRate.value);
});
const grandBeforeRounding = computed(() => {
    const base = Math.max(0, subtotal.value - itemDiscount.value - Number(discountTotal.value || 0));
    return taxIncluded.value ? base : base + taxTotal.value;
});
const roundingStep = computed(() => Number(props.settings?.rounding_step ?? 0));
const rounding = computed(() => {
    if (!roundingStep.value) return 0;
    return Math.round(grandBeforeRounding.value / roundingStep.value) * roundingStep.value - grandBeforeRounding.value;
});
const grandTotal = computed(() => Math.round(grandBeforeRounding.value + rounding.value));
const paidTotal = computed(() => payments.value.reduce((sum, payment) => sum + Number(payment.amount || 0), 0));
const remaining = computed(() => Math.max(0, grandTotal.value - paidTotal.value));

const cartCount = computed(() => cart.value.reduce((sum, item) => sum + item.qty, 0));

const addProduct = (product) => {
    const existing = cart.value.find((item) => item.product_id === product.id);

    if (existing) {
        if (product.track_stock && existing.qty + 1 > product.stock) {
            errors.value = { items: `Stok ${product.name} tinggal ${formatNumber(product.stock, 0)}.` };
            return;
        }
        existing.qty += 1;
        return;
    }

    if (product.track_stock && product.stock <= 0) {
        errors.value = { items: `Stok ${product.name} habis.` };
        return;
    }

    cart.value.push({
        product_id: product.id,
        name: product.name,
        price: Number(product.sell_price),
        qty: 1,
        discount: 0,
        is_taxable: product.is_taxable,
        track_stock: product.track_stock,
        stock: Number(product.stock),
        unit: product.unit,
    });
};

const changeQty = (item, delta) => {
    const next = item.qty + delta;

    if (next <= 0) {
        removeItem(item);
        return;
    }

    if (item.track_stock && next > item.stock) {
        errors.value = { items: `Stok ${item.name} tinggal ${formatNumber(item.stock, 0)}.` };
        return;
    }

    item.qty = next;
};

const removeItem = (item) => {
    cart.value = cart.value.filter((row) => row.product_id !== item.product_id);
};

const clearCart = () => {
    cart.value = [];
    customerId.value = '';
    discountTotal.value = 0;
    errors.value = {};
};

const scanBarcode = async () => {
    const code = barcodeInput.value.trim();
    if (!code) return;

    try {
        const response = await fetch(route('pos.lookup', { code }));
        if (!response.ok) {
            errors.value = { items: `Barcode ${code} tidak ditemukan.` };
            return;
        }
        const data = await response.json();
        addProduct(data.product);
        barcodeInput.value = '';
        errors.value = {};
        await nextTick();
        barcodeRef.value?.focus();
    } catch (error) {
        errors.value = { items: 'Gagal mencari barcode.' };
    }
};

const openPayment = () => {
    if (!cart.value.length) {
        errors.value = { items: 'Keranjang masih kosong.' };
        return;
    }

    payments.value = [{ payment_method_id: props.paymentMethods[0]?.id ?? '', amount: grandTotal.value, reference: '' }];
    showPayment.value = true;
};

const addPaymentRow = () => {
    payments.value.push({ payment_method_id: props.paymentMethods[0]?.id ?? '', amount: remaining.value, reference: '' });
};

const removePaymentRow = (index) => {
    payments.value.splice(index, 1);
};

const checkout = () => {
    processing.value = true;
    errors.value = {};

    const payload = {
        idempotency_key: (crypto.randomUUID ? crypto.randomUUID() : String(Date.now())),
        customer_id: customerId.value || null,
        discount_total: Number(discountTotal.value || 0),
        items: cart.value.map((item) => ({
            product_id: item.product_id,
            qty: item.qty,
            discount: Number(item.discount || 0),
        })),
        payments: payments.value.map((payment) => ({
            payment_method_id: payment.payment_method_id,
            amount: Number(payment.amount),
            reference: payment.reference || null,
        })),
    };

    router.post(route('pos.checkout'), payload, {
        preserveState: true,
        preserveScroll: true,
        onError: (bag) => {
            errors.value = bag;
            processing.value = false;
            showPayment.value = false;
        },
        onFinish: () => {
            processing.value = false;
        },
    });
};

const holdBill = () => {
    if (!cart.value.length || !holdLabel.value.trim()) return;

    router.post(route('pos.hold'), {
        label: holdLabel.value,
        cart: {
            items: cart.value,
            customer_id: customerId.value || null,
            discount_total: Number(discountTotal.value || 0),
        },
    }, {
        preserveState: true,
        preserveScroll: true,
        onSuccess: () => {
            showHold.value = false;
            holdLabel.value = '';
            clearCart();
        },
    });
};

watch(search, () => {
    errors.value = {};
});
</script>

<template>
    <Head title="POS Kasir" />

    <AuthenticatedLayout>
        <div class="mx-auto max-w-7xl px-4 py-8 sm:px-6 lg:px-8">
            <PageHeader title="POS Kasir" :subtitle="`Shift ${shift?.id ?? '-'} · Kasir: ${$page.props.auth.user.name}`">
                <template #actions>
                    <SecondaryButton as="link" :href="route('pos.held')">
                        <PauseCircle class="h-4 w-4" /> Bill Ditahan ({{ heldCount }})
                    </SecondaryButton>
                    <SecondaryButton as="link" :href="route('shifts.close')">
                        Tutup Shift
                    </SecondaryButton>
                </template>
            </PageHeader>

            <div v-if="errors.items || errors.payments || errors.shift" class="mb-4 border-2 border-bad-fg bg-bad-bg p-3 text-sm font-semibold text-bad-fg">
                {{ errors.items || errors.payments || errors.shift }}
            </div>

            <div class="grid gap-6 lg:grid-cols-[1fr_420px]">
                <div class="border-2 border-ink bg-surface p-4 shadow-hard sm:p-6">
                    <div class="mb-4 grid gap-3 sm:grid-cols-[1fr_auto]">
                        <div class="relative">
                            <Search class="absolute left-3 top-1/2 h-4 w-4 -translate-y-1/2 text-muted" />
                            <input
                                v-model="search"
                                type="text"
                                placeholder="Cari nama, SKU, atau barcode..."
                                class="h-12 w-full border-2 border-ink bg-surface pl-10 pr-4 text-sm focus:border-violet-text focus:outline-none"
                            />
                        </div>
                        <div class="relative">
                            <ScanBarcode class="absolute left-3 top-1/2 h-4 w-4 -translate-y-1/2 text-violet-text" />
                            <input
                                ref="barcodeRef"
                                v-model="barcodeInput"
                                type="text"
                                placeholder="Scan barcode + Enter"
                                class="h-12 w-full border-2 border-ink bg-lime/20 pl-10 pr-4 text-sm focus:border-violet-text focus:outline-none sm:w-64"
                                @keyup.enter="scanBarcode"
                            />
                        </div>
                    </div>

                    <div class="mb-4 flex flex-wrap gap-2">
                        <button
                            type="button"
                            :class="['border-2 border-ink px-3 py-2 text-xs font-bold transition', !categoryId ? 'bg-ink text-lime' : 'bg-surface text-ink hover:bg-hi']"
                            @click="categoryId = ''"
                        >
                            Semua
                        </button>
                        <button
                            v-for="category in categories"
                            :key="category.id"
                            type="button"
                            :class="['border-2 border-ink px-3 py-2 text-xs font-bold transition', categoryId === category.name ? 'bg-ink text-lime' : 'bg-surface text-ink hover:bg-hi']"
                            @click="categoryId = category.name"
                        >
                            {{ category.name }}
                        </button>
                    </div>

                    <div class="grid max-h-[62vh] grid-cols-2 gap-3 overflow-y-auto pr-1 sm:grid-cols-3 xl:grid-cols-4">
                        <button
                            v-for="product in filteredProducts"
                            :key="product.id"
                            type="button"
                            class="group flex flex-col justify-between border-2 border-ink bg-surface p-3 text-left transition hover:bg-hi"
                            @click="addProduct(product)"
                        >
                            <div>
                                <div class="mb-2 flex items-start justify-between gap-2">
                                    <span class="bg-surface-2 px-2 py-1 text-[10px] font-bold uppercase text-muted">{{ product.category ?? '-' }}</span>
                                    <span v-if="product.track_stock" :class="['px-2 py-1 text-[10px] font-bold', product.stock > 0 ? 'bg-ok-bg text-ok-fg' : 'bg-bad-bg text-bad-fg']">
                                        {{ formatNumber(product.stock, 0) }}
                                    </span>
                                </div>
                                <p class="line-clamp-2 text-sm font-bold leading-snug text-ink">{{ product.name }}</p>
                                <p class="mt-1 text-[11px] text-muted">{{ product.sku }} · {{ product.unit }}</p>
                            </div>
                            <p class="mt-3 font-display text-base font-bold text-violet-text">{{ formatRupiah(product.sell_price) }}</p>
                        </button>
                    </div>

                    <p v-if="!filteredProducts.length" class="py-12 text-center text-sm text-muted">Produk tidak ditemukan.</p>
                </div>

                <div class="h-fit border-2 border-ink bg-surface shadow-hard lg:sticky lg:top-20">
                    <div class="flex items-center justify-between border-b-2 border-ink bg-ink px-4 py-3">
                        <div class="flex items-center gap-2 text-lime">
                            <ShoppingCart class="h-5 w-5" />
                            <span class="text-sm font-bold">Keranjang ({{ cartCount }})</span>
                        </div>
                        <button v-if="cart.length" type="button" class="text-xs font-semibold text-white/70 hover:text-red-300" @click="clearCart">
                            Kosongkan
                        </button>
                    </div>

                    <div class="max-h-[38vh] overflow-y-auto p-3">
                        <div v-if="!cart.length" class="py-8 text-center text-sm text-muted">
                            Keranjang kosong. Pilih produk atau scan barcode.
                        </div>

                        <div v-for="item in cart" :key="item.product_id" class="mb-3 border-b border-line pb-3 last:mb-0 last:border-0 last:pb-0">
                            <div class="flex items-start justify-between gap-2">
                                <div class="min-w-0">
                                    <p class="truncate text-sm font-bold text-ink">{{ item.name }}</p>
                                    <p class="text-xs text-muted">{{ formatRupiah(item.price) }} / {{ item.unit }}</p>
                                </div>
                                <button type="button" class="text-bad-fg hover:text-red-600" @click="removeItem(item)">
                                    <X class="h-4 w-4" />
                                </button>
                            </div>
                            <div class="mt-2 flex items-center justify-between gap-2">
                                <div class="flex items-center border-2 border-ink">
                                    <button type="button" class="flex h-8 w-8 items-center justify-center hover:bg-hi" @click="changeQty(item, -1)">
                                        <Minus class="h-3 w-3" />
                                    </button>
                                    <span class="w-10 text-center text-sm font-bold">{{ item.qty }}</span>
                                    <button type="button" class="flex h-8 w-8 items-center justify-center hover:bg-hi" @click="changeQty(item, 1)">
                                        <Plus class="h-3 w-3" />
                                    </button>
                                </div>
                                <p class="text-sm font-bold text-ink">{{ formatRupiah(item.qty * item.price - Number(item.discount || 0)) }}</p>
                            </div>
                        </div>
                    </div>

                    <div class="border-t-2 border-ink p-4">
                        <label class="mb-1 block text-xs font-bold uppercase tracking-wide text-muted">Pelanggan</label>
                        <FormSelect v-model="customerId" class="mb-3">
                            <option value="">Umum</option>
                            <option v-for="customer in customers" :key="customer.id" :value="customer.id">{{ customer.name }}</option>
                        </FormSelect>

                        <label class="mb-1 block text-xs font-bold uppercase tracking-wide text-muted">Diskon Transaksi (Rp)</label>
                        <FormInput v-model="discountTotal" type="number" min="0" class="mb-3" />

                        <div class="space-y-1 border-t border-line pt-3 text-sm">
                            <div class="flex justify-between"><span class="text-muted">Subtotal</span><span class="font-semibold">{{ formatRupiah(subtotal) }}</span></div>
                            <div v-if="itemDiscount" class="flex justify-between"><span class="text-muted">Diskon Item</span><span class="font-semibold">-{{ formatRupiah(itemDiscount) }}</span></div>
                            <div v-if="Number(discountTotal)" class="flex justify-between"><span class="text-muted">Diskon Transaksi</span><span class="font-semibold">-{{ formatRupiah(discountTotal) }}</span></div>
                            <div class="flex justify-between"><span class="text-muted">Pajak {{ settings.tax_rate }}%</span><span class="font-semibold">{{ formatRupiah(taxTotal) }}</span></div>
                            <div v-if="rounding" class="flex justify-between"><span class="text-muted">Pembulatan</span><span class="font-semibold">{{ formatRupiah(rounding) }}</span></div>
                            <div class="mt-2 flex justify-between border-t-2 border-ink pt-2">
                                <span class="font-display text-base font-bold text-ink">Total</span>
                                <span class="font-display text-xl font-bold text-violet-text">{{ formatRupiah(grandTotal) }}</span>
                            </div>
                        </div>

                        <div class="mt-4 grid grid-cols-2 gap-2">
                            <SecondaryButton type="button" :disabled="!cart.length" @click="showHold = true">
                                <PauseCircle class="h-4 w-4" /> Tahan
                            </SecondaryButton>
                            <PrimaryButton type="button" :disabled="!cart.length" @click="openPayment">
                                <CreditCard class="h-4 w-4" /> Bayar
                            </PrimaryButton>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <Modal :show="showPayment" max-width="lg" @close="showPayment = false">
            <div class="p-6">
                <div class="mb-4 flex items-center justify-between">
                    <h2 class="font-display text-2xl font-bold text-ink">Pembayaran</h2>
                    <button type="button" class="text-muted hover:text-ink" @click="showPayment = false"><X class="h-5 w-5" /></button>
                </div>

                <div class="mb-4 border-2 border-ink bg-lime p-4">
                    <p class="text-xs font-bold uppercase tracking-wide text-ink/70">Total Tagihan</p>
                    <p class="font-display text-3xl font-bold text-ink">{{ formatRupiah(grandTotal) }}</p>
                </div>

                <div class="space-y-3">
                    <div v-for="(payment, index) in payments" :key="index" class="border-2 border-ink p-3">
                        <div class="grid gap-2 sm:grid-cols-[1fr_1fr_auto]">
                            <FormSelect v-model="payment.payment_method_id">
                                <option v-for="method in paymentMethods" :key="method.id" :value="method.id">{{ method.name }}</option>
                            </FormSelect>
                            <FormInput v-model="payment.amount" type="number" min="0" placeholder="Jumlah" />
                            <button v-if="payments.length > 1" type="button" class="flex h-12 w-12 items-center justify-center border-2 border-ink text-bad-fg hover:bg-bad-bg" @click="removePaymentRow(index)">
                                <Trash2 class="h-4 w-4" />
                            </button>
                        </div>
                    </div>
                </div>

                <button type="button" class="mt-3 text-sm font-semibold text-violet-text underline" @click="addPaymentRow">
                    + Tambah metode pembayaran
                </button>

                <div class="mt-4 flex items-center justify-between border-t-2 border-ink pt-3 text-sm">
                    <span class="font-semibold text-muted">Sisa tagihan</span>
                    <span :class="['font-display text-xl font-bold', remaining > 0 ? 'text-bad-fg' : 'text-ok-fg']">{{ formatRupiah(remaining) }}</span>
                </div>

                <div v-if="paidTotal > grandTotal" class="mt-2 flex items-center justify-between text-sm">
                    <span class="font-semibold text-muted">Kembalian</span>
                    <span class="font-display text-xl font-bold text-ink">{{ formatRupiah(paidTotal - grandTotal) }}</span>
                </div>

                <div class="mt-5 grid grid-cols-2 gap-2">
                    <SecondaryButton type="button" @click="showPayment = false">Batal</SecondaryButton>
                    <PrimaryButton type="button" :disabled="remaining > 0 || processing" :loading="processing" @click="checkout">
                        <Banknote class="h-4 w-4" /> Simpan &amp; Cetak
                    </PrimaryButton>
                </div>
            </div>
        </Modal>

        <Modal :show="showHold" max-width="md" @close="showHold = false">
            <div class="p-6">
                <h2 class="mb-4 font-display text-2xl font-bold text-ink">Tahan Bill</h2>
                <label class="mb-1 block text-sm font-semibold text-ink">Label bill</label>
                <FormInput v-model="holdLabel" placeholder="Contoh: Meja 3 / Bu Siti" />
                <div class="mt-5 grid grid-cols-2 gap-2">
                    <SecondaryButton type="button" @click="showHold = false">Batal</SecondaryButton>
                    <PrimaryButton type="button" :disabled="!holdLabel.trim()" @click="holdBill">Tahan Bill</PrimaryButton>
                </div>
            </div>
        </Modal>
    </AuthenticatedLayout>
</template>
