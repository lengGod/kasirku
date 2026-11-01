# GudangKu

Sistem manajemen inventori berbasis Laravel 13, Inertia.js, Vue 3, dan MySQL 8. Dirancang khusus untuk operasional gudang minimarket modern dengan alur kerja FEFO (First Expired, First Out).

## Fitur Utama

- **Manajemen Inventori**: CRUD Barang, Kategori, Satuan, Lokasi, dan Supplier.
- **Transaksi**: Barang Masuk, Barang Keluar (FEFO), dan Penyesuaian Stok (Opname).
- **Batch & Kedaluwarsa**: Pelacakan nomor batch dan tanggal kedaluwarsa secara mendetail.
- **Laporan & Analitik**: Laporan stok, stok menipis, kedaluwarsa, dan mutasi stok dengan fitur ekspor CSV.
- **Role-Based Access**: Pembatasan akses Admin, Staff, dan Viewer.
- **Dashboard**: Visualisasi mutasi stok 30 hari terakhir.

## Teknologi

- **Backend**: Laravel 13 (PHP 8.5+)
- **Frontend**: Inertia.js + Vue 3 (`<script setup>`)
- **Styling**: Tailwind CSS
- **Database**: MySQL 8
- **Icons**: Lucide Vue

## Instalasi

1. Pastikan PHP 8.5+ dan Composer terinstal.
2. Clone repository:
   ```bash
   git clone <repository-url>
   cd inventory
   ```
3. Instal dependensi:
   ```bash
   composer install
   npm install
   ```
4. Setup environment:
   ```bash
   cp .env.example .env
   php artisan key:generate
   ```
5. Jalankan migrasi dan seeder:
   ```bash
   php artisan migrate:fresh --seed
   ```
6. Jalankan aplikasi:
   ```bash
   npm run dev
   # di terminal lain:
   php artisan serve
   ```

## Konvensi Data
- Nomor Dokumen: `IN-YYYYMM-0001`, `OUT-YYYYMM-0001`, `ADJ-YYYYMM-0001`
- Batch Number: `B-YYMMDD-NN`
- Data contoh sudah disesuaikan dengan kebutuhan gudang minimarket retail.

## Lisensi
Proyek ini dibuat untuk keperluan internal manajemen inventori.
