# PRD: Aplikasi Kasir (KasirKu)

**Versi:** 0.1 (Draft untuk review)
**Stack:** Laravel 13, Inertia.js + Vue 3, MySQL 8, Laravel Breeze (Vue stack)
**Jenis aplikasi:** Point of Sale (POS) / kasir untuk toko dan usaha ritel
**Basis proyek:** kerangka frontend disalin dari proyek GudangKu (layout, topbar, komponen dasar, auth Breeze); seluruh backend dan isi halaman ditulis baru sesuai dokumen ini.

Catatan: struktur, stack, dan gaya dokumen ini sama dengan PRD Inventaris Gudang. Yang berbeda adalah domain utamanya, yaitu **penjualan di kasir**. Stok di sini adalah pendukung, bukan fokus utama.

---

## 1. Ringkasan

Aplikasi web kasir untuk mencatat penjualan secara cepat dan akurat: memilih atau men-scan produk, menghitung total (diskon dan pajak), menerima pembayaran, mencetak struk, lalu mengurangi stok otomatis. Dilengkapi manajemen shift kasir, retur/void, laporan penjualan dan laba, serta audit log. Tujuannya mengganti pencatatan manual atau mesin kasir sederhana dengan sistem terpusat yang cepat dipakai dan bisa diaudit.

## 2. Tujuan & Non-Tujuan

**Tujuan**
- Transaksi kasir cepat: satu transaksi selesai dalam hitungan detik, dengan scan barcode dan pintasan keyboard.
- Total, diskon, pajak, dan kembalian selalu akurat.
- Uang di laci kasir dapat direkonsiliasi lewat shift (buka dan tutup kasir).
- Stok berkurang otomatis dan peringatan stok menipis muncul.
- Setiap transaksi, retur, dan pembatalan tercatat dan bisa diaudit.
- Laporan penjualan, produk terlaris, dan laba bisa diekspor.

**Non-tujuan (di luar MVP)**
- Mode offline penuh (PWA offline-first); fase lanjutan.
- Integrasi payment gateway otomatis (QRIS dinamis, kartu EDC); MVP mencatat metode pembayaran secara manual.
- Multi-cabang/outlet dengan konsolidasi (skema disiapkan, UI belum).
- Marketplace/e-commerce, pemesanan online, dan reservasi meja.
- Akuntansi lengkap, penggajian, dan modul pembelian ke supplier (hanya penerimaan stok sederhana).
- Aplikasi mobile native (kasir dipakai lewat browser di PC/tablet).

## 3. Pengguna & Peran

| Peran | Hak akses |
|---|---|
| **Owner/Admin** | Semua fitur: produk, harga, user, pengaturan toko, laporan, persetujuan void/retur |
| **Kasir** | Transaksi penjualan, buka/tutup shift sendiri, hold bill, cetak ulang struk, lihat produk dan stok |
| **Manajer/Viewer** | Lihat dashboard dan laporan; manajer juga bisa menyetujui void/retur dengan PIN |

Breeze hanya menyediakan autentikasi, jadi peran dibuat lewat kolom `role` pada tabel `users` (enum: `owner`, `cashier`, `manager`) dengan Gate/Policy. Manajer dan Owner memiliki **PIN supervisor** untuk otorisasi aksi sensitif seperti diskon besar, void, dan retur.

## 4. Lingkup Fitur (MVP)

1. **Autentikasi** (Breeze): login, logout, lupa/reset password, edit profil.
2. **Layar Kasir (POS)**: pencarian dan scan produk, keranjang, diskon, pajak, pembayaran, struk.
3. **Shift Kasir**: buka kasir (modal awal), tutup kasir (hitung uang fisik, selisih).
4. **Produk & Master Data**: Produk, Kategori, Satuan, Pelanggan, Metode Pembayaran, Diskon/Promo sederhana.
5. **Pembayaran**: tunai, QRIS (manual), transfer, kartu (manual), dan pembayaran campuran (split).
6. **Hold Bill & Bill Terbuka**: simpan keranjang sementara dan lanjutkan nanti.
7. **Retur & Void**: pembatalan transaksi dan pengembalian barang dengan otorisasi.
8. **Stok sederhana**: stok berkurang saat penjualan, penerimaan stok, penyesuaian, dan peringatan stok menipis. Batch/kedaluwarsa bersifat opsional per produk.
9. **Barcode/QR & Label**: scan produk (scanner USB/kamera) dan cetak label harga/barcode.
10. **Struk & Cetak**: struk thermal 58/80 mm via browser dan PDF; kirim ulang/cetak ulang struk.
11. **Dashboard**: ringkasan penjualan hari ini, grafik, produk terlaris, stok menipis.
12. **Laporan & Ekspor**: penjualan, laba, per kasir, per produk, per metode bayar, shift (Excel/PDF).
13. **Manajemen User & Pengaturan Toko** (Owner/Admin).

## 5. Functional Requirements

### 5.1 Produk
- FR-01: CRUD produk dengan field: SKU (unik), barcode (opsional, unik), nama, kategori, satuan, harga beli, harga jual, foto, stok minimum, status aktif, flag `track_stock`, pajak (kena/tidak).
- FR-02: Dukungan **varian sederhana** (mis. ukuran) dan **harga bertingkat** (opsional fase 2); MVP: satu harga jual per produk.
- FR-03: Produk non-stok (jasa) boleh dijual tanpa mengurangi stok (`track_stock = false`).
- FR-04: Pencarian cepat (nama/SKU/barcode), filter, sorting, pagination server-side.
- FR-05: Produk yang sudah pernah terjual tidak boleh dihapus permanen (soft delete/nonaktifkan).
- FR-06: Opsional per produk: `track_batch` dan `track_expiry` (untuk makanan/obat). Jika aktif, penjualan mengalokasikan batch dengan aturan FEFO dan batch kedaluwarsa tidak bisa dijual.

### 5.2 Layar Kasir (POS)
- FR-07: Tata letak satu layar: area pencarian/scan dan grid produk di kiri, keranjang dan total di kanan, tombol bayar besar di bawah.
- FR-08: Tambah produk via scan barcode (scanner USB/keyboard-wedge atau kamera), pencarian ketik, atau klik kartu produk. Scan berulang menaikkan qty.
- FR-09: Ubah qty, hapus item, catatan per item, dan kosongkan keranjang (dengan konfirmasi).
- FR-10: **Diskon** per item dan per transaksi (nominal atau persen). Diskon di atas batas tertentu memerlukan PIN supervisor.
- FR-11: **Pajak** (mis. PPN) dapat diaktifkan di pengaturan: mode harga *sudah termasuk pajak* atau *belum termasuk*. Rincian pajak tampil di struk.
- FR-12: Pilih pelanggan (opsional) atau transaksi umum.
- FR-13: **Hold bill**: simpan keranjang dengan label (mis. nama/nomor meja) dan lanjutkan dari daftar bill tertahan.
- FR-14: Pintasan keyboard: fokus ke pencarian (`F2`), bayar (`F9`), hold (`F4`), batalkan (`Esc`).
- FR-15: Validasi stok: penjualan produk `track_stock` melebihi stok ditolak, kecuali pengaturan "izinkan stok minus" aktif (default: tidak).

### 5.3 Pembayaran
- FR-16: Metode pembayaran: Tunai, QRIS, Transfer, Kartu, dan metode kustom (diatur Owner/Admin).
- FR-17: Pembayaran campuran (split): beberapa metode dalam satu transaksi; total bayar harus ≥ total tagihan.
- FR-18: Tunai: input uang diterima, tombol nominal cepat (pas, 50.000, 100.000), hitung kembalian otomatis.
- FR-19: Non-tunai: input nomor referensi (opsional) dan konfirmasi manual oleh kasir.
- FR-20: Pembulatan total (mis. ke 100 rupiah) dapat diatur dan dicatat sebagai baris tersendiri.
- FR-21: Setelah bayar: tampilkan ringkasan, cetak/unduh struk, dan tombol "Transaksi baru".

### 5.4 Shift Kasir
- FR-22: Kasir wajib **membuka shift** (input modal awal di laci) sebelum bertransaksi.
- FR-23: **Tutup shift**: sistem menampilkan ekspektasi kas (modal + penjualan tunai − retur tunai ± kas masuk/keluar), kasir memasukkan uang fisik, selisih dicatat.
- FR-24: **Kas masuk/keluar** selama shift (mis. beli es batu, setoran) dengan alasan wajib.
- FR-25: Laporan shift (ringkasan per metode bayar, jumlah transaksi, selisih) dapat dicetak.
- FR-26: Satu kasir hanya boleh memiliki satu shift terbuka pada satu waktu.

### 5.5 Retur & Void
- FR-27: **Void** transaksi (pembatalan penuh) hanya untuk transaksi pada shift yang sama/hari yang sama, dengan alasan wajib dan PIN supervisor.
- FR-28: **Retur** sebagian atau seluruh item dari transaksi lama dengan alasan; stok dikembalikan (kecuali barang rusak/expired) dan pengembalian uang dicatat per metode.
- FR-29: Void/retur membuat dokumen pembalik; transaksi asli tidak diubah atau dihapus.

### 5.6 Struk & Cetak
- FR-30: Struk berisi: nama toko, alamat, nomor struk, tanggal/jam, kasir, daftar item, diskon, pajak, total, metode bayar, kembalian, catatan kaki.
- FR-31: Cetak ke printer thermal lewat dialog cetak browser (lebar 58/80 mm) dan unduh PDF. Integrasi langsung ESC/POS (WebUSB/agent) menjadi fase 2.
- FR-32: Cetak ulang struk (diberi tanda "SALINAN") dan tercatat di log.
- FR-33: Cetak label barcode/harga produk (PDF, ukuran bisa dipilih).

### 5.7 Stok Pendukung
- FR-34: Penerimaan stok sederhana (barang masuk dari supplier) dengan nomor dokumen otomatis.
- FR-35: Penyesuaian/opname stok dengan alasan wajib; perubahan menjadi mutasi stok.
- FR-36: Kartu stok per produk (masuk, keluar karena penjualan, retur, penyesuaian, saldo).
- FR-37: Peringatan stok menipis di dashboard dan layar kasir; jika batch/kedaluwarsa aktif, ada daftar "mendekati kedaluwarsa".

### 5.8 Pelanggan & Promo (ringan)
- FR-38: Master pelanggan (nama, telepon, catatan). Riwayat belanja per pelanggan.
- FR-39: Promo sederhana: diskon persen/nominal pada produk atau kategori dengan periode aktif. Poin loyalti dan voucher menjadi fase 2.

### 5.9 Dashboard & Laporan
- FR-40: Dashboard: penjualan hari ini (total, jumlah transaksi, rata-rata per transaksi), perbandingan dengan kemarin, grafik 7/30 hari, produk terlaris, stok menipis, status shift.
- FR-41: Laporan: penjualan harian/periode, penjualan per produk/kategori/kasir/metode bayar, laba kotor (harga jual − harga beli saat transaksi), retur/void, laporan shift, stok.
- FR-42: Ekspor ke Excel dan PDF.

### 5.10 User, Pengaturan & Audit
- FR-43: Owner/Admin mengelola user, peran, status aktif, dan PIN supervisor.
- FR-44: Pengaturan toko: nama, alamat, logo, footer struk, pajak, pembulatan, batas diskon tanpa PIN, izinkan stok minus.
- FR-45: Log aktivitas (siapa mengubah apa dan kapan) untuk transaksi, harga, retur/void, dan pengaturan.

## 6. Business Rules

- **Transaksi yang sudah dibayar tidak bisa diedit.** Koreksi hanya lewat void atau retur yang membuat dokumen pembalik.
- Item transaksi menyimpan **snapshot** nama, harga jual, harga beli, diskon, dan pajak saat transaksi, sehingga perubahan harga di kemudian hari tidak mengubah riwayat.
- Stok **tidak pernah diedit langsung**; hanya berubah lewat penjualan, retur, penerimaan, dan penyesuaian. Tabel `stock_movements` adalah ledger append-only.
- Seluruh proses pembayaran (simpan transaksi, pembayaran, pengurangan stok, mutasi) berjalan dalam **satu DB transaction** dengan `lockForUpdate` pada baris stok untuk mencegah race condition antar kasir.
- Stok tidak boleh negatif (kecuali pengaturan eksplisit mengizinkan).
- Total bayar tidak boleh kurang dari total tagihan; kembalian hanya muncul dari pembayaran tunai.
- Transaksi hanya bisa dibuat pada **shift terbuka** milik kasir tersebut.
- Void hanya diizinkan dalam batas waktu/shift yang ditentukan; setelah itu hanya lewat retur dengan persetujuan.
- Diskon di atas batas yang diatur, void, dan retur memerlukan **PIN supervisor**.
- Nomor struk berformat `INV-YYYYMMDD-0001` (urut per hari), retur `RTN-YYYYMMDD-0001`, penerimaan stok `IN-YYYYMM-0001`, dan dibuat aman dari race condition (bukan `max(id)+1`).
- Perhitungan uang memakai tipe `decimal` (bukan float) dengan aturan pembulatan yang konsisten.
- Jika batch/kedaluwarsa aktif untuk suatu produk: alokasi FEFO, dan batch kedaluwarsa tidak boleh dijual.
- Setiap checkout memakai **idempotency key** agar klik ganda atau pengiriman ulang tidak membuat transaksi ganda.

## 7. Non-Functional Requirements

- **Kecepatan kasir:** penambahan item via scan terasa instan (< 300 ms untuk lookup); halaman POS dimuat di bawah 2 detik dengan 50.000 produk (pencarian server-side, produk populer di-cache).
- **Keamanan:** CSRF, validasi via Form Request, otorisasi via Policy/Gate, hashing password dan PIN, rate limiting login (bawaan Breeze) dan percobaan PIN.
- **Ketahanan:** penanganan koneksi putus yang jelas (pesan error, transaksi tidak hilang setengah jalan; keranjang tersimpan sementara di sisi klien).
- **Integritas data:** transaksi dan mutasi stok tidak dapat dihapus (append-only); backup MySQL terjadwal harian.
- **UI:** responsif dengan prioritas desktop dan tablet layar sentuh; tombol besar di layar kasir; bahasa Indonesia; format tanggal dan Rupiah lokal.
- **Kompatibilitas:** scanner HID umum, kamera pada browser modern (HTTPS), printer thermal via dialog cetak browser.
- **Testing:** Pest/PHPUnit untuk perhitungan total/pajak/diskon, pembayaran split, shift, void/retur, dan konsistensi stok.

## 8. Arsitektur Teknis

- **Backend:** Laravel 13 (pastikan versi PHP sesuai persyaratan resmi Laravel 13), arsitektur Controller → Form Request → Service/Action → Eloquent. Service khusus: `CheckoutService`, `PricingService` (diskon, pajak, pembulatan), `ShiftService`, `RefundService`, `StockService`, `ReceiptService`.
- **Frontend:** Inertia.js + Vue 3 (Composition API, `<script setup>`), Tailwind CSS. Komponen baru: `ProductGrid`, `CartPanel`, `PaymentModal`, `PinModal`, `ReceiptPreview`.
- **Database:** MySQL 8, InnoDB, `utf8mb4`.
- **Auth:** Laravel Breeze (stack Vue + Inertia).
- **Library pendukung (usulan):** `maatwebsite/excel`, `barryvdh/laravel-dompdf`, `spatie/laravel-activitylog`, `picqer/php-barcode-generator`, `simplesoftwareio/simple-qrcode`, `html5-qrcode` atau `@zxing/library`, Chart.js/ApexCharts.
- **Desain:** mengikuti pola `design.md` GudangKu (topbar dropdown berkelompok, sudut tajam, palet indigo + lime), dengan tambahan layout khusus layar kasir. Aksen warna dan logo diubah agar tampak berbeda dari GudangKu.

### 8.1 Penggunaan ulang dari proyek GudangKu

| Bagian | Perlakuan |
|---|---|
| Auth Breeze, layout, topbar, token Tailwind | Dipakai ulang; menu di `nav.js` diganti |
| Komponen dasar (tombol, input, kartu, modal, dropdown, tabel, chip, toast, pagination, empty state) | Dipakai ulang |
| `ScanInput`, `CameraScanner` | Dipakai ulang di layar POS |
| CRUD Produk, Kategori, Satuan | Dipakai ulang dengan penyesuaian kolom (harga jual, pajak, `track_stock`) |
| Pola `StockService` (ledger append-only, transaksi DB, `lockForUpdate`), pembuat nomor dokumen, `ScanLookupService`, `LabelService`, setup activity log dan ekspor | Dipertahankan polanya dan disesuaikan |
| Halaman Barang Masuk/Keluar gudang, laporan stok gudang, dashboard gudang | Dihapus total |
| Controller, model, migrasi, policy, seeder, test khusus penjualan | Ditulis baru |
| `prd.md`, `agent.md`, `design.md` | Diganti versi KasirKu |

## 9. Rancangan Database (Garis Besar)

| Tabel | Kolom utama |
|---|---|
| `users` | id, name, email, password, **pin_hash**, role (`owner`/`cashier`/`manager`), is_active |
| `categories` | id, name |
| `units` | id, name, short_name |
| `products` | id, sku, barcode, name, category_id, unit_id, cost_price, sell_price, is_taxable, min_stock, image, track_stock, track_batch, track_expiry, is_active, soft deletes |
| `batches` | id, product_id, batch_number, expiry_date, status (opsional, bila batch aktif) |
| `stocks` | id, product_id, batch_id (nullable), quantity |
| `customers` | id, name, phone, notes |
| `payment_methods` | id, name, type (cash/qris/transfer/card/other), is_active |
| `promotions` | id, name, type, value, target (product/category), start_at, end_at, is_active |
| `shifts` | id, user_id, opened_at, closed_at, opening_cash, expected_cash, actual_cash, difference, status |
| `cash_movements` | id, shift_id, type (in/out), amount, reason, created_by |
| `sales` | id, invoice_number, idempotency_key, shift_id, cashier_id, customer_id, subtotal, discount_total, tax_total, rounding, grand_total, paid_total, change_amount, status (paid/voided/refunded/partial_refund), voided_by, void_reason, created_at |
| `sale_items` | id, sale_id, product_id, batch_id, name_snapshot, qty, unit_price, cost_price, discount, tax, line_total |
| `sale_payments` | id, sale_id, payment_method_id, amount, reference |
| `held_sales` | id, cashier_id, label, cart_json, created_at |
| `refunds` | id, refund_number, sale_id, shift_id, total, reason, approved_by, created_by |
| `refund_items` | id, refund_id, sale_item_id, qty, amount, restock (bool) |
| `stock_ins` / `stock_in_items` | penerimaan stok sederhana (dokumen + item, batch opsional) |
| `stock_adjustments` / `stock_adjustment_items` | penyesuaian/opname |
| `stock_movements` | id, product_id, batch_id, type (sale/refund/in/adjust), qty (+/-), balance_after, reference_type, reference_id, created_by, created_at |
| `settings` | key, value (pajak, pembulatan, batas diskon, info toko, dll.) |
| `receipt_print_logs` | id, sale_id, printed_by, is_copy, created_at |

Relasi utama: `sales` 1–N `sale_items` dan `sale_payments`; `shifts` 1–N `sales`; `refunds` merujuk `sales`. `stock_movements` memakai polymorphic reference ke dokumen asalnya. Karena MySQL menganggap `NULL` berbeda pada unique index, unik `stocks` untuk produk tanpa batch dijaga lewat kolom pembantu (mis. `batch_key` default `0`) atau logika aplikasi.

## 10. Struktur Halaman (Inertia Pages)

- `Auth/*` (Login, Forgot/Reset Password): bawaan Breeze
- `Dashboard`
- `Pos/Index` (layar kasir), `Pos/Held` (bill tertahan), `Pos/Receipt` (pratinjau/cetak struk)
- `Shifts/Open`, `Shifts/Close`, `Shifts/Index`, `Shifts/Show`
- `Sales/Index, Show` (riwayat transaksi, cetak ulang, void, retur)
- `Refunds/Index, Create, Show`
- `Products/Index, Create, Edit, Show` (Show berisi kartu stok)
- `Categories`, `Units`, `Customers`, `PaymentMethods`, `Promotions` (CRUD sederhana)
- `Stock/Receive`, `Stock/Adjust`, `Stock/Movements`
- `Labels/Index` (cetak label barcode/harga)
- `Reports/Sales, Profit, Products, Cashiers, Payments, Shifts, Stock`
- `Users/Index, Create, Edit` (Owner/Admin)
- `Settings/Store` (Owner/Admin)
- `Profile/Edit`: bawaan Breeze

### 10.1 Usulan menu topbar

| Menu | Isi |
|---|---|
| Dashboard | Tunggal |
| **Kasir** | Tombol utama ke `Pos/Index` (tampil menonjol) |
| Penjualan (dropdown) | Riwayat Transaksi, Bill Tertahan, Retur, Shift |
| Master Data (dropdown) | Produk, Kategori, Satuan, Pelanggan, Metode Pembayaran, Promo |
| Stok (dropdown) | Penerimaan, Penyesuaian, Mutasi, Cetak Label |
| Laporan (dropdown) | Penjualan, Laba, Produk, Kasir, Metode Bayar, Shift, Stok |
| Profil (dropdown) | Profil Saya, Pengguna dan Pengaturan Toko (Owner/Admin), Keluar |

## 11. Acceptance Criteria (Contoh)

- Kasir tidak dapat memulai transaksi sebelum membuka shift.
- Scan barcode produk menambahkan item ke keranjang; scan ulang menaikkan qty.
- Total, pajak, diskon, dan kembalian dihitung benar (diuji dengan beberapa skenario, termasuk pembulatan dan harga termasuk/belum termasuk pajak).
- Pembayaran split (tunai + QRIS) yang totalnya kurang dari tagihan ditolak dengan pesan jelas.
- Penjualan melebihi stok ditolak dan stok tidak berubah; dua kasir menjual produk yang sama bersamaan tidak membuat stok negatif.
- Setelah pembayaran sukses, stok berkurang dan muncul satu baris di kartu stok per item.
- Mengirim ulang checkout yang sama (idempotency key sama) tidak membuat transaksi ganda.
- Transaksi yang sudah dibayar tidak punya tombol edit; void tanpa PIN supervisor ditolak.
- Retur sebagian mengembalikan stok sesuai qty dan mencatat pengembalian uang; transaksi asli tidak berubah.
- Tutup shift menampilkan ekspektasi kas yang benar dan mencatat selisih dengan uang fisik.
- Cetak ulang struk menampilkan tanda "SALINAN" dan tercatat di log.
- Kasir tidak bisa membuka halaman Manajemen User atau Pengaturan Toko (403).

## 12. Rencana Milestone

| Fase | Isi | Estimasi |
|---|---|---|
| 0 | Salin kerangka dari GudangKu, bersihkan modul gudang, ganti nama/branding | 2–3 hari |
| 1 | Setup peran, layout topbar baru, master data (produk, kategori, satuan, pelanggan, metode bayar) | 1 minggu |
| 2 | Layar POS: keranjang, scan, diskon, pajak, pembayaran, struk | 1,5–2 minggu |
| 3 | Shift kasir, kas masuk/keluar, hold bill | 1 minggu |
| 4 | Stok pendukung (penerimaan, penyesuaian, mutasi), peringatan stok, batch/FEFO opsional | 1 minggu |
| 5 | Void/retur dengan PIN supervisor, riwayat transaksi, cetak ulang | 1 minggu |
| 6 | Dashboard, laporan/ekspor, label barcode, audit log, testing, polishing | 1,5 minggu |

Estimasi total: sekitar 7–8 minggu untuk satu developer.

## 13. Asumsi

1. Satu toko/outlet untuk MVP (skema siap dikembangkan ke multi-outlet).
2. Pembayaran non-tunai dicatat manual; tidak ada integrasi payment gateway di MVP.
3. Harga jual satu tingkat per produk; harga bertingkat dan varian kompleks di fase lanjutan.
4. Pencetakan struk lewat dialog cetak browser; printer thermal sudah terpasang di perangkat kasir.
5. Koneksi internet/jaringan lokal tersedia selama berjualan (belum offline-first).
6. Bahasa antarmuka Indonesia saja dan mata uang Rupiah.
7. Pajak (PPN) bersifat opsional dan diatur di pengaturan toko.

## 14. Risiko & Catatan

- **Koneksi terputus saat checkout:** perlu mekanisme agar transaksi tidak ganda atau setengah tersimpan (idempotency key per transaksi).
- **Kecepatan layar POS:** harus tetap responsif dengan katalog besar; gunakan pencarian server-side, debounce, dan cache produk populer.
- **Perhitungan uang:** kesalahan pembulatan dan pajak berdampak langsung; butuh cakupan test yang kuat.
- **Kamera browser** membutuhkan HTTPS; scanner fisik tetap disarankan untuk volume tinggi.
- **Printer thermal via browser** kurang mulus dibanding integrasi ESC/POS langsung; dijadwalkan sebagai peningkatan fase 2.
- **Sisa referensi gudang** setelah menyalin proyek (route, policy, string bahasa) dapat menimbulkan error; hapus modul gudang secara utuh, bukan sebagian.
- **Migrasi data awal** (produk dari Excel) perlu fitur impor; belum masuk MVP.

## 15. Pertanyaan Terbuka

- Jenis usaha target (toko kelontong, kafe/restoran, apotek, fashion)? Ini memengaruhi fitur seperti meja/pesanan dapur, batch/kedaluwarsa, dan varian ukuran.
- Apakah perlu **multi-outlet/cabang** sejak awal?
- Apakah perlu **pajak (PPN)** dan **service charge**?
- Metode pembayaran apa saja yang dipakai, dan apakah perlu integrasi **QRIS dinamis** nanti?
- Apakah perlu **poin loyalti, voucher, atau member**?
- Apakah perlu fitur **meja/dine-in** dan pengiriman pesanan ke dapur?
- Jenis dan ukuran **printer struk** yang dipakai (58 mm atau 80 mm)?
- Apakah perlu **impor produk dari Excel** di MVP?
- Peran apa saja yang benar-benar dibutuhkan selain tiga di atas?
