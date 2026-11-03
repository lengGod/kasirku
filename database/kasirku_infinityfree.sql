-- MySQL dump 10.13  Distrib 8.0.30, for Win64 (x86_64)
--
-- Host: localhost    Database: kasirku_deploy
-- ------------------------------------------------------
-- Server version	8.0.30

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `activity_log`
--

DROP TABLE IF EXISTS `activity_log`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `activity_log` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `log_name` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `description` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `subject_type` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `subject_id` bigint unsigned NOT NULL,
  `causer_type` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `causer_id` bigint unsigned NOT NULL,
  `properties` json DEFAULT NULL,
  `batch_uuid` char(36) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `event` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `activity_log_subject_type_subject_id_index` (`subject_type`,`subject_id`),
  KEY `activity_log_causer_type_causer_id_index` (`causer_type`,`causer_id`),
  KEY `activity_log_log_name_index` (`log_name`),
  KEY `activity_log_batch_uuid_index` (`batch_uuid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `activity_log`
--

LOCK TABLES `activity_log` WRITE;
/*!40000 ALTER TABLE `activity_log` DISABLE KEYS */;
/*!40000 ALTER TABLE `activity_log` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `batches`
--

DROP TABLE IF EXISTS `batches`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `batches` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `product_id` bigint unsigned NOT NULL,
  `batch_number` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `expiry_date` date DEFAULT NULL,
  `is_expired` tinyint(1) NOT NULL DEFAULT '0',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `batches_product_number_unique` (`product_id`,`batch_number`),
  KEY `batches_expiry_date_index` (`expiry_date`),
  CONSTRAINT `batches_product_id_foreign` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `batches`
--

LOCK TABLES `batches` WRITE;
/*!40000 ALTER TABLE `batches` DISABLE KEYS */;
/*!40000 ALTER TABLE `batches` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `cache`
--

DROP TABLE IF EXISTS `cache`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `cache` (
  `key` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `value` mediumtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `expiration` bigint NOT NULL,
  PRIMARY KEY (`key`),
  KEY `cache_expiration_index` (`expiration`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `cache`
--

LOCK TABLES `cache` WRITE;
/*!40000 ALTER TABLE `cache` DISABLE KEYS */;
/*!40000 ALTER TABLE `cache` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `cache_locks`
--

DROP TABLE IF EXISTS `cache_locks`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `cache_locks` (
  `key` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `owner` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `expiration` bigint NOT NULL,
  PRIMARY KEY (`key`),
  KEY `cache_locks_expiration_index` (`expiration`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `cache_locks`
--

LOCK TABLES `cache_locks` WRITE;
/*!40000 ALTER TABLE `cache_locks` DISABLE KEYS */;
/*!40000 ALTER TABLE `cache_locks` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `cash_movements`
--

DROP TABLE IF EXISTS `cash_movements`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `cash_movements` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `shift_id` bigint unsigned NOT NULL,
  `type` enum('in','out') COLLATE utf8mb4_unicode_ci NOT NULL,
  `amount` decimal(15,2) NOT NULL,
  `reason` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_by` bigint unsigned DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `cash_movements_created_by_foreign` (`created_by`),
  KEY `cash_movements_shift_id_index` (`shift_id`),
  CONSTRAINT `cash_movements_created_by_foreign` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`) ON DELETE SET NULL,
  CONSTRAINT `cash_movements_shift_id_foreign` FOREIGN KEY (`shift_id`) REFERENCES `shifts` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `cash_movements`
--

LOCK TABLES `cash_movements` WRITE;
/*!40000 ALTER TABLE `cash_movements` DISABLE KEYS */;
INSERT INTO `cash_movements` VALUES (1,17,'out',75000.00,'Belanja kebutuhan operasional toko',3,'2026-10-30 08:30:00','2026-10-30 08:30:00'),(2,12,'in',50000.00,'Tambahan uang kecil dari kas toko',3,'2026-10-25 08:30:00','2026-10-25 08:30:00'),(3,6,'out',35000.00,'Pembelian kantong belanja dan tisu',3,'2026-10-19 08:30:00','2026-10-19 08:30:00');
/*!40000 ALTER TABLE `cash_movements` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `categories`
--

DROP TABLE IF EXISTS `categories`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `categories` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `categories_name_unique` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `categories`
--

LOCK TABLES `categories` WRITE;
/*!40000 ALTER TABLE `categories` DISABLE KEYS */;
INSERT INTO `categories` VALUES (1,'Makanan','2026-11-03 03:19:43','2026-11-03 03:19:43'),(2,'Minuman','2026-11-03 03:19:43','2026-11-03 03:19:43'),(3,'Sembako','2026-11-03 03:19:43','2026-11-03 03:19:43'),(4,'Perawatan Diri','2026-11-03 03:19:43','2026-11-03 03:19:43'),(5,'Jasa','2026-11-03 03:19:43','2026-11-03 03:19:43');
/*!40000 ALTER TABLE `categories` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `customers`
--

DROP TABLE IF EXISTS `customers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `customers` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `phone` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `notes` text COLLATE utf8mb4_unicode_ci,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `customers_phone_index` (`phone`)
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `customers`
--

LOCK TABLES `customers` WRITE;
/*!40000 ALTER TABLE `customers` DISABLE KEYS */;
INSERT INTO `customers` VALUES (1,'Umum',NULL,'Pelanggan tanpa identitas','2026-11-03 03:19:43','2026-11-03 03:19:43'),(2,'Bu Siti','081234567890','Langganan sembako','2026-11-03 03:19:43','2026-11-03 03:19:43'),(3,'Pak Budi','081298765432','Langganan minuman','2026-11-03 03:19:43','2026-11-03 03:19:43'),(4,'Ibu Rina Wijaya','081287654321','Pelanggan rumah tangga','2026-11-03 03:19:43','2026-11-03 03:19:43'),(5,'Andi Pratama','085712345678','Pelanggan kantor sekitar toko','2026-11-03 03:19:43','2026-11-03 03:19:43'),(6,'Siti Aminah','081356789012','Belanja kebutuhan dapur mingguan','2026-11-03 03:19:43','2026-11-03 03:19:43'),(7,'Dedi Kurniawan','082112345678','Pelanggan tetap','2026-11-03 03:19:43','2026-11-03 03:19:43'),(8,'Maya Lestari','081912345678','Pelanggan tetap','2026-11-03 03:19:44','2026-11-03 03:19:44'),(9,'Koperasi Warga Melati','0215551732','Pembelian untuk kegiatan warga','2026-11-03 03:19:44','2026-11-03 03:19:44'),(10,'Warung Bu Yani','081377654321','Pelanggan usaha kecil','2026-11-03 03:19:44','2026-11-03 03:19:44');
/*!40000 ALTER TABLE `customers` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `document_sequences`
--

DROP TABLE IF EXISTS `document_sequences`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `document_sequences` (
  `key` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `value` bigint unsigned NOT NULL DEFAULT '0',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `document_sequences`
--

LOCK TABLES `document_sequences` WRITE;
/*!40000 ALTER TABLE `document_sequences` DISABLE KEYS */;
/*!40000 ALTER TABLE `document_sequences` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `failed_jobs`
--

DROP TABLE IF EXISTS `failed_jobs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `failed_jobs` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `uuid` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `connection` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `queue` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `payload` longtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `exception` longtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `failed_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `failed_jobs_uuid_unique` (`uuid`),
  KEY `failed_jobs_connection_queue_failed_at_index` (`connection`,`queue`,`failed_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `failed_jobs`
--

LOCK TABLES `failed_jobs` WRITE;
/*!40000 ALTER TABLE `failed_jobs` DISABLE KEYS */;
/*!40000 ALTER TABLE `failed_jobs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `held_sales`
--

DROP TABLE IF EXISTS `held_sales`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `held_sales` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `cashier_id` bigint unsigned DEFAULT NULL,
  `label` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `cart_json` longtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `held_sales_cashier_id_created_at_index` (`cashier_id`,`created_at`),
  CONSTRAINT `held_sales_cashier_id_foreign` FOREIGN KEY (`cashier_id`) REFERENCES `users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `held_sales`
--

LOCK TABLES `held_sales` WRITE;
/*!40000 ALTER TABLE `held_sales` DISABLE KEYS */;
INSERT INTO `held_sales` VALUES (1,2,'Pesanan Bu Rina','{\"items\":[{\"product_id\":2,\"name\":\"Biskuit Cokelat\",\"price\":12000,\"qty\":1,\"discount\":0,\"is_taxable\":true,\"track_stock\":true,\"stock\":51,\"unit\":\"pack\"},{\"product_id\":3,\"name\":\"Mie Instan Goreng\",\"price\":3500,\"qty\":2,\"discount\":0,\"is_taxable\":false,\"track_stock\":true,\"stock\":124,\"unit\":\"pcs\"}],\"customer_id\":null,\"discount_total\":0}','2026-11-03 03:19:47','2026-11-03 03:19:47'),(2,2,'Belanja kantor RT','{\"items\":[{\"product_id\":9,\"name\":\"Gula Pasir 1kg\",\"price\":17000,\"qty\":1,\"discount\":0,\"is_taxable\":false,\"track_stock\":true,\"stock\":68,\"unit\":\"kg\"},{\"product_id\":4,\"name\":\"Air Mineral 600ml\",\"price\":4000,\"qty\":2,\"discount\":0,\"is_taxable\":false,\"track_stock\":true,\"stock\":110,\"unit\":\"btl\"}],\"customer_id\":null,\"discount_total\":0}','2026-11-03 03:19:47','2026-11-03 03:19:47');
/*!40000 ALTER TABLE `held_sales` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `job_batches`
--

DROP TABLE IF EXISTS `job_batches`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `job_batches` (
  `id` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `total_jobs` int NOT NULL,
  `pending_jobs` int NOT NULL,
  `failed_jobs` int NOT NULL,
  `failed_job_ids` longtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `options` mediumtext COLLATE utf8mb4_unicode_ci,
  `cancelled_at` int DEFAULT NULL,
  `created_at` int NOT NULL,
  `finished_at` int DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `job_batches`
--

LOCK TABLES `job_batches` WRITE;
/*!40000 ALTER TABLE `job_batches` DISABLE KEYS */;
/*!40000 ALTER TABLE `job_batches` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `jobs`
--

DROP TABLE IF EXISTS `jobs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `jobs` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `queue` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `payload` longtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `attempts` smallint unsigned NOT NULL,
  `reserved_at` int unsigned DEFAULT NULL,
  `available_at` int unsigned NOT NULL,
  `created_at` int unsigned NOT NULL,
  PRIMARY KEY (`id`),
  KEY `jobs_queue_index` (`queue`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `jobs`
--

LOCK TABLES `jobs` WRITE;
/*!40000 ALTER TABLE `jobs` DISABLE KEYS */;
/*!40000 ALTER TABLE `jobs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `migrations`
--

DROP TABLE IF EXISTS `migrations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `migrations` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `migration` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `batch` int NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=29 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `migrations`
--

LOCK TABLES `migrations` WRITE;
/*!40000 ALTER TABLE `migrations` DISABLE KEYS */;
INSERT INTO `migrations` VALUES (1,'0001_01_01_000000_create_users_table',1),(2,'0001_01_01_000001_create_cache_table',1),(3,'0001_01_01_000002_create_jobs_table',1),(4,'2026_11_02_000001_create_categories_table',1),(5,'2026_11_02_000002_create_units_table',1),(6,'2026_11_02_000003_create_products_table',1),(7,'2026_11_02_000004_create_batches_table',1),(8,'2026_11_02_000005_create_stocks_table',1),(9,'2026_11_02_000006_create_stock_movements_table',1),(10,'2026_11_02_000007_create_customers_table',1),(11,'2026_11_02_000008_create_payment_methods_table',1),(12,'2026_11_02_000009_create_promotions_table',1),(13,'2026_11_02_000010_create_shifts_table',1),(14,'2026_11_02_000011_create_cash_movements_table',1),(15,'2026_11_02_000012_create_sales_table',1),(16,'2026_11_02_000013_create_sale_items_table',1),(17,'2026_11_02_000014_create_sale_payments_table',1),(18,'2026_11_02_000015_create_held_sales_table',1),(19,'2026_11_02_000016_create_refunds_table',1),(20,'2026_11_02_000017_create_refund_items_table',1),(21,'2026_11_02_000018_create_stock_ins_table',1),(22,'2026_11_02_000019_create_stock_in_items_table',1),(23,'2026_11_02_000020_create_stock_adjustments_table',1),(24,'2026_11_02_000021_create_stock_adjustment_items_table',1),(25,'2026_11_02_000022_create_settings_table',1),(26,'2026_11_02_000023_create_document_sequences_table',1),(27,'2026_11_02_000024_create_receipt_print_logs_table',1),(28,'2026_11_02_000025_create_activity_log_table',1);
/*!40000 ALTER TABLE `migrations` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `password_reset_tokens`
--

DROP TABLE IF EXISTS `password_reset_tokens`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `password_reset_tokens` (
  `email` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `token` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`email`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `password_reset_tokens`
--

LOCK TABLES `password_reset_tokens` WRITE;
/*!40000 ALTER TABLE `password_reset_tokens` DISABLE KEYS */;
/*!40000 ALTER TABLE `password_reset_tokens` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `payment_methods`
--

DROP TABLE IF EXISTS `payment_methods`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `payment_methods` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `type` enum('cash','qris','transfer','card','other') COLLATE utf8mb4_unicode_ci NOT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT '1',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `payment_methods_type_index` (`type`),
  KEY `payment_methods_is_active_index` (`is_active`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `payment_methods`
--

LOCK TABLES `payment_methods` WRITE;
/*!40000 ALTER TABLE `payment_methods` DISABLE KEYS */;
INSERT INTO `payment_methods` VALUES (1,'Tunai','cash',1,'2026-11-03 03:19:44','2026-11-03 03:19:44'),(2,'QRIS','qris',1,'2026-11-03 03:19:44','2026-11-03 03:19:44'),(3,'Transfer Bank','transfer',1,'2026-11-03 03:19:44','2026-11-03 03:19:44'),(4,'Kartu Debit/Kredit','card',1,'2026-11-03 03:19:44','2026-11-03 03:19:44');
/*!40000 ALTER TABLE `payment_methods` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `products`
--

DROP TABLE IF EXISTS `products`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `products` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `sku` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `barcode` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `category_id` bigint unsigned NOT NULL,
  `unit_id` bigint unsigned NOT NULL,
  `cost_price` decimal(15,2) NOT NULL DEFAULT '0.00',
  `sell_price` decimal(15,2) NOT NULL DEFAULT '0.00',
  `is_taxable` tinyint(1) NOT NULL DEFAULT '0',
  `min_stock` decimal(15,3) NOT NULL DEFAULT '0.000',
  `image` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `track_stock` tinyint(1) NOT NULL DEFAULT '1',
  `track_batch` tinyint(1) NOT NULL DEFAULT '0',
  `track_expiry` tinyint(1) NOT NULL DEFAULT '0',
  `is_active` tinyint(1) NOT NULL DEFAULT '1',
  `deleted_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `products_sku_unique` (`sku`),
  UNIQUE KEY `products_barcode_unique` (`barcode`),
  KEY `products_category_id_foreign` (`category_id`),
  KEY `products_unit_id_foreign` (`unit_id`),
  KEY `products_sku_index` (`sku`),
  KEY `products_barcode_index` (`barcode`),
  KEY `products_is_active_index` (`is_active`),
  CONSTRAINT `products_category_id_foreign` FOREIGN KEY (`category_id`) REFERENCES `categories` (`id`),
  CONSTRAINT `products_unit_id_foreign` FOREIGN KEY (`unit_id`) REFERENCES `units` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=37 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `products`
--

LOCK TABLES `products` WRITE;
/*!40000 ALTER TABLE `products` DISABLE KEYS */;
INSERT INTO `products` VALUES (1,'MKN-001','8991001000011','Roti Tawar Gandum',1,1,12000.00,17000.00,1,10.000,NULL,1,0,0,1,NULL,'2026-11-03 03:19:43','2026-11-03 03:19:43'),(2,'MKN-002','8991001000028','Biskuit Cokelat',1,5,8000.00,12000.00,1,10.000,NULL,1,0,0,1,NULL,'2026-11-03 03:19:43','2026-11-03 03:19:43'),(3,'MKN-003','8991001000035','Mie Instan Goreng',1,1,2800.00,3500.00,0,10.000,NULL,1,0,0,1,NULL,'2026-11-03 03:19:43','2026-11-03 03:19:43'),(4,'MNM-001','8992002000010','Air Mineral 600ml',2,2,2500.00,4000.00,0,10.000,NULL,1,0,0,1,NULL,'2026-11-03 03:19:43','2026-11-03 03:19:43'),(5,'MNM-002','8992002000027','Teh Kotak 250ml',2,1,3500.00,5000.00,0,10.000,NULL,1,0,0,1,NULL,'2026-11-03 03:19:43','2026-11-03 03:19:43'),(6,'MNM-003','8992002000034','Kopi Sachet',2,1,1500.00,2500.00,0,10.000,NULL,1,0,0,1,NULL,'2026-11-03 03:19:43','2026-11-03 03:19:43'),(7,'SBK-001','8993003000019','Beras Premium 5kg',3,3,65000.00,75000.00,0,10.000,NULL,1,0,0,1,NULL,'2026-11-03 03:19:43','2026-11-03 03:19:43'),(8,'SBK-002','8993003000026','Minyak Goreng 1L',3,4,15000.00,19000.00,0,10.000,NULL,1,0,0,1,NULL,'2026-11-03 03:19:43','2026-11-03 03:19:43'),(9,'SBK-003','8993003000033','Gula Pasir 1kg',3,3,14000.00,17000.00,0,10.000,NULL,1,0,0,1,NULL,'2026-11-03 03:19:43','2026-11-03 03:19:43'),(10,'PRW-001','8994004000018','Sabun Mandi',4,1,4000.00,6500.00,1,10.000,NULL,1,0,0,1,NULL,'2026-11-03 03:19:43','2026-11-03 03:19:43'),(11,'PRW-002','8994004000025','Pasta Gigi',4,1,9000.00,13500.00,1,10.000,NULL,1,0,0,1,NULL,'2026-11-03 03:19:43','2026-11-03 03:19:43'),(12,'JSA-001',NULL,'Jasa Cetak Dokumen',5,1,500.00,3000.00,0,10.000,NULL,0,0,0,1,NULL,'2026-11-03 03:19:43','2026-11-03 03:19:43'),(13,'SBK-004','8999901000004','Tepung Terigu Protein Sedang 1 kg',3,3,11000.00,14000.00,0,16.000,NULL,1,0,0,1,NULL,'2026-11-03 03:19:44','2026-11-03 03:19:44'),(14,'SBK-005','8999901000005','Telur Ayam Ras 1 kg',3,3,27000.00,31000.00,0,9.000,NULL,1,0,0,1,NULL,'2026-11-03 03:19:44','2026-11-03 03:19:44'),(15,'SBK-006','8999901000006','Garam Beryodium 500 g',3,1,2500.00,4000.00,0,18.000,NULL,1,0,0,1,NULL,'2026-11-03 03:19:44','2026-11-03 03:19:44'),(16,'SBK-007','8999901000007','Kecap Manis 600 ml',3,2,13500.00,17000.00,0,9.000,NULL,1,0,0,1,NULL,'2026-11-03 03:19:44','2026-11-03 03:19:44'),(17,'SBK-008','8999901000008','Saus Sambal 340 ml',3,2,9000.00,12000.00,0,8.000,NULL,1,0,0,1,NULL,'2026-11-03 03:19:44','2026-11-03 03:19:44'),(18,'SBK-009','8999901000009','Sarden Saus Tomat 155 g',3,1,9500.00,12500.00,0,11.000,NULL,1,0,0,1,NULL,'2026-11-03 03:19:44','2026-11-03 03:19:44'),(19,'MKN-004','8999901000010','Keripik Singkong Balado 68 g',1,1,5500.00,8000.00,1,14.000,NULL,1,0,0,1,NULL,'2026-11-03 03:19:44','2026-11-03 03:19:44'),(20,'MKN-005','8999901000011','Wafer Cokelat 65 g',1,1,3500.00,5500.00,1,18.000,NULL,1,0,0,1,NULL,'2026-11-03 03:19:44','2026-11-03 03:19:44'),(21,'MKN-006','8999901000012','Biskuit Kelapa 300 g',1,5,8500.00,12000.00,1,11.000,NULL,1,0,0,1,NULL,'2026-11-03 03:19:44','2026-11-03 03:19:44'),(22,'MKN-007','8999901000013','Kacang Panggang 100 g',1,1,6000.00,9000.00,1,10.000,NULL,1,0,0,1,NULL,'2026-11-03 03:19:44','2026-11-03 03:19:44'),(23,'MKN-008','8999901000014','Roti Isi Cokelat',1,1,4500.00,7000.00,1,8.000,NULL,1,0,0,1,NULL,'2026-11-03 03:19:44','2026-11-03 03:19:44'),(24,'MKN-009','8999901000015','Bubur Instan Ayam 45 g',1,1,7000.00,10000.00,0,8.000,NULL,1,0,0,1,NULL,'2026-11-03 03:19:44','2026-11-03 03:19:44'),(25,'MNM-004','8999901000016','Minuman Teh Melati 500 ml',2,2,3500.00,6000.00,0,16.000,NULL,1,0,0,1,NULL,'2026-11-03 03:19:44','2026-11-03 03:19:44'),(26,'MNM-005','8999901000017','Minuman Isotonik Lemon 500 ml',2,2,5500.00,8500.00,0,14.000,NULL,1,0,0,1,NULL,'2026-11-03 03:19:44','2026-11-03 03:19:44'),(27,'MNM-006','8999901000018','Susu UHT Cokelat 200 ml',2,1,4500.00,7000.00,0,13.000,NULL,1,0,0,1,NULL,'2026-11-03 03:19:44','2026-11-03 03:19:44'),(28,'MNM-007','8999901000019','Jus Jambu 250 ml',2,1,3500.00,5500.00,0,12.000,NULL,1,0,0,1,NULL,'2026-11-03 03:19:44','2026-11-03 03:19:44'),(29,'MNM-008','8999901000020','Kopi Susu Siap Minum 200 ml',2,1,6500.00,10000.00,0,9.000,NULL,1,0,0,1,NULL,'2026-11-03 03:19:44','2026-11-03 03:19:44'),(30,'MNM-009','8999901000021','Soda Rasa Jeruk 390 ml',2,2,4500.00,7000.00,0,10.000,NULL,1,0,0,1,NULL,'2026-11-03 03:19:44','2026-11-03 03:19:44'),(31,'PRW-003','8999901000022','Sampo Sachet 12 ml',4,1,800.00,1500.00,1,30.000,NULL,1,0,0,1,NULL,'2026-11-03 03:19:44','2026-11-03 03:19:44'),(32,'PRW-004','8999901000023','Deterjen Bubuk 800 g',4,5,11500.00,15500.00,1,8.000,NULL,1,0,0,1,NULL,'2026-11-03 03:19:44','2026-11-03 03:19:44'),(33,'PRW-005','8999901000024','Pewangi Pakaian 800 ml',4,2,9000.00,13000.00,1,8.000,NULL,1,0,0,1,NULL,'2026-11-03 03:19:44','2026-11-03 03:19:44'),(34,'PRW-006','8999901000025','Tisu Wajah 250 Lembar',4,5,7500.00,11000.00,1,8.000,NULL,1,0,0,1,NULL,'2026-11-03 03:19:44','2026-11-03 03:19:44'),(35,'PRW-007','8999901000026','Sikat Gigi Dewasa',4,1,4500.00,7500.00,1,10.000,NULL,1,0,0,1,NULL,'2026-11-03 03:19:44','2026-11-03 03:19:44'),(36,'PRW-008','8999901000027','Sabun Cuci Piring 755 ml',4,2,11500.00,15500.00,1,8.000,NULL,1,0,0,1,NULL,'2026-11-03 03:19:44','2026-11-03 03:19:44');
/*!40000 ALTER TABLE `products` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `promotions`
--

DROP TABLE IF EXISTS `promotions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `promotions` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `type` enum('percentage','nominal') COLLATE utf8mb4_unicode_ci NOT NULL,
  `value` decimal(15,2) NOT NULL,
  `target` enum('product','category') COLLATE utf8mb4_unicode_ci NOT NULL,
  `target_id` bigint unsigned DEFAULT NULL,
  `category_id` bigint unsigned DEFAULT NULL,
  `start_at` timestamp NULL DEFAULT NULL,
  `end_at` timestamp NULL DEFAULT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT '1',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `promotions_target_id_foreign` (`target_id`),
  KEY `promotions_category_id_foreign` (`category_id`),
  CONSTRAINT `promotions_category_id_foreign` FOREIGN KEY (`category_id`) REFERENCES `categories` (`id`) ON DELETE SET NULL,
  CONSTRAINT `promotions_target_id_foreign` FOREIGN KEY (`target_id`) REFERENCES `products` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `promotions`
--

LOCK TABLES `promotions` WRITE;
/*!40000 ALTER TABLE `promotions` DISABLE KEYS */;
INSERT INTO `promotions` VALUES (1,'Hemat Minuman Akhir Pekan','percentage',10.00,'category',NULL,2,'2026-11-01 17:00:00','2026-11-08 16:59:59',1,'2026-11-03 03:19:44','2026-11-03 03:19:44'),(2,'Harga Spesial Mie Instan','nominal',500.00,'product',3,NULL,'2026-10-29 03:19:44','2026-11-13 03:19:44',1,'2026-11-03 03:19:44','2026-11-03 03:19:44'),(3,'Promo Sabun Mandi Bulanan','percentage',15.00,'product',10,NULL,'2026-10-31 17:00:00','2026-11-30 16:59:59',1,'2026-11-03 03:19:44','2026-11-03 03:19:44'),(4,'Promo Ramadan Sembako','percentage',8.00,'category',NULL,3,'2026-04-03 03:19:44','2026-05-03 03:19:44',0,'2026-11-03 03:19:44','2026-11-03 03:19:44');
/*!40000 ALTER TABLE `promotions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `receipt_print_logs`
--

DROP TABLE IF EXISTS `receipt_print_logs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `receipt_print_logs` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `sale_id` bigint unsigned NOT NULL,
  `printed_by` bigint unsigned DEFAULT NULL,
  `is_copy` tinyint(1) NOT NULL DEFAULT '0',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `receipt_print_logs_printed_by_foreign` (`printed_by`),
  KEY `receipt_print_logs_sale_id_created_at_index` (`sale_id`,`created_at`),
  CONSTRAINT `receipt_print_logs_printed_by_foreign` FOREIGN KEY (`printed_by`) REFERENCES `users` (`id`) ON DELETE SET NULL,
  CONSTRAINT `receipt_print_logs_sale_id_foreign` FOREIGN KEY (`sale_id`) REFERENCES `sales` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=43 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `receipt_print_logs`
--

LOCK TABLES `receipt_print_logs` WRITE;
/*!40000 ALTER TABLE `receipt_print_logs` DISABLE KEYS */;
INSERT INTO `receipt_print_logs` VALUES (1,1,2,0,'2026-10-14 05:17:00','2026-10-14 05:17:00'),(2,3,2,1,'2026-10-14 11:31:00','2026-10-14 11:31:00'),(3,4,2,0,'2026-10-15 05:17:00','2026-10-15 05:17:00'),(4,6,2,1,'2026-10-15 11:31:00','2026-10-15 11:31:00'),(5,7,2,0,'2026-10-16 05:17:00','2026-10-16 05:17:00'),(6,9,2,1,'2026-10-16 11:31:00','2026-10-16 11:31:00'),(7,10,2,0,'2026-10-17 05:17:00','2026-10-17 05:17:00'),(8,12,2,1,'2026-10-17 11:31:00','2026-10-17 11:31:00'),(9,13,2,0,'2026-10-18 05:17:00','2026-10-18 05:17:00'),(10,15,2,1,'2026-10-18 11:31:00','2026-10-18 11:31:00'),(11,16,2,0,'2026-10-19 05:17:00','2026-10-19 05:17:00'),(12,18,2,1,'2026-10-19 11:31:00','2026-10-19 11:31:00'),(13,19,2,0,'2026-10-20 05:17:00','2026-10-20 05:17:00'),(14,21,2,1,'2026-10-20 11:31:00','2026-10-20 11:31:00'),(15,22,2,0,'2026-10-21 05:17:00','2026-10-21 05:17:00'),(16,24,2,1,'2026-10-21 11:31:00','2026-10-21 11:31:00'),(17,25,2,0,'2026-10-22 05:17:00','2026-10-22 05:17:00'),(18,27,2,1,'2026-10-22 11:31:00','2026-10-22 11:31:00'),(19,28,2,0,'2026-10-23 05:17:00','2026-10-23 05:17:00'),(20,30,2,1,'2026-10-23 11:31:00','2026-10-23 11:31:00'),(21,31,2,0,'2026-10-24 05:17:00','2026-10-24 05:17:00'),(22,33,2,1,'2026-10-24 11:31:00','2026-10-24 11:31:00'),(23,34,2,0,'2026-10-25 05:17:00','2026-10-25 05:17:00'),(24,36,2,1,'2026-10-25 11:31:00','2026-10-25 11:31:00'),(25,37,2,0,'2026-10-26 05:17:00','2026-10-26 05:17:00'),(26,39,2,1,'2026-10-26 11:31:00','2026-10-26 11:31:00'),(27,40,2,0,'2026-10-27 05:17:00','2026-10-27 05:17:00'),(28,42,2,1,'2026-10-27 11:31:00','2026-10-27 11:31:00'),(29,43,2,0,'2026-10-28 05:17:00','2026-10-28 05:17:00'),(30,45,2,1,'2026-10-28 11:31:00','2026-10-28 11:31:00'),(31,46,2,0,'2026-10-29 05:17:00','2026-10-29 05:17:00'),(32,48,2,1,'2026-10-29 11:31:00','2026-10-29 11:31:00'),(33,49,2,0,'2026-10-30 05:17:00','2026-10-30 05:17:00'),(34,51,2,1,'2026-10-30 11:31:00','2026-10-30 11:31:00'),(35,52,2,0,'2026-10-31 05:17:00','2026-10-31 05:17:00'),(36,54,2,1,'2026-10-31 11:31:00','2026-10-31 11:31:00'),(37,55,2,0,'2026-11-01 05:17:00','2026-11-01 05:17:00'),(38,57,2,1,'2026-11-01 11:31:00','2026-11-01 11:31:00'),(39,58,2,0,'2026-11-02 05:17:00','2026-11-02 05:17:00'),(40,60,2,1,'2026-11-02 11:31:00','2026-11-02 11:31:00'),(41,61,2,0,'2026-11-03 05:17:00','2026-11-03 05:17:00'),(42,63,2,1,'2026-11-03 11:31:00','2026-11-03 11:31:00');
/*!40000 ALTER TABLE `receipt_print_logs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `refund_items`
--

DROP TABLE IF EXISTS `refund_items`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `refund_items` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `refund_id` bigint unsigned NOT NULL,
  `sale_item_id` bigint unsigned NOT NULL,
  `qty` decimal(15,3) NOT NULL,
  `amount` decimal(15,2) NOT NULL,
  `restock` tinyint(1) NOT NULL DEFAULT '1',
  PRIMARY KEY (`id`),
  KEY `refund_items_refund_id_index` (`refund_id`),
  KEY `refund_items_sale_item_id_index` (`sale_item_id`),
  CONSTRAINT `refund_items_refund_id_foreign` FOREIGN KEY (`refund_id`) REFERENCES `refunds` (`id`) ON DELETE CASCADE,
  CONSTRAINT `refund_items_sale_item_id_foreign` FOREIGN KEY (`sale_item_id`) REFERENCES `sale_items` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `refund_items`
--

LOCK TABLES `refund_items` WRITE;
/*!40000 ALTER TABLE `refund_items` DISABLE KEYS */;
INSERT INTO `refund_items` VALUES (1,1,181,1.000,2500.00,1);
/*!40000 ALTER TABLE `refund_items` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `refunds`
--

DROP TABLE IF EXISTS `refunds`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `refunds` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `refund_number` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `sale_id` bigint unsigned NOT NULL,
  `shift_id` bigint unsigned NOT NULL,
  `total` decimal(15,2) NOT NULL DEFAULT '0.00',
  `reason` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `approved_by` bigint unsigned DEFAULT NULL,
  `created_by` bigint unsigned DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `refunds_refund_number_unique` (`refund_number`),
  KEY `refunds_shift_id_foreign` (`shift_id`),
  KEY `refunds_approved_by_foreign` (`approved_by`),
  KEY `refunds_created_by_foreign` (`created_by`),
  KEY `refunds_sale_id_shift_id_index` (`sale_id`,`shift_id`),
  CONSTRAINT `refunds_approved_by_foreign` FOREIGN KEY (`approved_by`) REFERENCES `users` (`id`) ON DELETE SET NULL,
  CONSTRAINT `refunds_created_by_foreign` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`) ON DELETE SET NULL,
  CONSTRAINT `refunds_sale_id_foreign` FOREIGN KEY (`sale_id`) REFERENCES `sales` (`id`) ON DELETE CASCADE,
  CONSTRAINT `refunds_shift_id_foreign` FOREIGN KEY (`shift_id`) REFERENCES `shifts` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `refunds`
--

LOCK TABLES `refunds` WRITE;
/*!40000 ALTER TABLE `refunds` DISABLE KEYS */;
INSERT INTO `refunds` VALUES (1,'RTN-20261103-0001',61,21,2500.00,'Kemasan produk rusak saat diterima pelanggan',2,2,'2026-11-03 03:19:47','2026-11-03 03:19:47');
/*!40000 ALTER TABLE `refunds` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sale_items`
--

DROP TABLE IF EXISTS `sale_items`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sale_items` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `sale_id` bigint unsigned NOT NULL,
  `product_id` bigint unsigned NOT NULL,
  `batch_id` bigint unsigned DEFAULT NULL,
  `name_snapshot` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `qty` decimal(15,3) NOT NULL,
  `unit_price` decimal(15,2) NOT NULL,
  `cost_price` decimal(15,2) NOT NULL DEFAULT '0.00',
  `discount` decimal(15,2) NOT NULL DEFAULT '0.00',
  `tax` decimal(15,2) NOT NULL DEFAULT '0.00',
  `line_total` decimal(15,2) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `sale_items_batch_id_foreign` (`batch_id`),
  KEY `sale_items_sale_id_index` (`sale_id`),
  KEY `sale_items_product_id_index` (`product_id`),
  CONSTRAINT `sale_items_batch_id_foreign` FOREIGN KEY (`batch_id`) REFERENCES `batches` (`id`) ON DELETE SET NULL,
  CONSTRAINT `sale_items_product_id_foreign` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON DELETE CASCADE,
  CONSTRAINT `sale_items_sale_id_foreign` FOREIGN KEY (`sale_id`) REFERENCES `sales` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=190 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sale_items`
--

LOCK TABLES `sale_items` WRITE;
/*!40000 ALTER TABLE `sale_items` DISABLE KEYS */;
INSERT INTO `sale_items` VALUES (1,1,2,NULL,'Biskuit Cokelat',1.000,12000.00,8000.00,0.00,396.00,12396.00),(2,1,13,NULL,'Tepung Terigu Protein Sedang 1 kg',2.000,14000.00,11000.00,0.00,0.00,28000.00),(3,2,7,NULL,'Beras Premium 5kg',1.000,75000.00,65000.00,500.00,0.00,74500.00),(4,2,18,NULL,'Sarden Saus Tomat 155 g',2.000,12500.00,9500.00,0.00,0.00,25000.00),(5,2,29,NULL,'Kopi Susu Siap Minum 200 ml',1.000,10000.00,6500.00,0.00,0.00,10000.00),(6,3,12,NULL,'Jasa Cetak Dokumen',1.000,3000.00,500.00,0.00,0.00,3000.00),(7,3,23,NULL,'Roti Isi Cokelat',2.000,7000.00,4500.00,0.00,610.95,14610.95),(8,3,34,NULL,'Tisu Wajah 250 Lembar',1.000,11000.00,7500.00,0.00,480.03,11480.03),(9,3,9,NULL,'Gula Pasir 1kg',2.000,17000.00,14000.00,0.00,0.00,34000.00),(10,4,31,NULL,'Sampo Sachet 12 ml',2.000,1500.00,800.00,0.00,28.29,3028.29),(11,4,6,NULL,'Kopi Sachet',1.000,2500.00,1500.00,0.00,0.00,2500.00),(12,4,17,NULL,'Saus Sambal 340 ml',2.000,12000.00,9000.00,0.00,0.00,24000.00),(13,4,28,NULL,'Jus Jambu 250 ml',1.000,5500.00,3500.00,0.00,0.00,5500.00),(14,5,36,NULL,'Sabun Cuci Piring 755 ml',2.000,15500.00,11500.00,500.00,3355.00,33855.00),(15,5,11,NULL,'Pasta Gigi',1.000,13500.00,9000.00,0.00,1485.00,14985.00),(16,6,5,NULL,'Teh Kotak 250ml',2.000,5000.00,3500.00,0.00,0.00,10000.00),(17,6,16,NULL,'Kecap Manis 600 ml',1.000,17000.00,13500.00,0.00,0.00,17000.00),(18,6,27,NULL,'Susu UHT Cokelat 200 ml',2.000,7000.00,4500.00,0.00,0.00,14000.00),(19,7,24,NULL,'Bubur Instan Ayam 45 g',1.000,10000.00,7000.00,0.00,0.00,10000.00),(20,7,35,NULL,'Sikat Gigi Dewasa',2.000,7500.00,4500.00,0.00,1126.19,16126.19),(21,7,10,NULL,'Sabun Mandi',1.000,6500.00,4000.00,0.00,488.02,6988.02),(22,8,29,NULL,'Kopi Susu Siap Minum 200 ml',1.000,10000.00,6500.00,500.00,0.00,9500.00),(23,8,4,NULL,'Air Mineral 600ml',2.000,4000.00,2500.00,0.00,0.00,8000.00),(24,8,15,NULL,'Garam Beryodium 500 g',1.000,4000.00,2500.00,0.00,0.00,4000.00),(25,8,26,NULL,'Minuman Isotonik Lemon 500 ml',2.000,8500.00,5500.00,0.00,0.00,17000.00),(26,9,34,NULL,'Tisu Wajah 250 Lembar',1.000,11000.00,7500.00,0.00,289.20,11289.20),(27,9,9,NULL,'Gula Pasir 1kg',2.000,17000.00,14000.00,0.00,0.00,34000.00),(28,10,17,NULL,'Saus Sambal 340 ml',2.000,12000.00,9000.00,0.00,0.00,24000.00),(29,10,28,NULL,'Jus Jambu 250 ml',1.000,5500.00,3500.00,0.00,0.00,5500.00),(30,11,22,NULL,'Kacang Panggang 100 g',2.000,9000.00,6000.00,500.00,857.12,18357.12),(31,11,33,NULL,'Pewangi Pakaian 800 ml',1.000,13000.00,9000.00,0.00,636.72,13636.72),(32,11,8,NULL,'Minyak Goreng 1L',2.000,19000.00,15000.00,0.00,0.00,38000.00),(33,12,27,NULL,'Susu UHT Cokelat 200 ml',2.000,7000.00,4500.00,0.00,0.00,14000.00),(34,12,2,NULL,'Biskuit Cokelat',1.000,12000.00,8000.00,0.00,243.63,12243.63),(35,12,13,NULL,'Tepung Terigu Protein Sedang 1 kg',2.000,14000.00,11000.00,0.00,0.00,28000.00),(36,12,24,NULL,'Bubur Instan Ayam 45 g',1.000,10000.00,7000.00,0.00,0.00,10000.00),(37,13,10,NULL,'Sabun Mandi',1.000,6500.00,4000.00,0.00,167.81,6667.81),(38,13,21,NULL,'Biskuit Kelapa 300 g',2.000,12000.00,8500.00,0.00,619.59,24619.59),(39,13,32,NULL,'Deterjen Bubuk 800 g',1.000,15500.00,11500.00,0.00,400.15,15900.15),(40,13,7,NULL,'Beras Premium 5kg',2.000,75000.00,65000.00,0.00,0.00,150000.00),(41,14,15,NULL,'Garam Beryodium 500 g',1.000,4000.00,2500.00,500.00,0.00,3500.00),(42,14,26,NULL,'Minuman Isotonik Lemon 500 ml',2.000,8500.00,5500.00,0.00,0.00,17000.00),(43,15,20,NULL,'Wafer Cokelat 65 g',1.000,5500.00,3500.00,0.00,425.00,5925.00),(44,15,31,NULL,'Sampo Sachet 12 ml',2.000,1500.00,800.00,0.00,231.82,3231.82),(45,15,6,NULL,'Kopi Sachet',1.000,2500.00,1500.00,0.00,0.00,2500.00),(46,16,3,NULL,'Mie Instan Goreng',2.000,3500.00,2800.00,0.00,0.00,7000.00),(47,16,14,NULL,'Telur Ayam Ras 1 kg',1.000,31000.00,27000.00,0.00,0.00,31000.00),(48,16,25,NULL,'Minuman Teh Melati 500 ml',2.000,6000.00,3500.00,0.00,0.00,12000.00),(49,17,8,NULL,'Minyak Goreng 1L',2.000,19000.00,15000.00,500.00,0.00,37500.00),(50,17,19,NULL,'Keripik Singkong Balado 68 g',1.000,8000.00,5500.00,0.00,109.15,8109.15),(51,17,30,NULL,'Soda Rasa Jeruk 390 ml',2.000,7000.00,4500.00,0.00,0.00,14000.00),(52,17,5,NULL,'Teh Kotak 250ml',1.000,5000.00,3500.00,0.00,0.00,5000.00),(53,18,13,NULL,'Tepung Terigu Protein Sedang 1 kg',2.000,14000.00,11000.00,0.00,0.00,28000.00),(54,18,24,NULL,'Bubur Instan Ayam 45 g',1.000,10000.00,7000.00,0.00,0.00,10000.00),(55,19,32,NULL,'Deterjen Bubuk 800 g',1.000,15500.00,11500.00,0.00,159.68,15659.68),(56,19,7,NULL,'Beras Premium 5kg',2.000,75000.00,65000.00,0.00,0.00,150000.00),(57,20,1,NULL,'Roti Tawar Gandum',1.000,17000.00,12000.00,500.00,1445.85,17945.85),(58,20,12,NULL,'Jasa Cetak Dokumen',2.000,3000.00,500.00,0.00,0.00,6000.00),(59,20,23,NULL,'Roti Isi Cokelat',1.000,7000.00,4500.00,0.00,613.39,7613.39),(60,21,6,NULL,'Kopi Sachet',1.000,2500.00,1500.00,0.00,0.00,2500.00),(61,21,17,NULL,'Saus Sambal 340 ml',2.000,12000.00,9000.00,0.00,0.00,24000.00),(62,21,28,NULL,'Jus Jambu 250 ml',1.000,5500.00,3500.00,0.00,0.00,5500.00),(63,21,3,NULL,'Mie Instan Goreng',2.000,3500.00,2800.00,0.00,0.00,7000.00),(64,22,25,NULL,'Minuman Teh Melati 500 ml',2.000,6000.00,3500.00,0.00,0.00,12000.00),(65,22,36,NULL,'Sabun Cuci Piring 755 ml',1.000,15500.00,11500.00,0.00,1382.80,16882.80),(66,22,11,NULL,'Pasta Gigi',2.000,13500.00,9000.00,0.00,2408.74,29408.74),(67,22,22,NULL,'Kacang Panggang 100 g',1.000,9000.00,6000.00,0.00,802.91,9802.91),(68,23,30,NULL,'Soda Rasa Jeruk 390 ml',2.000,7000.00,4500.00,500.00,0.00,13500.00),(69,23,5,NULL,'Teh Kotak 250ml',1.000,5000.00,3500.00,0.00,0.00,5000.00),(70,24,35,NULL,'Sikat Gigi Dewasa',2.000,7500.00,4500.00,0.00,1613.74,16613.74),(71,24,10,NULL,'Sabun Mandi',1.000,6500.00,4000.00,0.00,699.29,7199.29),(72,24,21,NULL,'Biskuit Kelapa 300 g',2.000,12000.00,8500.00,0.00,2581.98,26581.98),(73,25,18,NULL,'Sarden Saus Tomat 155 g',1.000,12500.00,9500.00,0.00,0.00,12500.00),(74,25,29,NULL,'Kopi Susu Siap Minum 200 ml',2.000,10000.00,6500.00,0.00,0.00,20000.00),(75,25,4,NULL,'Air Mineral 600ml',1.000,4000.00,2500.00,0.00,0.00,4000.00),(76,26,23,NULL,'Roti Isi Cokelat',1.000,7000.00,4500.00,500.00,499.87,6999.87),(77,26,34,NULL,'Tisu Wajah 250 Lembar',2.000,11000.00,7500.00,0.00,1691.86,23691.86),(78,26,9,NULL,'Gula Pasir 1kg',1.000,17000.00,14000.00,0.00,0.00,17000.00),(79,26,20,NULL,'Wafer Cokelat 65 g',2.000,5500.00,3500.00,0.00,845.93,11845.93),(80,27,28,NULL,'Jus Jambu 250 ml',1.000,5500.00,3500.00,0.00,0.00,5500.00),(81,27,3,NULL,'Mie Instan Goreng',2.000,3500.00,2800.00,0.00,0.00,7000.00),(82,28,11,NULL,'Pasta Gigi',2.000,13500.00,9000.00,0.00,2970.00,29970.00),(83,28,22,NULL,'Kacang Panggang 100 g',1.000,9000.00,6000.00,0.00,990.00,9990.00),(84,29,16,NULL,'Kecap Manis 600 ml',2.000,17000.00,13500.00,500.00,0.00,33500.00),(85,29,27,NULL,'Susu UHT Cokelat 200 ml',1.000,7000.00,4500.00,0.00,0.00,7000.00),(86,29,2,NULL,'Biskuit Cokelat',2.000,12000.00,8000.00,0.00,982.33,24982.33),(87,30,21,NULL,'Biskuit Kelapa 300 g',2.000,12000.00,8500.00,0.00,513.68,24513.68),(88,30,32,NULL,'Deterjen Bubuk 800 g',1.000,15500.00,11500.00,0.00,331.75,15831.75),(89,30,7,NULL,'Beras Premium 5kg',2.000,75000.00,65000.00,0.00,0.00,150000.00),(90,30,18,NULL,'Sarden Saus Tomat 155 g',1.000,12500.00,9500.00,0.00,0.00,12500.00),(91,31,4,NULL,'Air Mineral 600ml',1.000,4000.00,2500.00,0.00,0.00,4000.00),(92,31,15,NULL,'Garam Beryodium 500 g',2.000,4000.00,2500.00,0.00,0.00,8000.00),(93,31,26,NULL,'Minuman Isotonik Lemon 500 ml',1.000,8500.00,5500.00,0.00,0.00,8500.00),(94,31,1,NULL,'Roti Tawar Gandum',2.000,17000.00,12000.00,0.00,2333.21,36333.21),(95,32,9,NULL,'Gula Pasir 1kg',1.000,17000.00,14000.00,500.00,0.00,16500.00),(96,32,20,NULL,'Wafer Cokelat 65 g',2.000,5500.00,3500.00,0.00,484.00,11484.00),(97,33,14,NULL,'Telur Ayam Ras 1 kg',1.000,31000.00,27000.00,0.00,0.00,31000.00),(98,33,25,NULL,'Minuman Teh Melati 500 ml',2.000,6000.00,3500.00,0.00,0.00,12000.00),(99,33,36,NULL,'Sabun Cuci Piring 755 ml',1.000,15500.00,11500.00,0.00,444.03,15944.03),(100,34,33,NULL,'Pewangi Pakaian 800 ml',2.000,13000.00,9000.00,0.00,1969.18,27969.18),(101,34,8,NULL,'Minyak Goreng 1L',1.000,19000.00,15000.00,0.00,0.00,19000.00),(102,34,19,NULL,'Keripik Singkong Balado 68 g',2.000,8000.00,5500.00,0.00,1211.80,17211.80),(103,35,2,NULL,'Biskuit Cokelat',2.000,12000.00,8000.00,500.00,1232.85,24732.85),(104,35,13,NULL,'Tepung Terigu Protein Sedang 1 kg',1.000,14000.00,11000.00,0.00,0.00,14000.00),(105,35,24,NULL,'Bubur Instan Ayam 45 g',2.000,10000.00,7000.00,0.00,0.00,20000.00),(106,35,35,NULL,'Sikat Gigi Dewasa',1.000,7500.00,4500.00,0.00,393.46,7893.46),(107,36,7,NULL,'Beras Premium 5kg',2.000,75000.00,65000.00,0.00,0.00,150000.00),(108,36,18,NULL,'Sarden Saus Tomat 155 g',1.000,12500.00,9500.00,0.00,0.00,12500.00),(109,37,26,NULL,'Minuman Isotonik Lemon 500 ml',1.000,8500.00,5500.00,0.00,0.00,8500.00),(110,37,1,NULL,'Roti Tawar Gandum',2.000,17000.00,12000.00,0.00,2992.00,36992.00),(111,38,31,NULL,'Sampo Sachet 12 ml',1.000,1500.00,800.00,500.00,6.11,1006.11),(112,38,6,NULL,'Kopi Sachet',2.000,2500.00,1500.00,0.00,0.00,5000.00),(113,38,17,NULL,'Saus Sambal 340 ml',1.000,12000.00,9000.00,0.00,0.00,12000.00),(114,39,36,NULL,'Sabun Cuci Piring 755 ml',1.000,15500.00,11500.00,0.00,1683.00,17183.00),(115,39,11,NULL,'Pasta Gigi',2.000,13500.00,9000.00,0.00,2931.68,29931.68),(116,39,22,NULL,'Kacang Panggang 100 g',1.000,9000.00,6000.00,0.00,977.23,9977.23),(117,39,33,NULL,'Pewangi Pakaian 800 ml',2.000,13000.00,9000.00,0.00,2823.10,28823.10),(118,40,19,NULL,'Keripik Singkong Balado 68 g',2.000,8000.00,5500.00,0.00,563.20,16563.20),(119,40,30,NULL,'Soda Rasa Jeruk 390 ml',1.000,7000.00,4500.00,0.00,0.00,7000.00),(120,40,5,NULL,'Teh Kotak 250ml',2.000,5000.00,3500.00,0.00,0.00,10000.00),(121,40,16,NULL,'Kecap Manis 600 ml',1.000,17000.00,13500.00,0.00,0.00,17000.00),(122,41,24,NULL,'Bubur Instan Ayam 45 g',2.000,10000.00,7000.00,500.00,0.00,19500.00),(123,41,35,NULL,'Sikat Gigi Dewasa',1.000,7500.00,4500.00,0.00,229.17,7729.17),(124,42,29,NULL,'Kopi Susu Siap Minum 200 ml',2.000,10000.00,6500.00,0.00,0.00,20000.00),(125,42,4,NULL,'Air Mineral 600ml',1.000,4000.00,2500.00,0.00,0.00,4000.00),(126,42,15,NULL,'Garam Beryodium 500 g',2.000,4000.00,2500.00,0.00,0.00,8000.00),(127,43,12,NULL,'Jasa Cetak Dokumen',1.000,3000.00,500.00,0.00,0.00,3000.00),(128,43,23,NULL,'Roti Isi Cokelat',2.000,7000.00,4500.00,0.00,1375.00,15375.00),(129,43,34,NULL,'Tisu Wajah 250 Lembar',1.000,11000.00,7500.00,0.00,1080.36,12080.36),(130,44,17,NULL,'Saus Sambal 340 ml',1.000,12000.00,9000.00,500.00,0.00,11500.00),(131,44,28,NULL,'Jus Jambu 250 ml',2.000,5500.00,3500.00,0.00,0.00,11000.00),(132,44,3,NULL,'Mie Instan Goreng',1.000,3500.00,2800.00,0.00,0.00,3500.00),(133,44,14,NULL,'Telur Ayam Ras 1 kg',2.000,31000.00,27000.00,0.00,0.00,62000.00),(134,45,22,NULL,'Kacang Panggang 100 g',1.000,9000.00,6000.00,0.00,961.71,9961.71),(135,45,33,NULL,'Pewangi Pakaian 800 ml',2.000,13000.00,9000.00,0.00,2778.29,28778.29),(136,46,5,NULL,'Teh Kotak 250ml',2.000,5000.00,3500.00,0.00,0.00,10000.00),(137,46,16,NULL,'Kecap Manis 600 ml',1.000,17000.00,13500.00,0.00,0.00,17000.00),(138,47,10,NULL,'Sabun Mandi',2.000,6500.00,4000.00,500.00,1375.00,13875.00),(139,47,21,NULL,'Biskuit Kelapa 300 g',1.000,12000.00,8500.00,0.00,1320.00,13320.00),(140,47,32,NULL,'Deterjen Bubuk 800 g',2.000,15500.00,11500.00,0.00,3410.00,34410.00),(141,48,15,NULL,'Garam Beryodium 500 g',2.000,4000.00,2500.00,0.00,0.00,8000.00),(142,48,26,NULL,'Minuman Isotonik Lemon 500 ml',1.000,8500.00,5500.00,0.00,0.00,8500.00),(143,48,1,NULL,'Roti Tawar Gandum',2.000,17000.00,12000.00,0.00,2332.39,36332.39),(144,48,12,NULL,'Jasa Cetak Dokumen',1.000,3000.00,500.00,0.00,0.00,3000.00),(145,49,34,NULL,'Tisu Wajah 250 Lembar',1.000,11000.00,7500.00,0.00,441.03,11441.03),(146,49,9,NULL,'Gula Pasir 1kg',2.000,17000.00,14000.00,0.00,0.00,34000.00),(147,49,20,NULL,'Wafer Cokelat 65 g',1.000,5500.00,3500.00,0.00,220.51,5720.51),(148,49,31,NULL,'Sampo Sachet 12 ml',2.000,1500.00,800.00,0.00,120.28,3120.28),(149,50,3,NULL,'Mie Instan Goreng',1.000,3500.00,2800.00,500.00,0.00,3000.00),(150,50,14,NULL,'Telur Ayam Ras 1 kg',2.000,31000.00,27000.00,0.00,0.00,62000.00),(151,51,8,NULL,'Minyak Goreng 1L',1.000,19000.00,15000.00,0.00,0.00,19000.00),(152,51,19,NULL,'Keripik Singkong Balado 68 g',2.000,8000.00,5500.00,0.00,654.51,16654.51),(153,51,30,NULL,'Soda Rasa Jeruk 390 ml',1.000,7000.00,4500.00,0.00,0.00,7000.00),(154,52,27,NULL,'Susu UHT Cokelat 200 ml',2.000,7000.00,4500.00,0.00,0.00,14000.00),(155,52,2,NULL,'Biskuit Cokelat',1.000,12000.00,8000.00,0.00,293.33,12293.33),(156,52,13,NULL,'Tepung Terigu Protein Sedang 1 kg',2.000,14000.00,11000.00,0.00,0.00,28000.00),(157,53,32,NULL,'Deterjen Bubuk 800 g',2.000,15500.00,11500.00,500.00,728.31,31228.31),(158,53,7,NULL,'Beras Premium 5kg',1.000,75000.00,65000.00,0.00,0.00,75000.00),(159,53,18,NULL,'Sarden Saus Tomat 155 g',2.000,12500.00,9500.00,0.00,0.00,25000.00),(160,53,29,NULL,'Kopi Susu Siap Minum 200 ml',1.000,10000.00,6500.00,0.00,0.00,10000.00),(161,54,1,NULL,'Roti Tawar Gandum',2.000,17000.00,12000.00,0.00,3343.87,37343.87),(162,54,12,NULL,'Jasa Cetak Dokumen',1.000,3000.00,500.00,0.00,0.00,3000.00),(163,55,20,NULL,'Wafer Cokelat 65 g',1.000,5500.00,3500.00,0.00,605.00,6105.00),(164,55,31,NULL,'Sampo Sachet 12 ml',2.000,1500.00,800.00,0.00,330.00,3330.00),(165,56,25,NULL,'Minuman Teh Melati 500 ml',1.000,6000.00,3500.00,500.00,0.00,5500.00),(166,56,36,NULL,'Sabun Cuci Piring 755 ml',2.000,15500.00,11500.00,0.00,3034.90,34034.90),(167,56,11,NULL,'Pasta Gigi',1.000,13500.00,9000.00,0.00,1321.65,14821.65),(168,57,30,NULL,'Soda Rasa Jeruk 390 ml',1.000,7000.00,4500.00,0.00,0.00,7000.00),(169,57,5,NULL,'Teh Kotak 250ml',2.000,5000.00,3500.00,0.00,0.00,10000.00),(170,57,16,NULL,'Kecap Manis 600 ml',1.000,17000.00,13500.00,0.00,0.00,17000.00),(171,57,27,NULL,'Susu UHT Cokelat 200 ml',2.000,7000.00,4500.00,0.00,0.00,14000.00),(172,58,13,NULL,'Tepung Terigu Protein Sedang 1 kg',2.000,14000.00,11000.00,0.00,0.00,28000.00),(173,58,24,NULL,'Bubur Instan Ayam 45 g',1.000,10000.00,7000.00,0.00,0.00,10000.00),(174,58,35,NULL,'Sikat Gigi Dewasa',2.000,7500.00,4500.00,0.00,596.22,15596.22),(175,58,10,NULL,'Sabun Mandi',1.000,6500.00,4000.00,0.00,258.36,6758.36),(176,59,18,NULL,'Sarden Saus Tomat 155 g',2.000,12500.00,9500.00,500.00,0.00,24500.00),(177,59,29,NULL,'Kopi Susu Siap Minum 200 ml',1.000,10000.00,6500.00,0.00,0.00,10000.00),(178,60,23,NULL,'Roti Isi Cokelat',2.000,7000.00,4500.00,0.00,641.48,14641.48),(179,60,34,NULL,'Tisu Wajah 250 Lembar',1.000,11000.00,7500.00,0.00,504.02,11504.02),(180,60,9,NULL,'Gula Pasir 1kg',2.000,17000.00,14000.00,0.00,0.00,34000.00),(181,61,6,NULL,'Kopi Sachet',1.000,2500.00,1500.00,0.00,0.00,2500.00),(182,61,17,NULL,'Saus Sambal 340 ml',2.000,12000.00,9000.00,0.00,0.00,24000.00),(183,61,28,NULL,'Jus Jambu 250 ml',1.000,5500.00,3500.00,0.00,0.00,5500.00),(184,62,11,NULL,'Pasta Gigi',1.000,13500.00,9000.00,500.00,767.32,13767.32),(185,62,22,NULL,'Kacang Panggang 100 g',2.000,9000.00,6000.00,0.00,1062.44,19062.44),(186,62,33,NULL,'Pewangi Pakaian 800 ml',1.000,13000.00,9000.00,0.00,767.32,13767.32),(187,62,8,NULL,'Minyak Goreng 1L',2.000,19000.00,15000.00,0.00,0.00,38000.00),(188,63,16,NULL,'Kecap Manis 600 ml',1.000,17000.00,13500.00,0.00,0.00,17000.00),(189,63,27,NULL,'Susu UHT Cokelat 200 ml',2.000,7000.00,4500.00,0.00,0.00,14000.00);
/*!40000 ALTER TABLE `sale_items` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sale_payments`
--

DROP TABLE IF EXISTS `sale_payments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sale_payments` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `sale_id` bigint unsigned NOT NULL,
  `payment_method_id` bigint unsigned NOT NULL,
  `amount` decimal(15,2) NOT NULL,
  `reference` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `sale_payments_payment_method_id_foreign` (`payment_method_id`),
  KEY `sale_payments_sale_id_index` (`sale_id`),
  CONSTRAINT `sale_payments_payment_method_id_foreign` FOREIGN KEY (`payment_method_id`) REFERENCES `payment_methods` (`id`) ON DELETE CASCADE,
  CONSTRAINT `sale_payments_sale_id_foreign` FOREIGN KEY (`sale_id`) REFERENCES `sales` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=64 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sale_payments`
--

LOCK TABLES `sale_payments` WRITE;
/*!40000 ALTER TABLE `sale_payments` DISABLE KEYS */;
INSERT INTO `sale_payments` VALUES (1,1,1,41300.00,NULL,'2026-11-03 03:19:44','2026-11-03 03:19:44'),(2,2,2,109500.00,'QRIS-261014152400','2026-11-03 03:19:44','2026-11-03 03:19:44'),(3,3,3,63700.00,'TRANSFER-261014183100','2026-11-03 03:19:44','2026-11-03 03:19:44'),(4,4,1,35300.00,NULL,'2026-11-03 03:19:45','2026-11-03 03:19:45'),(5,5,2,48800.00,'QRIS-261015152400','2026-11-03 03:19:45','2026-11-03 03:19:45'),(6,6,3,40000.00,'TRANSFER-261015183100','2026-11-03 03:19:45','2026-11-03 03:19:45'),(7,7,1,33900.00,NULL,'2026-11-03 03:19:45','2026-11-03 03:19:45'),(8,8,2,38500.00,'QRIS-261016152400','2026-11-03 03:19:45','2026-11-03 03:19:45'),(9,9,3,45200.00,'TRANSFER-261016183100','2026-11-03 03:19:45','2026-11-03 03:19:45'),(10,10,1,29500.00,NULL,'2026-11-03 03:19:45','2026-11-03 03:19:45'),(11,11,2,71900.00,'QRIS-261017152400','2026-11-03 03:19:45','2026-11-03 03:19:45'),(12,12,3,64300.00,'TRANSFER-261017183100','2026-11-03 03:19:45','2026-11-03 03:19:45'),(13,13,1,201100.00,NULL,'2026-11-03 03:19:45','2026-11-03 03:19:45'),(14,14,2,20500.00,'QRIS-261018152400','2026-11-03 03:19:45','2026-11-03 03:19:45'),(15,15,3,10900.00,'TRANSFER-261018183100','2026-11-03 03:19:45','2026-11-03 03:19:45'),(16,16,1,50000.00,NULL,'2026-11-03 03:19:45','2026-11-03 03:19:45'),(17,17,2,65400.00,'QRIS-261019152400','2026-11-03 03:19:45','2026-11-03 03:19:45'),(18,18,3,37000.00,'TRANSFER-261019183100','2026-11-03 03:19:45','2026-11-03 03:19:45'),(19,19,1,167200.00,NULL,'2026-11-03 03:19:45','2026-11-03 03:19:45'),(20,20,2,32100.00,'QRIS-261020152400','2026-11-03 03:19:45','2026-11-03 03:19:45'),(21,21,3,38000.00,'TRANSFER-261020183100','2026-11-03 03:19:45','2026-11-03 03:19:45'),(22,22,1,69200.00,NULL,'2026-11-03 03:19:45','2026-11-03 03:19:45'),(23,23,2,18500.00,'QRIS-261021152400','2026-11-03 03:19:45','2026-11-03 03:19:45'),(24,24,3,49400.00,'TRANSFER-261021183100','2026-11-03 03:19:45','2026-11-03 03:19:45'),(25,25,1,36500.00,NULL,'2026-11-03 03:19:45','2026-11-03 03:19:45'),(26,26,2,60800.00,'QRIS-261022152400','2026-11-03 03:19:45','2026-11-03 03:19:45'),(27,27,3,11500.00,'TRANSFER-261022183100','2026-11-03 03:19:45','2026-11-03 03:19:45'),(28,28,1,40000.00,NULL,'2026-11-03 03:19:45','2026-11-03 03:19:45'),(29,29,2,67100.00,'QRIS-261023152400','2026-11-03 03:19:45','2026-11-03 03:19:45'),(30,30,3,205300.00,'TRANSFER-261023183100','2026-11-03 03:19:46','2026-11-03 03:19:46'),(31,31,1,58200.00,NULL,'2026-11-03 03:19:46','2026-11-03 03:19:46'),(32,32,2,28700.00,'QRIS-261024152400','2026-11-03 03:19:46','2026-11-03 03:19:46'),(33,33,3,59200.00,'TRANSFER-261024183100','2026-11-03 03:19:46','2026-11-03 03:19:46'),(34,34,1,65600.00,NULL,'2026-11-03 03:19:46','2026-11-03 03:19:46'),(35,35,2,68400.00,'QRIS-261025152400','2026-11-03 03:19:46','2026-11-03 03:19:46'),(36,36,3,161500.00,'TRANSFER-261025183100','2026-11-03 03:19:46','2026-11-03 03:19:46'),(37,37,1,46200.00,NULL,'2026-11-03 03:19:46','2026-11-03 03:19:46'),(38,38,2,18100.00,'QRIS-261026152400','2026-11-03 03:19:46','2026-11-03 03:19:46'),(39,39,3,84900.00,'TRANSFER-261026183100','2026-11-03 03:19:46','2026-11-03 03:19:46'),(40,40,1,51800.00,NULL,'2026-11-03 03:19:46','2026-11-03 03:19:46'),(41,41,2,27800.00,'QRIS-261027152400','2026-11-03 03:19:46','2026-11-03 03:19:46'),(42,42,3,31000.00,'TRANSFER-261027183100','2026-11-03 03:19:46','2026-11-03 03:19:46'),(43,43,1,30800.00,NULL,'2026-11-03 03:19:46','2026-11-03 03:19:46'),(44,44,2,88000.00,'QRIS-261028152400','2026-11-03 03:19:46','2026-11-03 03:19:46'),(45,45,3,37700.00,'TRANSFER-261028183100','2026-11-03 03:19:46','2026-11-03 03:19:46'),(46,46,1,27000.00,NULL,'2026-11-03 03:19:46','2026-11-03 03:19:46'),(47,47,2,61600.00,'QRIS-261029152400','2026-11-03 03:19:46','2026-11-03 03:19:46'),(48,48,3,56200.00,'TRANSFER-261029183100','2026-11-03 03:19:46','2026-11-03 03:19:46'),(49,49,1,55600.00,NULL,'2026-11-03 03:19:46','2026-11-03 03:19:46'),(50,50,2,65000.00,'QRIS-261030152400','2026-11-03 03:19:46','2026-11-03 03:19:46'),(51,51,3,42700.00,'TRANSFER-261030183100','2026-11-03 03:19:46','2026-11-03 03:19:46'),(52,52,1,55300.00,NULL,'2026-11-03 03:19:46','2026-11-03 03:19:46'),(53,53,2,143900.00,'QRIS-261031152400','2026-11-03 03:19:46','2026-11-03 03:19:46'),(54,54,3,39600.00,'TRANSFER-261031183100','2026-11-03 03:19:47','2026-11-03 03:19:47'),(55,55,1,9400.00,NULL,'2026-11-03 03:19:47','2026-11-03 03:19:47'),(56,56,2,54900.00,'QRIS-261101152400','2026-11-03 03:19:47','2026-11-03 03:19:47'),(57,57,3,47000.00,'TRANSFER-261101183100','2026-11-03 03:19:47','2026-11-03 03:19:47'),(58,58,1,61900.00,NULL,'2026-11-03 03:19:47','2026-11-03 03:19:47'),(59,59,2,34500.00,'QRIS-261102152400','2026-11-03 03:19:47','2026-11-03 03:19:47'),(60,60,3,60700.00,'TRANSFER-261102183100','2026-11-03 03:19:47','2026-11-03 03:19:47'),(61,61,1,32000.00,NULL,'2026-11-03 03:19:47','2026-11-03 03:19:47'),(62,62,2,86800.00,'QRIS-261103152400','2026-11-03 03:19:47','2026-11-03 03:19:47'),(63,63,3,30000.00,'TRANSFER-261103183100','2026-11-03 03:19:47','2026-11-03 03:19:47');
/*!40000 ALTER TABLE `sale_payments` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sales`
--

DROP TABLE IF EXISTS `sales`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sales` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `invoice_number` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `idempotency_key` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `shift_id` bigint unsigned NOT NULL,
  `cashier_id` bigint unsigned DEFAULT NULL,
  `customer_id` bigint unsigned DEFAULT NULL,
  `subtotal` decimal(15,2) NOT NULL DEFAULT '0.00',
  `discount_total` decimal(15,2) NOT NULL DEFAULT '0.00',
  `tax_total` decimal(15,2) NOT NULL DEFAULT '0.00',
  `rounding` decimal(15,2) NOT NULL DEFAULT '0.00',
  `grand_total` decimal(15,2) NOT NULL DEFAULT '0.00',
  `paid_total` decimal(15,2) NOT NULL DEFAULT '0.00',
  `change_amount` decimal(15,2) NOT NULL DEFAULT '0.00',
  `status` enum('paid','voided','refunded','partial_refund') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'paid',
  `voided_by` bigint unsigned DEFAULT NULL,
  `void_reason` text COLLATE utf8mb4_unicode_ci,
  `voided_at` timestamp NULL DEFAULT NULL,
  `deleted_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `sales_invoice_number_unique` (`invoice_number`),
  UNIQUE KEY `sales_idempotency_key_unique` (`idempotency_key`),
  KEY `sales_customer_id_foreign` (`customer_id`),
  KEY `sales_voided_by_foreign` (`voided_by`),
  KEY `sales_shift_id_status_index` (`shift_id`,`status`),
  KEY `sales_cashier_id_created_at_index` (`cashier_id`,`created_at`),
  CONSTRAINT `sales_cashier_id_foreign` FOREIGN KEY (`cashier_id`) REFERENCES `users` (`id`) ON DELETE SET NULL,
  CONSTRAINT `sales_customer_id_foreign` FOREIGN KEY (`customer_id`) REFERENCES `customers` (`id`) ON DELETE SET NULL,
  CONSTRAINT `sales_shift_id_foreign` FOREIGN KEY (`shift_id`) REFERENCES `shifts` (`id`) ON DELETE CASCADE,
  CONSTRAINT `sales_voided_by_foreign` FOREIGN KEY (`voided_by`) REFERENCES `users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=64 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sales`
--

LOCK TABLES `sales` WRITE;
/*!40000 ALTER TABLE `sales` DISABLE KEYS */;
INSERT INTO `sales` VALUES (1,'INV-20261014-0001','seed-INV-20261014-0001',1,2,2,40000.00,0.00,1320.00,-20.00,41300.00,41300.00,0.00,'paid',NULL,NULL,NULL,NULL,'2026-10-14 05:17:00','2026-10-14 05:17:00'),(2,'INV-20261014-0002','seed-INV-20261014-0002',1,2,3,110000.00,500.00,0.00,0.00,109500.00,109500.00,0.00,'paid',NULL,NULL,NULL,NULL,'2026-10-14 08:24:00','2026-10-14 08:24:00'),(3,'INV-20261014-0003','seed-INV-20261014-0003',1,2,4,62000.00,1000.00,2705.64,-5.64,63700.00,63700.00,0.00,'paid',NULL,NULL,NULL,NULL,'2026-10-14 11:31:00','2026-10-14 11:31:00'),(4,'INV-20261015-0001','seed-INV-20261015-0001',2,2,1,35000.00,0.00,330.00,-30.00,35300.00,35300.00,0.00,'paid',NULL,NULL,NULL,NULL,'2026-10-15 05:17:00','2026-10-15 05:17:00'),(5,'INV-20261015-0002','seed-INV-20261015-0002',2,2,2,44500.00,500.00,4840.00,-40.00,48800.00,48800.00,0.00,'paid',NULL,NULL,NULL,NULL,'2026-10-15 08:24:00','2026-10-15 08:24:00'),(6,'INV-20261015-0003','seed-INV-20261015-0003',2,2,3,41000.00,1000.00,0.00,0.00,40000.00,40000.00,0.00,'paid',NULL,NULL,NULL,NULL,'2026-10-15 11:31:00','2026-10-15 11:31:00'),(7,'INV-20261016-0001','seed-INV-20261016-0001',3,2,10,31500.00,0.00,2365.00,35.00,33900.00,33900.00,0.00,'paid',NULL,NULL,NULL,NULL,'2026-10-16 05:17:00','2026-10-16 05:17:00'),(8,'INV-20261016-0002','seed-INV-20261016-0002',3,2,1,39000.00,500.00,0.00,0.00,38500.00,38500.00,0.00,'paid',NULL,NULL,NULL,NULL,'2026-10-16 08:24:00','2026-10-16 08:24:00'),(9,'INV-20261016-0003','seed-INV-20261016-0003',3,2,2,45000.00,1000.00,1183.11,16.89,45200.00,45200.00,0.00,'paid',NULL,NULL,NULL,NULL,'2026-10-16 11:31:00','2026-10-16 11:31:00'),(10,'INV-20261017-0001','seed-INV-20261017-0001',4,2,9,29500.00,0.00,0.00,0.00,29500.00,29500.00,0.00,'paid',NULL,NULL,NULL,NULL,'2026-10-17 05:17:00','2026-10-17 05:17:00'),(11,'INV-20261017-0002','seed-INV-20261017-0002',4,2,10,69000.00,500.00,3355.00,45.00,71900.00,71900.00,0.00,'paid',NULL,NULL,NULL,NULL,'2026-10-17 08:24:00','2026-10-17 08:24:00'),(12,'INV-20261017-0003','seed-INV-20261017-0003',4,2,1,64000.00,1000.00,1299.38,0.62,64300.00,64300.00,0.00,'paid',NULL,NULL,NULL,NULL,'2026-10-17 11:31:00','2026-10-17 11:31:00'),(13,'INV-20261018-0001','seed-INV-20261018-0001',5,2,8,196000.00,0.00,5060.00,40.00,201100.00,201100.00,0.00,'paid',NULL,NULL,NULL,NULL,'2026-10-18 05:17:00','2026-10-18 05:17:00'),(14,'INV-20261018-0002','seed-INV-20261018-0002',5,2,9,21000.00,500.00,0.00,0.00,20500.00,20500.00,0.00,'paid',NULL,NULL,NULL,NULL,'2026-10-18 08:24:00','2026-10-18 08:24:00'),(15,'INV-20261018-0003','seed-INV-20261018-0003',5,2,10,11000.00,1000.00,850.00,50.00,10900.00,10900.00,0.00,'paid',NULL,NULL,NULL,NULL,'2026-10-18 11:31:00','2026-10-18 11:31:00'),(16,'INV-20261019-0001','seed-INV-20261019-0001',6,2,7,50000.00,0.00,0.00,0.00,50000.00,50000.00,0.00,'paid',NULL,NULL,NULL,NULL,'2026-10-19 05:17:00','2026-10-19 05:17:00'),(17,'INV-20261019-0002','seed-INV-20261019-0002',6,2,8,65000.00,500.00,880.00,20.00,65400.00,65400.00,0.00,'paid',NULL,NULL,NULL,NULL,'2026-10-19 08:24:00','2026-10-19 08:24:00'),(18,'INV-20261019-0003','seed-INV-20261019-0003',6,2,9,38000.00,1000.00,0.00,0.00,37000.00,37000.00,0.00,'paid',NULL,NULL,NULL,NULL,'2026-10-19 11:31:00','2026-10-19 11:31:00'),(19,'INV-20261020-0001','seed-INV-20261020-0001',7,2,6,165500.00,0.00,1705.00,-5.00,167200.00,167200.00,0.00,'paid',NULL,NULL,NULL,NULL,'2026-10-20 05:17:00','2026-10-20 05:17:00'),(20,'INV-20261020-0002','seed-INV-20261020-0002',7,2,7,30000.00,500.00,2585.00,15.00,32100.00,32100.00,0.00,'paid',NULL,NULL,NULL,NULL,'2026-10-20 08:24:00','2026-10-20 08:24:00'),(21,'INV-20261020-0003','seed-INV-20261020-0003',7,2,8,39000.00,1000.00,0.00,0.00,38000.00,38000.00,0.00,'paid',NULL,NULL,NULL,NULL,'2026-10-20 11:31:00','2026-10-20 11:31:00'),(22,'INV-20261021-0001','seed-INV-20261021-0001',8,2,5,63500.00,0.00,5665.00,35.00,69200.00,69200.00,0.00,'paid',NULL,NULL,NULL,NULL,'2026-10-21 05:17:00','2026-10-21 05:17:00'),(23,'INV-20261021-0002','seed-INV-20261021-0002',8,2,6,19000.00,500.00,0.00,0.00,18500.00,18500.00,0.00,'paid',NULL,NULL,NULL,NULL,'2026-10-21 08:24:00','2026-10-21 08:24:00'),(24,'INV-20261021-0003','seed-INV-20261021-0003',8,2,7,45500.00,1000.00,4895.00,5.00,49400.00,49400.00,0.00,'paid',NULL,NULL,NULL,NULL,'2026-10-21 11:31:00','2026-10-21 11:31:00'),(25,'INV-20261022-0001','seed-INV-20261022-0001',9,2,4,36500.00,0.00,0.00,0.00,36500.00,36500.00,0.00,'paid',NULL,NULL,NULL,NULL,'2026-10-22 05:17:00','2026-10-22 05:17:00'),(26,'INV-20261022-0002','seed-INV-20261022-0002',9,2,5,57000.00,500.00,4345.00,-45.00,60800.00,60800.00,0.00,'paid',NULL,NULL,NULL,NULL,'2026-10-22 08:24:00','2026-10-22 08:24:00'),(27,'INV-20261022-0003','seed-INV-20261022-0003',9,2,6,12500.00,1000.00,0.00,0.00,11500.00,11500.00,0.00,'paid',NULL,NULL,NULL,NULL,'2026-10-22 11:31:00','2026-10-22 11:31:00'),(28,'INV-20261023-0001','seed-INV-20261023-0001',10,2,3,36000.00,0.00,3960.00,40.00,40000.00,40000.00,0.00,'paid',NULL,NULL,NULL,NULL,'2026-10-23 05:17:00','2026-10-23 05:17:00'),(29,'INV-20261023-0002','seed-INV-20261023-0002',10,2,4,65000.00,500.00,2640.00,-40.00,67100.00,67100.00,0.00,'paid',NULL,NULL,NULL,NULL,'2026-10-23 08:24:00','2026-10-23 08:24:00'),(30,'INV-20261023-0003','seed-INV-20261023-0003',10,2,5,202000.00,1000.00,4323.49,-23.49,205300.00,205300.00,0.00,'paid',NULL,NULL,NULL,NULL,'2026-10-23 11:31:00','2026-10-23 11:31:00'),(31,'INV-20261024-0001','seed-INV-20261024-0001',11,2,2,54500.00,0.00,3740.00,-40.00,58200.00,58200.00,0.00,'paid',NULL,NULL,NULL,NULL,'2026-10-24 05:17:00','2026-10-24 05:17:00'),(32,'INV-20261024-0002','seed-INV-20261024-0002',11,2,3,28000.00,500.00,1210.00,-10.00,28700.00,28700.00,0.00,'paid',NULL,NULL,NULL,NULL,'2026-10-24 08:24:00','2026-10-24 08:24:00'),(33,'INV-20261024-0003','seed-INV-20261024-0003',11,2,4,58500.00,1000.00,1675.85,24.15,59200.00,59200.00,0.00,'paid',NULL,NULL,NULL,NULL,'2026-10-24 11:31:00','2026-10-24 11:31:00'),(34,'INV-20261025-0001','seed-INV-20261025-0001',12,2,1,61000.00,0.00,4620.00,-20.00,65600.00,65600.00,0.00,'paid',NULL,NULL,NULL,NULL,'2026-10-25 05:17:00','2026-10-25 05:17:00'),(35,'INV-20261025-0002','seed-INV-20261025-0002',12,2,2,65500.00,500.00,3410.00,-10.00,68400.00,68400.00,0.00,'paid',NULL,NULL,NULL,NULL,'2026-10-25 08:24:00','2026-10-25 08:24:00'),(36,'INV-20261025-0003','seed-INV-20261025-0003',12,2,3,162500.00,1000.00,0.00,0.00,161500.00,161500.00,0.00,'paid',NULL,NULL,NULL,NULL,'2026-10-25 11:31:00','2026-10-25 11:31:00'),(37,'INV-20261026-0001','seed-INV-20261026-0001',13,2,10,42500.00,0.00,3740.00,-40.00,46200.00,46200.00,0.00,'paid',NULL,NULL,NULL,NULL,'2026-10-26 05:17:00','2026-10-26 05:17:00'),(38,'INV-20261026-0002','seed-INV-20261026-0002',13,2,1,18500.00,500.00,110.00,-10.00,18100.00,18100.00,0.00,'paid',NULL,NULL,NULL,NULL,'2026-10-26 08:24:00','2026-10-26 08:24:00'),(39,'INV-20261026-0003','seed-INV-20261026-0003',13,2,2,77500.00,1000.00,8415.00,-15.00,84900.00,84900.00,0.00,'paid',NULL,NULL,NULL,NULL,'2026-10-26 11:31:00','2026-10-26 11:31:00'),(40,'INV-20261027-0001','seed-INV-20261027-0001',14,2,9,50000.00,0.00,1760.00,40.00,51800.00,51800.00,0.00,'paid',NULL,NULL,NULL,NULL,'2026-10-27 05:17:00','2026-10-27 05:17:00'),(41,'INV-20261027-0002','seed-INV-20261027-0002',14,2,10,27500.00,500.00,825.00,-25.00,27800.00,27800.00,0.00,'paid',NULL,NULL,NULL,NULL,'2026-10-27 08:24:00','2026-10-27 08:24:00'),(42,'INV-20261027-0003','seed-INV-20261027-0003',14,2,1,32000.00,1000.00,0.00,0.00,31000.00,31000.00,0.00,'paid',NULL,NULL,NULL,NULL,'2026-10-27 11:31:00','2026-10-27 11:31:00'),(43,'INV-20261028-0001','seed-INV-20261028-0001',15,2,8,28000.00,0.00,2750.00,50.00,30800.00,30800.00,0.00,'paid',NULL,NULL,NULL,NULL,'2026-10-28 05:17:00','2026-10-28 05:17:00'),(44,'INV-20261028-0002','seed-INV-20261028-0002',15,2,9,88500.00,500.00,0.00,0.00,88000.00,88000.00,0.00,'paid',NULL,NULL,NULL,NULL,'2026-10-28 08:24:00','2026-10-28 08:24:00'),(45,'INV-20261028-0003','seed-INV-20261028-0003',15,2,10,35000.00,1000.00,3740.00,-40.00,37700.00,37700.00,0.00,'paid',NULL,NULL,NULL,NULL,'2026-10-28 11:31:00','2026-10-28 11:31:00'),(46,'INV-20261029-0001','seed-INV-20261029-0001',16,2,7,27000.00,0.00,0.00,0.00,27000.00,27000.00,0.00,'paid',NULL,NULL,NULL,NULL,'2026-10-29 05:17:00','2026-10-29 05:17:00'),(47,'INV-20261029-0002','seed-INV-20261029-0002',16,2,8,56000.00,500.00,6105.00,-5.00,61600.00,61600.00,0.00,'paid',NULL,NULL,NULL,NULL,'2026-10-29 08:24:00','2026-10-29 08:24:00'),(48,'INV-20261029-0003','seed-INV-20261029-0003',16,2,9,53500.00,1000.00,3670.09,29.91,56200.00,56200.00,0.00,'paid',NULL,NULL,NULL,NULL,'2026-10-29 11:31:00','2026-10-29 11:31:00'),(49,'INV-20261030-0001','seed-INV-20261030-0001',17,2,6,53500.00,0.00,2145.00,-45.00,55600.00,55600.00,0.00,'paid',NULL,NULL,NULL,NULL,'2026-10-30 05:17:00','2026-10-30 05:17:00'),(50,'INV-20261030-0002','seed-INV-20261030-0002',17,2,7,65500.00,500.00,0.00,0.00,65000.00,65000.00,0.00,'paid',NULL,NULL,NULL,NULL,'2026-10-30 08:24:00','2026-10-30 08:24:00'),(51,'INV-20261030-0003','seed-INV-20261030-0003',17,2,8,42000.00,1000.00,1718.10,-18.10,42700.00,42700.00,0.00,'paid',NULL,NULL,NULL,NULL,'2026-10-30 11:31:00','2026-10-30 11:31:00'),(52,'INV-20261031-0001','seed-INV-20261031-0001',18,2,5,54000.00,0.00,1320.00,-20.00,55300.00,55300.00,0.00,'paid',NULL,NULL,NULL,NULL,'2026-10-31 05:17:00','2026-10-31 05:17:00'),(53,'INV-20261031-0002','seed-INV-20261031-0002',18,2,6,141000.00,500.00,3355.00,45.00,143900.00,143900.00,0.00,'paid',NULL,NULL,NULL,NULL,'2026-10-31 08:24:00','2026-10-31 08:24:00'),(54,'INV-20261031-0003','seed-INV-20261031-0003',18,2,7,37000.00,1000.00,3638.92,-38.92,39600.00,39600.00,0.00,'paid',NULL,NULL,NULL,NULL,'2026-10-31 11:31:00','2026-10-31 11:31:00'),(55,'INV-20261101-0001','seed-INV-20261101-0001',19,2,4,8500.00,0.00,935.00,-35.00,9400.00,9400.00,0.00,'paid',NULL,NULL,NULL,NULL,'2026-11-01 05:17:00','2026-11-01 05:17:00'),(56,'INV-20261101-0002','seed-INV-20261101-0002',19,2,5,50500.00,500.00,4895.00,5.00,54900.00,54900.00,0.00,'paid',NULL,NULL,NULL,NULL,'2026-11-01 08:24:00','2026-11-01 08:24:00'),(57,'INV-20261101-0003','seed-INV-20261101-0003',19,2,6,48000.00,1000.00,0.00,0.00,47000.00,47000.00,0.00,'paid',NULL,NULL,NULL,NULL,'2026-11-01 11:31:00','2026-11-01 11:31:00'),(58,'INV-20261102-0001','seed-INV-20261102-0001',20,2,3,59500.00,0.00,2365.00,35.00,61900.00,61900.00,0.00,'paid',NULL,NULL,NULL,NULL,'2026-11-02 05:17:00','2026-11-02 05:17:00'),(59,'INV-20261102-0002','seed-INV-20261102-0002',20,2,4,35000.00,500.00,0.00,0.00,34500.00,34500.00,0.00,'paid',NULL,NULL,NULL,NULL,'2026-11-02 08:24:00','2026-11-02 08:24:00'),(60,'INV-20261102-0003','seed-INV-20261102-0003',20,2,5,59000.00,1000.00,2703.39,-3.39,60700.00,60700.00,0.00,'paid',NULL,NULL,NULL,NULL,'2026-11-02 11:31:00','2026-11-02 11:31:00'),(61,'INV-20261103-0001','seed-INV-20261103-0001',21,2,2,32000.00,0.00,0.00,0.00,32000.00,32000.00,0.00,'partial_refund',NULL,NULL,NULL,NULL,'2026-11-03 05:17:00','2026-11-03 03:19:47'),(62,'INV-20261103-0002','seed-INV-20261103-0002',21,2,3,82500.00,500.00,4840.00,-40.00,86800.00,86800.00,0.00,'paid',NULL,NULL,NULL,NULL,'2026-11-03 08:24:00','2026-11-03 08:24:00'),(63,'INV-20261103-0003','seed-INV-20261103-0003',21,2,4,31000.00,1000.00,0.00,0.00,30000.00,30000.00,0.00,'paid',NULL,NULL,NULL,NULL,'2026-11-03 11:31:00','2026-11-03 11:31:00');
/*!40000 ALTER TABLE `sales` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sessions`
--

DROP TABLE IF EXISTS `sessions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sessions` (
  `id` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `user_id` bigint unsigned DEFAULT NULL,
  `ip_address` varchar(45) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `user_agent` text COLLATE utf8mb4_unicode_ci,
  `payload` longtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `last_activity` int NOT NULL,
  PRIMARY KEY (`id`),
  KEY `sessions_user_id_index` (`user_id`),
  KEY `sessions_last_activity_index` (`last_activity`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sessions`
--

LOCK TABLES `sessions` WRITE;
/*!40000 ALTER TABLE `sessions` DISABLE KEYS */;
/*!40000 ALTER TABLE `sessions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `settings`
--

DROP TABLE IF EXISTS `settings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `settings` (
  `key` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `value` text COLLATE utf8mb4_unicode_ci,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `settings`
--

LOCK TABLES `settings` WRITE;
/*!40000 ALTER TABLE `settings` DISABLE KEYS */;
INSERT INTO `settings` VALUES ('allow_negative_stock','0','2026-11-03 03:19:43','2026-11-03 03:19:43'),('max_discount_without_pin','10000','2026-11-03 03:19:43','2026-11-03 03:19:43'),('receipt_footer','Terima kasih telah berbelanja. Barang yang sudah dibeli tidak dapat ditukar tanpa struk.','2026-11-03 03:19:43','2026-11-03 03:19:43'),('rounding_step','100','2026-11-03 03:19:43','2026-11-03 03:19:43'),('store_address','Jl. Merdeka No. 17, Jakarta','2026-11-03 03:19:43','2026-11-03 03:19:43'),('store_name','KasirKu','2026-11-03 03:19:43','2026-11-03 03:19:43'),('store_phone','021-555-0100','2026-11-03 03:19:43','2026-11-03 03:19:43'),('tax_included','0','2026-11-03 03:19:43','2026-11-03 03:19:43'),('tax_rate','11','2026-11-03 03:19:43','2026-11-03 03:19:43');
/*!40000 ALTER TABLE `settings` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `shifts`
--

DROP TABLE IF EXISTS `shifts`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `shifts` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `user_id` bigint unsigned NOT NULL,
  `opened_at` timestamp NOT NULL,
  `closed_at` timestamp NULL DEFAULT NULL,
  `opening_cash` decimal(15,2) NOT NULL DEFAULT '0.00',
  `expected_cash` decimal(15,2) NOT NULL DEFAULT '0.00',
  `actual_cash` decimal(15,2) DEFAULT NULL,
  `difference` decimal(15,2) NOT NULL DEFAULT '0.00',
  `status` enum('open','closed') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'open',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `shifts_user_id_status_index` (`user_id`,`status`),
  CONSTRAINT `shifts_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=22 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `shifts`
--

LOCK TABLES `shifts` WRITE;
/*!40000 ALTER TABLE `shifts` DISABLE KEYS */;
INSERT INTO `shifts` VALUES (1,2,'2026-10-14 00:45:00','2026-10-14 14:10:00',300000.00,341300.00,341300.00,0.00,'closed','2026-10-14 00:45:00','2026-11-03 03:19:47'),(2,2,'2026-10-15 00:45:00','2026-10-15 14:10:00',300000.00,335300.00,335300.00,0.00,'closed','2026-10-15 00:45:00','2026-11-03 03:19:47'),(3,2,'2026-10-16 00:45:00','2026-10-16 14:10:00',300000.00,333900.00,333400.00,-500.00,'closed','2026-10-16 00:45:00','2026-11-03 03:19:47'),(4,2,'2026-10-17 00:45:00','2026-10-17 14:10:00',300000.00,329500.00,329500.00,0.00,'closed','2026-10-17 00:45:00','2026-11-03 03:19:47'),(5,2,'2026-10-18 00:45:00','2026-10-18 14:10:00',300000.00,501100.00,501100.00,0.00,'closed','2026-10-18 00:45:00','2026-11-03 03:19:47'),(6,2,'2026-10-19 00:45:00','2026-10-19 14:10:00',300000.00,315000.00,314500.00,-500.00,'closed','2026-10-19 00:45:00','2026-11-03 03:19:47'),(7,2,'2026-10-20 00:45:00','2026-10-20 14:10:00',300000.00,467200.00,467200.00,0.00,'closed','2026-10-20 00:45:00','2026-11-03 03:19:47'),(8,2,'2026-10-21 00:45:00','2026-10-21 14:10:00',300000.00,369200.00,369200.00,0.00,'closed','2026-10-21 00:45:00','2026-11-03 03:19:47'),(9,2,'2026-10-22 00:45:00','2026-10-22 14:10:00',300000.00,336500.00,336000.00,-500.00,'closed','2026-10-22 00:45:00','2026-11-03 03:19:47'),(10,2,'2026-10-23 00:45:00','2026-10-23 14:10:00',300000.00,340000.00,340000.00,0.00,'closed','2026-10-23 00:45:00','2026-11-03 03:19:47'),(11,2,'2026-10-24 00:45:00','2026-10-24 14:10:00',300000.00,358200.00,358200.00,0.00,'closed','2026-10-24 00:45:00','2026-11-03 03:19:47'),(12,2,'2026-10-25 00:45:00','2026-10-25 14:10:00',300000.00,415600.00,415100.00,-500.00,'closed','2026-10-25 00:45:00','2026-11-03 03:19:47'),(13,2,'2026-10-26 00:45:00','2026-10-26 14:10:00',300000.00,346200.00,346200.00,0.00,'closed','2026-10-26 00:45:00','2026-11-03 03:19:47'),(14,2,'2026-10-27 00:45:00','2026-10-27 14:10:00',300000.00,351800.00,351800.00,0.00,'closed','2026-10-27 00:45:00','2026-11-03 03:19:47'),(15,2,'2026-10-28 00:45:00','2026-10-28 14:10:00',300000.00,330800.00,330300.00,-500.00,'closed','2026-10-28 00:45:00','2026-11-03 03:19:47'),(16,2,'2026-10-29 00:45:00','2026-10-29 14:10:00',300000.00,327000.00,327000.00,0.00,'closed','2026-10-29 00:45:00','2026-11-03 03:19:47'),(17,2,'2026-10-30 00:45:00','2026-10-30 14:10:00',300000.00,280600.00,280600.00,0.00,'closed','2026-10-30 00:45:00','2026-11-03 03:19:47'),(18,2,'2026-10-31 00:45:00','2026-10-31 14:10:00',300000.00,355300.00,354800.00,-500.00,'closed','2026-10-31 00:45:00','2026-11-03 03:19:47'),(19,2,'2026-11-01 00:45:00','2026-11-01 14:10:00',300000.00,309400.00,309400.00,0.00,'closed','2026-11-01 00:45:00','2026-11-03 03:19:47'),(20,2,'2026-11-02 00:45:00','2026-11-02 14:10:00',300000.00,361900.00,361900.00,0.00,'closed','2026-11-02 00:45:00','2026-11-03 03:19:47'),(21,2,'2026-11-03 00:45:00',NULL,300000.00,329500.00,329000.00,-500.00,'open','2026-11-03 00:45:00','2026-11-03 03:19:47');
/*!40000 ALTER TABLE `shifts` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `stock_adjustment_items`
--

DROP TABLE IF EXISTS `stock_adjustment_items`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `stock_adjustment_items` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `stock_adjustment_id` bigint unsigned NOT NULL,
  `product_id` bigint unsigned NOT NULL,
  `qty_before` decimal(15,3) NOT NULL,
  `qty_after` decimal(15,3) NOT NULL,
  `difference` decimal(15,3) NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `stock_adjustment_items_product_id_foreign` (`product_id`),
  KEY `stock_adjustment_items_stock_adjustment_id_index` (`stock_adjustment_id`),
  CONSTRAINT `stock_adjustment_items_product_id_foreign` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON DELETE CASCADE,
  CONSTRAINT `stock_adjustment_items_stock_adjustment_id_foreign` FOREIGN KEY (`stock_adjustment_id`) REFERENCES `stock_adjustments` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `stock_adjustment_items`
--

LOCK TABLES `stock_adjustment_items` WRITE;
/*!40000 ALTER TABLE `stock_adjustment_items` DISABLE KEYS */;
INSERT INTO `stock_adjustment_items` VALUES (1,1,4,111.000,110.000,-1.000,NULL,NULL),(2,1,14,69.000,68.000,-1.000,NULL,NULL),(3,1,24,54.000,53.000,-1.000,NULL,NULL);
/*!40000 ALTER TABLE `stock_adjustment_items` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `stock_adjustments`
--

DROP TABLE IF EXISTS `stock_adjustments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `stock_adjustments` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `document_number` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `reason` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_by` bigint unsigned DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `stock_adjustments_document_number_unique` (`document_number`),
  KEY `stock_adjustments_created_by_foreign` (`created_by`),
  CONSTRAINT `stock_adjustments_created_by_foreign` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `stock_adjustments`
--

LOCK TABLES `stock_adjustments` WRITE;
/*!40000 ALTER TABLE `stock_adjustments` DISABLE KEYS */;
INSERT INTO `stock_adjustments` VALUES (1,'ADJ-20261101-0001','Penyesuaian stok hasil stok opname mingguan',3,'2026-11-01 13:15:00','2026-11-01 13:15:00');
/*!40000 ALTER TABLE `stock_adjustments` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `stock_in_items`
--

DROP TABLE IF EXISTS `stock_in_items`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `stock_in_items` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `stock_in_id` bigint unsigned NOT NULL,
  `product_id` bigint unsigned NOT NULL,
  `qty` decimal(15,3) NOT NULL,
  `cost_price` decimal(15,2) NOT NULL DEFAULT '0.00',
  `batch_number` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `expiry_date` date DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `stock_in_items_product_id_foreign` (`product_id`),
  KEY `stock_in_items_stock_in_id_index` (`stock_in_id`),
  CONSTRAINT `stock_in_items_product_id_foreign` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON DELETE CASCADE,
  CONSTRAINT `stock_in_items_stock_in_id_foreign` FOREIGN KEY (`stock_in_id`) REFERENCES `stock_ins` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=41 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `stock_in_items`
--

LOCK TABLES `stock_in_items` WRITE;
/*!40000 ALTER TABLE `stock_in_items` DISABLE KEYS */;
INSERT INTO `stock_in_items` VALUES (1,1,1,12.000,12000.00,NULL,NULL,'2026-11-03 03:19:44','2026-11-03 03:19:44'),(2,1,4,18.000,2500.00,NULL,NULL,'2026-11-03 03:19:44','2026-11-03 03:19:44'),(3,1,7,24.000,65000.00,NULL,NULL,'2026-11-03 03:19:44','2026-11-03 03:19:44'),(4,1,10,30.000,4000.00,NULL,NULL,'2026-11-03 03:19:44','2026-11-03 03:19:44'),(5,1,13,12.000,11000.00,NULL,NULL,'2026-11-03 03:19:44','2026-11-03 03:19:44'),(6,2,6,18.000,1500.00,NULL,NULL,'2026-11-03 03:19:44','2026-11-03 03:19:44'),(7,2,9,24.000,14000.00,NULL,NULL,'2026-11-03 03:19:44','2026-11-03 03:19:44'),(8,2,12,30.000,500.00,NULL,NULL,'2026-11-03 03:19:44','2026-11-03 03:19:44'),(9,2,15,12.000,2500.00,NULL,NULL,'2026-11-03 03:19:44','2026-11-03 03:19:44'),(10,2,18,18.000,9500.00,NULL,NULL,'2026-11-03 03:19:44','2026-11-03 03:19:44'),(11,3,11,24.000,9000.00,NULL,NULL,'2026-11-03 03:19:44','2026-11-03 03:19:44'),(12,3,14,30.000,27000.00,NULL,NULL,'2026-11-03 03:19:44','2026-11-03 03:19:44'),(13,3,17,12.000,9000.00,NULL,NULL,'2026-11-03 03:19:44','2026-11-03 03:19:44'),(14,3,20,18.000,3500.00,NULL,NULL,'2026-11-03 03:19:44','2026-11-03 03:19:44'),(15,3,23,24.000,4500.00,NULL,NULL,'2026-11-03 03:19:44','2026-11-03 03:19:44'),(16,4,16,30.000,13500.00,NULL,NULL,'2026-11-03 03:19:44','2026-11-03 03:19:44'),(17,4,19,12.000,5500.00,NULL,NULL,'2026-11-03 03:19:44','2026-11-03 03:19:44'),(18,4,22,18.000,6000.00,NULL,NULL,'2026-11-03 03:19:44','2026-11-03 03:19:44'),(19,4,25,24.000,3500.00,NULL,NULL,'2026-11-03 03:19:44','2026-11-03 03:19:44'),(20,4,28,30.000,3500.00,NULL,NULL,'2026-11-03 03:19:44','2026-11-03 03:19:44'),(21,5,21,12.000,8500.00,NULL,NULL,'2026-11-03 03:19:44','2026-11-03 03:19:44'),(22,5,24,18.000,7000.00,NULL,NULL,'2026-11-03 03:19:44','2026-11-03 03:19:44'),(23,5,27,24.000,4500.00,NULL,NULL,'2026-11-03 03:19:44','2026-11-03 03:19:44'),(24,5,30,30.000,4500.00,NULL,NULL,'2026-11-03 03:19:44','2026-11-03 03:19:44'),(25,5,33,12.000,9000.00,NULL,NULL,'2026-11-03 03:19:44','2026-11-03 03:19:44'),(26,6,26,18.000,5500.00,NULL,NULL,'2026-11-03 03:19:44','2026-11-03 03:19:44'),(27,6,29,24.000,6500.00,NULL,NULL,'2026-11-03 03:19:44','2026-11-03 03:19:44'),(28,6,32,30.000,11500.00,NULL,NULL,'2026-11-03 03:19:44','2026-11-03 03:19:44'),(29,6,35,12.000,4500.00,NULL,NULL,'2026-11-03 03:19:44','2026-11-03 03:19:44'),(30,6,2,18.000,8000.00,NULL,NULL,'2026-11-03 03:19:44','2026-11-03 03:19:44'),(31,7,31,24.000,800.00,NULL,NULL,'2026-11-03 03:19:44','2026-11-03 03:19:44'),(32,7,34,30.000,7500.00,NULL,NULL,'2026-11-03 03:19:44','2026-11-03 03:19:44'),(33,7,1,12.000,12000.00,NULL,NULL,'2026-11-03 03:19:44','2026-11-03 03:19:44'),(34,7,4,18.000,2500.00,NULL,NULL,'2026-11-03 03:19:44','2026-11-03 03:19:44'),(35,7,7,24.000,65000.00,NULL,NULL,'2026-11-03 03:19:44','2026-11-03 03:19:44'),(36,8,36,30.000,11500.00,NULL,NULL,'2026-11-03 03:19:44','2026-11-03 03:19:44'),(37,8,3,12.000,2800.00,NULL,NULL,'2026-11-03 03:19:44','2026-11-03 03:19:44'),(38,8,6,18.000,1500.00,NULL,NULL,'2026-11-03 03:19:44','2026-11-03 03:19:44'),(39,8,9,24.000,14000.00,NULL,NULL,'2026-11-03 03:19:44','2026-11-03 03:19:44'),(40,8,12,30.000,500.00,NULL,NULL,'2026-11-03 03:19:44','2026-11-03 03:19:44');
/*!40000 ALTER TABLE `stock_in_items` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `stock_ins`
--

DROP TABLE IF EXISTS `stock_ins`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `stock_ins` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `document_number` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `supplier_name` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `received_at` timestamp NOT NULL,
  `note` text COLLATE utf8mb4_unicode_ci,
  `created_by` bigint unsigned DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `stock_ins_document_number_unique` (`document_number`),
  KEY `stock_ins_created_by_foreign` (`created_by`),
  KEY `stock_ins_created_at_index` (`created_at`),
  CONSTRAINT `stock_ins_created_by_foreign` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `stock_ins`
--

LOCK TABLES `stock_ins` WRITE;
/*!40000 ALTER TABLE `stock_ins` DISABLE KEYS */;
INSERT INTO `stock_ins` VALUES (1,'IN-202610-0001','PT Sumber Pangan Nusantara','2026-10-12 02:30:00','Penerimaan barang rutin untuk kebutuhan toko.',3,'2026-10-12 02:30:00','2026-10-12 02:30:00'),(2,'IN-202610-0002','CV Segar Makmur','2026-10-14 02:30:00','Penerimaan barang rutin untuk kebutuhan toko.',3,'2026-10-14 02:30:00','2026-10-14 02:30:00'),(3,'IN-202610-0003','PT Mitra Kebutuhan Harian','2026-10-16 02:30:00','Penerimaan barang rutin untuk kebutuhan toko.',3,'2026-10-16 02:30:00','2026-10-16 02:30:00'),(4,'IN-202610-0004','UD Berkah Jaya','2026-10-18 02:30:00','Penerimaan barang rutin untuk kebutuhan toko.',3,'2026-10-18 02:30:00','2026-10-18 02:30:00'),(5,'IN-202610-0005','PT Sumber Pangan Nusantara','2026-10-20 02:30:00','Penerimaan barang rutin untuk kebutuhan toko.',3,'2026-10-20 02:30:00','2026-10-20 02:30:00'),(6,'IN-202610-0006','CV Segar Makmur','2026-10-22 02:30:00','Penerimaan barang rutin untuk kebutuhan toko.',3,'2026-10-22 02:30:00','2026-10-22 02:30:00'),(7,'IN-202610-0007','PT Mitra Kebutuhan Harian','2026-10-24 02:30:00','Penerimaan barang rutin untuk kebutuhan toko.',3,'2026-10-24 02:30:00','2026-10-24 02:30:00'),(8,'IN-202610-0008','UD Berkah Jaya','2026-10-26 02:30:00','Penerimaan barang rutin untuk kebutuhan toko.',3,'2026-10-26 02:30:00','2026-10-26 02:30:00');
/*!40000 ALTER TABLE `stock_ins` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `stock_movements`
--

DROP TABLE IF EXISTS `stock_movements`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `stock_movements` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `product_id` bigint unsigned NOT NULL,
  `batch_id` bigint unsigned DEFAULT NULL,
  `created_by` bigint unsigned DEFAULT NULL,
  `type` enum('sale','refund','in','adjust') COLLATE utf8mb4_unicode_ci NOT NULL,
  `qty` decimal(15,3) NOT NULL,
  `balance_after` decimal(15,3) NOT NULL,
  `reference_type` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `reference_id` bigint unsigned DEFAULT NULL,
  `note` text COLLATE utf8mb4_unicode_ci,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `stock_movements_batch_id_foreign` (`batch_id`),
  KEY `stock_movements_created_by_foreign` (`created_by`),
  KEY `stock_movements_product_id_created_at_index` (`product_id`,`created_at`),
  KEY `stock_movements_reference_type_reference_id_index` (`reference_type`,`reference_id`),
  CONSTRAINT `stock_movements_batch_id_foreign` FOREIGN KEY (`batch_id`) REFERENCES `batches` (`id`) ON DELETE SET NULL,
  CONSTRAINT `stock_movements_created_by_foreign` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`) ON DELETE SET NULL,
  CONSTRAINT `stock_movements_product_id_foreign` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=229 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `stock_movements`
--

LOCK TABLES `stock_movements` WRITE;
/*!40000 ALTER TABLE `stock_movements` DISABLE KEYS */;
INSERT INTO `stock_movements` VALUES (1,1,NULL,3,'in',12.000,37.000,'App\\Models\\StockIn',1,'IN-202610-0001','2026-10-12 02:30:00',NULL),(2,4,NULL,3,'in',18.000,98.000,'App\\Models\\StockIn',1,'IN-202610-0001','2026-10-12 02:30:00',NULL),(3,7,NULL,3,'in',24.000,44.000,'App\\Models\\StockIn',1,'IN-202610-0001','2026-10-12 02:30:00',NULL),(4,10,NULL,3,'in',30.000,75.000,'App\\Models\\StockIn',1,'IN-202610-0001','2026-10-12 02:30:00',NULL),(5,13,NULL,3,'in',12.000,92.000,'App\\Models\\StockIn',1,'IN-202610-0001','2026-10-12 02:30:00',NULL),(6,6,NULL,3,'in',18.000,168.000,'App\\Models\\StockIn',2,'IN-202610-0002','2026-10-14 02:30:00',NULL),(7,9,NULL,3,'in',24.000,54.000,'App\\Models\\StockIn',2,'IN-202610-0002','2026-10-14 02:30:00',NULL),(8,12,NULL,3,'in',30.000,30.000,'App\\Models\\StockIn',2,'IN-202610-0002','2026-10-14 02:30:00',NULL),(9,15,NULL,3,'in',12.000,102.000,'App\\Models\\StockIn',2,'IN-202610-0002','2026-10-14 02:30:00',NULL),(10,18,NULL,3,'in',18.000,73.000,'App\\Models\\StockIn',2,'IN-202610-0002','2026-10-14 02:30:00',NULL),(11,11,NULL,3,'in',24.000,52.000,'App\\Models\\StockIn',3,'IN-202610-0003','2026-10-16 02:30:00',NULL),(12,14,NULL,3,'in',30.000,75.000,'App\\Models\\StockIn',3,'IN-202610-0003','2026-10-16 02:30:00',NULL),(13,17,NULL,3,'in',12.000,54.000,'App\\Models\\StockIn',3,'IN-202610-0003','2026-10-16 02:30:00',NULL),(14,20,NULL,3,'in',18.000,108.000,'App\\Models\\StockIn',3,'IN-202610-0003','2026-10-16 02:30:00',NULL),(15,23,NULL,3,'in',24.000,60.000,'App\\Models\\StockIn',3,'IN-202610-0003','2026-10-16 02:30:00',NULL),(16,16,NULL,3,'in',30.000,78.000,'App\\Models\\StockIn',4,'IN-202610-0004','2026-10-18 02:30:00',NULL),(17,19,NULL,3,'in',12.000,82.000,'App\\Models\\StockIn',4,'IN-202610-0004','2026-10-18 02:30:00',NULL),(18,22,NULL,3,'in',18.000,68.000,'App\\Models\\StockIn',4,'IN-202610-0004','2026-10-18 02:30:00',NULL),(19,25,NULL,3,'in',24.000,108.000,'App\\Models\\StockIn',4,'IN-202610-0004','2026-10-18 02:30:00',NULL),(20,28,NULL,3,'in',30.000,92.000,'App\\Models\\StockIn',4,'IN-202610-0004','2026-10-18 02:30:00',NULL),(21,21,NULL,3,'in',12.000,70.000,'App\\Models\\StockIn',5,'IN-202610-0005','2026-10-20 02:30:00',NULL),(22,24,NULL,3,'in',18.000,62.000,'App\\Models\\StockIn',5,'IN-202610-0005','2026-10-20 02:30:00',NULL),(23,27,NULL,3,'in',24.000,89.000,'App\\Models\\StockIn',5,'IN-202610-0005','2026-10-20 02:30:00',NULL),(24,30,NULL,3,'in',30.000,82.000,'App\\Models\\StockIn',5,'IN-202610-0005','2026-10-20 02:30:00',NULL),(25,33,NULL,3,'in',12.000,54.000,'App\\Models\\StockIn',5,'IN-202610-0005','2026-10-20 02:30:00',NULL),(26,26,NULL,3,'in',18.000,90.000,'App\\Models\\StockIn',6,'IN-202610-0006','2026-10-22 02:30:00',NULL),(27,29,NULL,3,'in',24.000,69.000,'App\\Models\\StockIn',6,'IN-202610-0006','2026-10-22 02:30:00',NULL),(28,32,NULL,3,'in',30.000,70.000,'App\\Models\\StockIn',6,'IN-202610-0006','2026-10-22 02:30:00',NULL),(29,35,NULL,3,'in',12.000,64.000,'App\\Models\\StockIn',6,'IN-202610-0006','2026-10-22 02:30:00',NULL),(30,2,NULL,3,'in',18.000,58.000,'App\\Models\\StockIn',6,'IN-202610-0006','2026-10-22 02:30:00',NULL),(31,31,NULL,3,'in',24.000,174.000,'App\\Models\\StockIn',7,'IN-202610-0007','2026-10-24 02:30:00',NULL),(32,34,NULL,3,'in',30.000,74.000,'App\\Models\\StockIn',7,'IN-202610-0007','2026-10-24 02:30:00',NULL),(33,1,NULL,3,'in',12.000,49.000,'App\\Models\\StockIn',7,'IN-202610-0007','2026-10-24 02:30:00',NULL),(34,4,NULL,3,'in',18.000,116.000,'App\\Models\\StockIn',7,'IN-202610-0007','2026-10-24 02:30:00',NULL),(35,7,NULL,3,'in',24.000,68.000,'App\\Models\\StockIn',7,'IN-202610-0007','2026-10-24 02:30:00',NULL),(36,36,NULL,3,'in',30.000,66.000,'App\\Models\\StockIn',8,'IN-202610-0008','2026-10-26 02:30:00',NULL),(37,3,NULL,3,'in',12.000,132.000,'App\\Models\\StockIn',8,'IN-202610-0008','2026-10-26 02:30:00',NULL),(38,6,NULL,3,'in',18.000,186.000,'App\\Models\\StockIn',8,'IN-202610-0008','2026-10-26 02:30:00',NULL),(39,9,NULL,3,'in',24.000,78.000,'App\\Models\\StockIn',8,'IN-202610-0008','2026-10-26 02:30:00',NULL),(40,12,NULL,3,'in',30.000,60.000,'App\\Models\\StockIn',8,'IN-202610-0008','2026-10-26 02:30:00',NULL),(41,2,NULL,2,'sale',-1.000,57.000,'App\\Models\\Sale',1,'INV-20261014-0001','2026-10-14 05:17:00',NULL),(42,13,NULL,2,'sale',-2.000,90.000,'App\\Models\\Sale',1,'INV-20261014-0001','2026-10-14 05:17:00',NULL),(43,7,NULL,2,'sale',-1.000,67.000,'App\\Models\\Sale',2,'INV-20261014-0002','2026-10-14 08:24:00',NULL),(44,18,NULL,2,'sale',-2.000,71.000,'App\\Models\\Sale',2,'INV-20261014-0002','2026-10-14 08:24:00',NULL),(45,29,NULL,2,'sale',-1.000,68.000,'App\\Models\\Sale',2,'INV-20261014-0002','2026-10-14 08:24:00',NULL),(46,23,NULL,2,'sale',-2.000,58.000,'App\\Models\\Sale',3,'INV-20261014-0003','2026-10-14 11:31:00',NULL),(47,34,NULL,2,'sale',-1.000,73.000,'App\\Models\\Sale',3,'INV-20261014-0003','2026-10-14 11:31:00',NULL),(48,9,NULL,2,'sale',-2.000,76.000,'App\\Models\\Sale',3,'INV-20261014-0003','2026-10-14 11:31:00',NULL),(49,31,NULL,2,'sale',-2.000,172.000,'App\\Models\\Sale',4,'INV-20261015-0001','2026-10-15 05:17:00',NULL),(50,6,NULL,2,'sale',-1.000,185.000,'App\\Models\\Sale',4,'INV-20261015-0001','2026-10-15 05:17:00',NULL),(51,17,NULL,2,'sale',-2.000,52.000,'App\\Models\\Sale',4,'INV-20261015-0001','2026-10-15 05:17:00',NULL),(52,28,NULL,2,'sale',-1.000,91.000,'App\\Models\\Sale',4,'INV-20261015-0001','2026-10-15 05:17:00',NULL),(53,36,NULL,2,'sale',-2.000,64.000,'App\\Models\\Sale',5,'INV-20261015-0002','2026-10-15 08:24:00',NULL),(54,11,NULL,2,'sale',-1.000,51.000,'App\\Models\\Sale',5,'INV-20261015-0002','2026-10-15 08:24:00',NULL),(55,5,NULL,2,'sale',-2.000,58.000,'App\\Models\\Sale',6,'INV-20261015-0003','2026-10-15 11:31:00',NULL),(56,16,NULL,2,'sale',-1.000,77.000,'App\\Models\\Sale',6,'INV-20261015-0003','2026-10-15 11:31:00',NULL),(57,27,NULL,2,'sale',-2.000,87.000,'App\\Models\\Sale',6,'INV-20261015-0003','2026-10-15 11:31:00',NULL),(58,24,NULL,2,'sale',-1.000,61.000,'App\\Models\\Sale',7,'INV-20261016-0001','2026-10-16 05:17:00',NULL),(59,35,NULL,2,'sale',-2.000,62.000,'App\\Models\\Sale',7,'INV-20261016-0001','2026-10-16 05:17:00',NULL),(60,10,NULL,2,'sale',-1.000,74.000,'App\\Models\\Sale',7,'INV-20261016-0001','2026-10-16 05:17:00',NULL),(61,29,NULL,2,'sale',-1.000,67.000,'App\\Models\\Sale',8,'INV-20261016-0002','2026-10-16 08:24:00',NULL),(62,4,NULL,2,'sale',-2.000,114.000,'App\\Models\\Sale',8,'INV-20261016-0002','2026-10-16 08:24:00',NULL),(63,15,NULL,2,'sale',-1.000,101.000,'App\\Models\\Sale',8,'INV-20261016-0002','2026-10-16 08:24:00',NULL),(64,26,NULL,2,'sale',-2.000,88.000,'App\\Models\\Sale',8,'INV-20261016-0002','2026-10-16 08:24:00',NULL),(65,34,NULL,2,'sale',-1.000,72.000,'App\\Models\\Sale',9,'INV-20261016-0003','2026-10-16 11:31:00',NULL),(66,9,NULL,2,'sale',-2.000,74.000,'App\\Models\\Sale',9,'INV-20261016-0003','2026-10-16 11:31:00',NULL),(67,17,NULL,2,'sale',-2.000,50.000,'App\\Models\\Sale',10,'INV-20261017-0001','2026-10-17 05:17:00',NULL),(68,28,NULL,2,'sale',-1.000,90.000,'App\\Models\\Sale',10,'INV-20261017-0001','2026-10-17 05:17:00',NULL),(69,22,NULL,2,'sale',-2.000,66.000,'App\\Models\\Sale',11,'INV-20261017-0002','2026-10-17 08:24:00',NULL),(70,33,NULL,2,'sale',-1.000,53.000,'App\\Models\\Sale',11,'INV-20261017-0002','2026-10-17 08:24:00',NULL),(71,8,NULL,2,'sale',-2.000,33.000,'App\\Models\\Sale',11,'INV-20261017-0002','2026-10-17 08:24:00',NULL),(72,27,NULL,2,'sale',-2.000,85.000,'App\\Models\\Sale',12,'INV-20261017-0003','2026-10-17 11:31:00',NULL),(73,2,NULL,2,'sale',-1.000,56.000,'App\\Models\\Sale',12,'INV-20261017-0003','2026-10-17 11:31:00',NULL),(74,13,NULL,2,'sale',-2.000,88.000,'App\\Models\\Sale',12,'INV-20261017-0003','2026-10-17 11:31:00',NULL),(75,24,NULL,2,'sale',-1.000,60.000,'App\\Models\\Sale',12,'INV-20261017-0003','2026-10-17 11:31:00',NULL),(76,10,NULL,2,'sale',-1.000,73.000,'App\\Models\\Sale',13,'INV-20261018-0001','2026-10-18 05:17:00',NULL),(77,21,NULL,2,'sale',-2.000,68.000,'App\\Models\\Sale',13,'INV-20261018-0001','2026-10-18 05:17:00',NULL),(78,32,NULL,2,'sale',-1.000,69.000,'App\\Models\\Sale',13,'INV-20261018-0001','2026-10-18 05:17:00',NULL),(79,7,NULL,2,'sale',-2.000,65.000,'App\\Models\\Sale',13,'INV-20261018-0001','2026-10-18 05:17:00',NULL),(80,15,NULL,2,'sale',-1.000,100.000,'App\\Models\\Sale',14,'INV-20261018-0002','2026-10-18 08:24:00',NULL),(81,26,NULL,2,'sale',-2.000,86.000,'App\\Models\\Sale',14,'INV-20261018-0002','2026-10-18 08:24:00',NULL),(82,20,NULL,2,'sale',-1.000,107.000,'App\\Models\\Sale',15,'INV-20261018-0003','2026-10-18 11:31:00',NULL),(83,31,NULL,2,'sale',-2.000,170.000,'App\\Models\\Sale',15,'INV-20261018-0003','2026-10-18 11:31:00',NULL),(84,6,NULL,2,'sale',-1.000,184.000,'App\\Models\\Sale',15,'INV-20261018-0003','2026-10-18 11:31:00',NULL),(85,3,NULL,2,'sale',-2.000,130.000,'App\\Models\\Sale',16,'INV-20261019-0001','2026-10-19 05:17:00',NULL),(86,14,NULL,2,'sale',-1.000,74.000,'App\\Models\\Sale',16,'INV-20261019-0001','2026-10-19 05:17:00',NULL),(87,25,NULL,2,'sale',-2.000,106.000,'App\\Models\\Sale',16,'INV-20261019-0001','2026-10-19 05:17:00',NULL),(88,8,NULL,2,'sale',-2.000,31.000,'App\\Models\\Sale',17,'INV-20261019-0002','2026-10-19 08:24:00',NULL),(89,19,NULL,2,'sale',-1.000,81.000,'App\\Models\\Sale',17,'INV-20261019-0002','2026-10-19 08:24:00',NULL),(90,30,NULL,2,'sale',-2.000,80.000,'App\\Models\\Sale',17,'INV-20261019-0002','2026-10-19 08:24:00',NULL),(91,5,NULL,2,'sale',-1.000,57.000,'App\\Models\\Sale',17,'INV-20261019-0002','2026-10-19 08:24:00',NULL),(92,13,NULL,2,'sale',-2.000,86.000,'App\\Models\\Sale',18,'INV-20261019-0003','2026-10-19 11:31:00',NULL),(93,24,NULL,2,'sale',-1.000,59.000,'App\\Models\\Sale',18,'INV-20261019-0003','2026-10-19 11:31:00',NULL),(94,32,NULL,2,'sale',-1.000,68.000,'App\\Models\\Sale',19,'INV-20261020-0001','2026-10-20 05:17:00',NULL),(95,7,NULL,2,'sale',-2.000,63.000,'App\\Models\\Sale',19,'INV-20261020-0001','2026-10-20 05:17:00',NULL),(96,1,NULL,2,'sale',-1.000,48.000,'App\\Models\\Sale',20,'INV-20261020-0002','2026-10-20 08:24:00',NULL),(97,23,NULL,2,'sale',-1.000,57.000,'App\\Models\\Sale',20,'INV-20261020-0002','2026-10-20 08:24:00',NULL),(98,6,NULL,2,'sale',-1.000,183.000,'App\\Models\\Sale',21,'INV-20261020-0003','2026-10-20 11:31:00',NULL),(99,17,NULL,2,'sale',-2.000,48.000,'App\\Models\\Sale',21,'INV-20261020-0003','2026-10-20 11:31:00',NULL),(100,28,NULL,2,'sale',-1.000,89.000,'App\\Models\\Sale',21,'INV-20261020-0003','2026-10-20 11:31:00',NULL),(101,3,NULL,2,'sale',-2.000,128.000,'App\\Models\\Sale',21,'INV-20261020-0003','2026-10-20 11:31:00',NULL),(102,25,NULL,2,'sale',-2.000,104.000,'App\\Models\\Sale',22,'INV-20261021-0001','2026-10-21 05:17:00',NULL),(103,36,NULL,2,'sale',-1.000,63.000,'App\\Models\\Sale',22,'INV-20261021-0001','2026-10-21 05:17:00',NULL),(104,11,NULL,2,'sale',-2.000,49.000,'App\\Models\\Sale',22,'INV-20261021-0001','2026-10-21 05:17:00',NULL),(105,22,NULL,2,'sale',-1.000,65.000,'App\\Models\\Sale',22,'INV-20261021-0001','2026-10-21 05:17:00',NULL),(106,30,NULL,2,'sale',-2.000,78.000,'App\\Models\\Sale',23,'INV-20261021-0002','2026-10-21 08:24:00',NULL),(107,5,NULL,2,'sale',-1.000,56.000,'App\\Models\\Sale',23,'INV-20261021-0002','2026-10-21 08:24:00',NULL),(108,35,NULL,2,'sale',-2.000,60.000,'App\\Models\\Sale',24,'INV-20261021-0003','2026-10-21 11:31:00',NULL),(109,10,NULL,2,'sale',-1.000,72.000,'App\\Models\\Sale',24,'INV-20261021-0003','2026-10-21 11:31:00',NULL),(110,21,NULL,2,'sale',-2.000,66.000,'App\\Models\\Sale',24,'INV-20261021-0003','2026-10-21 11:31:00',NULL),(111,18,NULL,2,'sale',-1.000,70.000,'App\\Models\\Sale',25,'INV-20261022-0001','2026-10-22 05:17:00',NULL),(112,29,NULL,2,'sale',-2.000,65.000,'App\\Models\\Sale',25,'INV-20261022-0001','2026-10-22 05:17:00',NULL),(113,4,NULL,2,'sale',-1.000,113.000,'App\\Models\\Sale',25,'INV-20261022-0001','2026-10-22 05:17:00',NULL),(114,23,NULL,2,'sale',-1.000,56.000,'App\\Models\\Sale',26,'INV-20261022-0002','2026-10-22 08:24:00',NULL),(115,34,NULL,2,'sale',-2.000,70.000,'App\\Models\\Sale',26,'INV-20261022-0002','2026-10-22 08:24:00',NULL),(116,9,NULL,2,'sale',-1.000,73.000,'App\\Models\\Sale',26,'INV-20261022-0002','2026-10-22 08:24:00',NULL),(117,20,NULL,2,'sale',-2.000,105.000,'App\\Models\\Sale',26,'INV-20261022-0002','2026-10-22 08:24:00',NULL),(118,28,NULL,2,'sale',-1.000,88.000,'App\\Models\\Sale',27,'INV-20261022-0003','2026-10-22 11:31:00',NULL),(119,3,NULL,2,'sale',-2.000,126.000,'App\\Models\\Sale',27,'INV-20261022-0003','2026-10-22 11:31:00',NULL),(120,11,NULL,2,'sale',-2.000,47.000,'App\\Models\\Sale',28,'INV-20261023-0001','2026-10-23 05:17:00',NULL),(121,22,NULL,2,'sale',-1.000,64.000,'App\\Models\\Sale',28,'INV-20261023-0001','2026-10-23 05:17:00',NULL),(122,16,NULL,2,'sale',-2.000,75.000,'App\\Models\\Sale',29,'INV-20261023-0002','2026-10-23 08:24:00',NULL),(123,27,NULL,2,'sale',-1.000,84.000,'App\\Models\\Sale',29,'INV-20261023-0002','2026-10-23 08:24:00',NULL),(124,2,NULL,2,'sale',-2.000,54.000,'App\\Models\\Sale',29,'INV-20261023-0002','2026-10-23 08:24:00',NULL),(125,21,NULL,2,'sale',-2.000,64.000,'App\\Models\\Sale',30,'INV-20261023-0003','2026-10-23 11:31:00',NULL),(126,32,NULL,2,'sale',-1.000,67.000,'App\\Models\\Sale',30,'INV-20261023-0003','2026-10-23 11:31:00',NULL),(127,7,NULL,2,'sale',-2.000,61.000,'App\\Models\\Sale',30,'INV-20261023-0003','2026-10-23 11:31:00',NULL),(128,18,NULL,2,'sale',-1.000,69.000,'App\\Models\\Sale',30,'INV-20261023-0003','2026-10-23 11:31:00',NULL),(129,4,NULL,2,'sale',-1.000,112.000,'App\\Models\\Sale',31,'INV-20261024-0001','2026-10-24 05:17:00',NULL),(130,15,NULL,2,'sale',-2.000,98.000,'App\\Models\\Sale',31,'INV-20261024-0001','2026-10-24 05:17:00',NULL),(131,26,NULL,2,'sale',-1.000,85.000,'App\\Models\\Sale',31,'INV-20261024-0001','2026-10-24 05:17:00',NULL),(132,1,NULL,2,'sale',-2.000,46.000,'App\\Models\\Sale',31,'INV-20261024-0001','2026-10-24 05:17:00',NULL),(133,9,NULL,2,'sale',-1.000,72.000,'App\\Models\\Sale',32,'INV-20261024-0002','2026-10-24 08:24:00',NULL),(134,20,NULL,2,'sale',-2.000,103.000,'App\\Models\\Sale',32,'INV-20261024-0002','2026-10-24 08:24:00',NULL),(135,14,NULL,2,'sale',-1.000,73.000,'App\\Models\\Sale',33,'INV-20261024-0003','2026-10-24 11:31:00',NULL),(136,25,NULL,2,'sale',-2.000,102.000,'App\\Models\\Sale',33,'INV-20261024-0003','2026-10-24 11:31:00',NULL),(137,36,NULL,2,'sale',-1.000,62.000,'App\\Models\\Sale',33,'INV-20261024-0003','2026-10-24 11:31:00',NULL),(138,33,NULL,2,'sale',-2.000,51.000,'App\\Models\\Sale',34,'INV-20261025-0001','2026-10-25 05:17:00',NULL),(139,8,NULL,2,'sale',-1.000,30.000,'App\\Models\\Sale',34,'INV-20261025-0001','2026-10-25 05:17:00',NULL),(140,19,NULL,2,'sale',-2.000,79.000,'App\\Models\\Sale',34,'INV-20261025-0001','2026-10-25 05:17:00',NULL),(141,2,NULL,2,'sale',-2.000,52.000,'App\\Models\\Sale',35,'INV-20261025-0002','2026-10-25 08:24:00',NULL),(142,13,NULL,2,'sale',-1.000,85.000,'App\\Models\\Sale',35,'INV-20261025-0002','2026-10-25 08:24:00',NULL),(143,24,NULL,2,'sale',-2.000,57.000,'App\\Models\\Sale',35,'INV-20261025-0002','2026-10-25 08:24:00',NULL),(144,35,NULL,2,'sale',-1.000,59.000,'App\\Models\\Sale',35,'INV-20261025-0002','2026-10-25 08:24:00',NULL),(145,7,NULL,2,'sale',-2.000,59.000,'App\\Models\\Sale',36,'INV-20261025-0003','2026-10-25 11:31:00',NULL),(146,18,NULL,2,'sale',-1.000,68.000,'App\\Models\\Sale',36,'INV-20261025-0003','2026-10-25 11:31:00',NULL),(147,26,NULL,2,'sale',-1.000,84.000,'App\\Models\\Sale',37,'INV-20261026-0001','2026-10-26 05:17:00',NULL),(148,1,NULL,2,'sale',-2.000,44.000,'App\\Models\\Sale',37,'INV-20261026-0001','2026-10-26 05:17:00',NULL),(149,31,NULL,2,'sale',-1.000,169.000,'App\\Models\\Sale',38,'INV-20261026-0002','2026-10-26 08:24:00',NULL),(150,6,NULL,2,'sale',-2.000,181.000,'App\\Models\\Sale',38,'INV-20261026-0002','2026-10-26 08:24:00',NULL),(151,17,NULL,2,'sale',-1.000,47.000,'App\\Models\\Sale',38,'INV-20261026-0002','2026-10-26 08:24:00',NULL),(152,36,NULL,2,'sale',-1.000,61.000,'App\\Models\\Sale',39,'INV-20261026-0003','2026-10-26 11:31:00',NULL),(153,11,NULL,2,'sale',-2.000,45.000,'App\\Models\\Sale',39,'INV-20261026-0003','2026-10-26 11:31:00',NULL),(154,22,NULL,2,'sale',-1.000,63.000,'App\\Models\\Sale',39,'INV-20261026-0003','2026-10-26 11:31:00',NULL),(155,33,NULL,2,'sale',-2.000,49.000,'App\\Models\\Sale',39,'INV-20261026-0003','2026-10-26 11:31:00',NULL),(156,19,NULL,2,'sale',-2.000,77.000,'App\\Models\\Sale',40,'INV-20261027-0001','2026-10-27 05:17:00',NULL),(157,30,NULL,2,'sale',-1.000,77.000,'App\\Models\\Sale',40,'INV-20261027-0001','2026-10-27 05:17:00',NULL),(158,5,NULL,2,'sale',-2.000,54.000,'App\\Models\\Sale',40,'INV-20261027-0001','2026-10-27 05:17:00',NULL),(159,16,NULL,2,'sale',-1.000,74.000,'App\\Models\\Sale',40,'INV-20261027-0001','2026-10-27 05:17:00',NULL),(160,24,NULL,2,'sale',-2.000,55.000,'App\\Models\\Sale',41,'INV-20261027-0002','2026-10-27 08:24:00',NULL),(161,35,NULL,2,'sale',-1.000,58.000,'App\\Models\\Sale',41,'INV-20261027-0002','2026-10-27 08:24:00',NULL),(162,29,NULL,2,'sale',-2.000,63.000,'App\\Models\\Sale',42,'INV-20261027-0003','2026-10-27 11:31:00',NULL),(163,4,NULL,2,'sale',-1.000,111.000,'App\\Models\\Sale',42,'INV-20261027-0003','2026-10-27 11:31:00',NULL),(164,15,NULL,2,'sale',-2.000,96.000,'App\\Models\\Sale',42,'INV-20261027-0003','2026-10-27 11:31:00',NULL),(165,23,NULL,2,'sale',-2.000,54.000,'App\\Models\\Sale',43,'INV-20261028-0001','2026-10-28 05:17:00',NULL),(166,34,NULL,2,'sale',-1.000,69.000,'App\\Models\\Sale',43,'INV-20261028-0001','2026-10-28 05:17:00',NULL),(167,17,NULL,2,'sale',-1.000,46.000,'App\\Models\\Sale',44,'INV-20261028-0002','2026-10-28 08:24:00',NULL),(168,28,NULL,2,'sale',-2.000,86.000,'App\\Models\\Sale',44,'INV-20261028-0002','2026-10-28 08:24:00',NULL),(169,3,NULL,2,'sale',-1.000,125.000,'App\\Models\\Sale',44,'INV-20261028-0002','2026-10-28 08:24:00',NULL),(170,14,NULL,2,'sale',-2.000,71.000,'App\\Models\\Sale',44,'INV-20261028-0002','2026-10-28 08:24:00',NULL),(171,22,NULL,2,'sale',-1.000,62.000,'App\\Models\\Sale',45,'INV-20261028-0003','2026-10-28 11:31:00',NULL),(172,33,NULL,2,'sale',-2.000,47.000,'App\\Models\\Sale',45,'INV-20261028-0003','2026-10-28 11:31:00',NULL),(173,5,NULL,2,'sale',-2.000,52.000,'App\\Models\\Sale',46,'INV-20261029-0001','2026-10-29 05:17:00',NULL),(174,16,NULL,2,'sale',-1.000,73.000,'App\\Models\\Sale',46,'INV-20261029-0001','2026-10-29 05:17:00',NULL),(175,10,NULL,2,'sale',-2.000,70.000,'App\\Models\\Sale',47,'INV-20261029-0002','2026-10-29 08:24:00',NULL),(176,21,NULL,2,'sale',-1.000,63.000,'App\\Models\\Sale',47,'INV-20261029-0002','2026-10-29 08:24:00',NULL),(177,32,NULL,2,'sale',-2.000,65.000,'App\\Models\\Sale',47,'INV-20261029-0002','2026-10-29 08:24:00',NULL),(178,15,NULL,2,'sale',-2.000,94.000,'App\\Models\\Sale',48,'INV-20261029-0003','2026-10-29 11:31:00',NULL),(179,26,NULL,2,'sale',-1.000,83.000,'App\\Models\\Sale',48,'INV-20261029-0003','2026-10-29 11:31:00',NULL),(180,1,NULL,2,'sale',-2.000,42.000,'App\\Models\\Sale',48,'INV-20261029-0003','2026-10-29 11:31:00',NULL),(181,34,NULL,2,'sale',-1.000,68.000,'App\\Models\\Sale',49,'INV-20261030-0001','2026-10-30 05:17:00',NULL),(182,9,NULL,2,'sale',-2.000,70.000,'App\\Models\\Sale',49,'INV-20261030-0001','2026-10-30 05:17:00',NULL),(183,20,NULL,2,'sale',-1.000,102.000,'App\\Models\\Sale',49,'INV-20261030-0001','2026-10-30 05:17:00',NULL),(184,31,NULL,2,'sale',-2.000,167.000,'App\\Models\\Sale',49,'INV-20261030-0001','2026-10-30 05:17:00',NULL),(185,3,NULL,2,'sale',-1.000,124.000,'App\\Models\\Sale',50,'INV-20261030-0002','2026-10-30 08:24:00',NULL),(186,14,NULL,2,'sale',-2.000,69.000,'App\\Models\\Sale',50,'INV-20261030-0002','2026-10-30 08:24:00',NULL),(187,8,NULL,2,'sale',-1.000,29.000,'App\\Models\\Sale',51,'INV-20261030-0003','2026-10-30 11:31:00',NULL),(188,19,NULL,2,'sale',-2.000,75.000,'App\\Models\\Sale',51,'INV-20261030-0003','2026-10-30 11:31:00',NULL),(189,30,NULL,2,'sale',-1.000,76.000,'App\\Models\\Sale',51,'INV-20261030-0003','2026-10-30 11:31:00',NULL),(190,27,NULL,2,'sale',-2.000,82.000,'App\\Models\\Sale',52,'INV-20261031-0001','2026-10-31 05:17:00',NULL),(191,2,NULL,2,'sale',-1.000,51.000,'App\\Models\\Sale',52,'INV-20261031-0001','2026-10-31 05:17:00',NULL),(192,13,NULL,2,'sale',-2.000,83.000,'App\\Models\\Sale',52,'INV-20261031-0001','2026-10-31 05:17:00',NULL),(193,32,NULL,2,'sale',-2.000,63.000,'App\\Models\\Sale',53,'INV-20261031-0002','2026-10-31 08:24:00',NULL),(194,7,NULL,2,'sale',-1.000,58.000,'App\\Models\\Sale',53,'INV-20261031-0002','2026-10-31 08:24:00',NULL),(195,18,NULL,2,'sale',-2.000,66.000,'App\\Models\\Sale',53,'INV-20261031-0002','2026-10-31 08:24:00',NULL),(196,29,NULL,2,'sale',-1.000,62.000,'App\\Models\\Sale',53,'INV-20261031-0002','2026-10-31 08:24:00',NULL),(197,1,NULL,2,'sale',-2.000,40.000,'App\\Models\\Sale',54,'INV-20261031-0003','2026-10-31 11:31:00',NULL),(198,20,NULL,2,'sale',-1.000,101.000,'App\\Models\\Sale',55,'INV-20261101-0001','2026-11-01 05:17:00',NULL),(199,31,NULL,2,'sale',-2.000,165.000,'App\\Models\\Sale',55,'INV-20261101-0001','2026-11-01 05:17:00',NULL),(200,25,NULL,2,'sale',-1.000,101.000,'App\\Models\\Sale',56,'INV-20261101-0002','2026-11-01 08:24:00',NULL),(201,36,NULL,2,'sale',-2.000,59.000,'App\\Models\\Sale',56,'INV-20261101-0002','2026-11-01 08:24:00',NULL),(202,11,NULL,2,'sale',-1.000,44.000,'App\\Models\\Sale',56,'INV-20261101-0002','2026-11-01 08:24:00',NULL),(203,30,NULL,2,'sale',-1.000,75.000,'App\\Models\\Sale',57,'INV-20261101-0003','2026-11-01 11:31:00',NULL),(204,5,NULL,2,'sale',-2.000,50.000,'App\\Models\\Sale',57,'INV-20261101-0003','2026-11-01 11:31:00',NULL),(205,16,NULL,2,'sale',-1.000,72.000,'App\\Models\\Sale',57,'INV-20261101-0003','2026-11-01 11:31:00',NULL),(206,27,NULL,2,'sale',-2.000,80.000,'App\\Models\\Sale',57,'INV-20261101-0003','2026-11-01 11:31:00',NULL),(207,13,NULL,2,'sale',-2.000,81.000,'App\\Models\\Sale',58,'INV-20261102-0001','2026-11-02 05:17:00',NULL),(208,24,NULL,2,'sale',-1.000,54.000,'App\\Models\\Sale',58,'INV-20261102-0001','2026-11-02 05:17:00',NULL),(209,35,NULL,2,'sale',-2.000,56.000,'App\\Models\\Sale',58,'INV-20261102-0001','2026-11-02 05:17:00',NULL),(210,10,NULL,2,'sale',-1.000,69.000,'App\\Models\\Sale',58,'INV-20261102-0001','2026-11-02 05:17:00',NULL),(211,18,NULL,2,'sale',-2.000,64.000,'App\\Models\\Sale',59,'INV-20261102-0002','2026-11-02 08:24:00',NULL),(212,29,NULL,2,'sale',-1.000,61.000,'App\\Models\\Sale',59,'INV-20261102-0002','2026-11-02 08:24:00',NULL),(213,23,NULL,2,'sale',-2.000,52.000,'App\\Models\\Sale',60,'INV-20261102-0003','2026-11-02 11:31:00',NULL),(214,34,NULL,2,'sale',-1.000,67.000,'App\\Models\\Sale',60,'INV-20261102-0003','2026-11-02 11:31:00',NULL),(215,9,NULL,2,'sale',-2.000,68.000,'App\\Models\\Sale',60,'INV-20261102-0003','2026-11-02 11:31:00',NULL),(216,6,NULL,2,'sale',-1.000,180.000,'App\\Models\\Sale',61,'INV-20261103-0001','2026-11-03 05:17:00',NULL),(217,17,NULL,2,'sale',-2.000,44.000,'App\\Models\\Sale',61,'INV-20261103-0001','2026-11-03 05:17:00',NULL),(218,28,NULL,2,'sale',-1.000,85.000,'App\\Models\\Sale',61,'INV-20261103-0001','2026-11-03 05:17:00',NULL),(219,11,NULL,2,'sale',-1.000,43.000,'App\\Models\\Sale',62,'INV-20261103-0002','2026-11-03 08:24:00',NULL),(220,22,NULL,2,'sale',-2.000,60.000,'App\\Models\\Sale',62,'INV-20261103-0002','2026-11-03 08:24:00',NULL),(221,33,NULL,2,'sale',-1.000,46.000,'App\\Models\\Sale',62,'INV-20261103-0002','2026-11-03 08:24:00',NULL),(222,8,NULL,2,'sale',-2.000,27.000,'App\\Models\\Sale',62,'INV-20261103-0002','2026-11-03 08:24:00',NULL),(223,16,NULL,2,'sale',-1.000,71.000,'App\\Models\\Sale',63,'INV-20261103-0003','2026-11-03 11:31:00',NULL),(224,27,NULL,2,'sale',-2.000,78.000,'App\\Models\\Sale',63,'INV-20261103-0003','2026-11-03 11:31:00',NULL),(225,6,NULL,2,'refund',1.000,181.000,'App\\Models\\Refund',1,'Retur INV-20261103-0001','2026-11-03 11:15:00',NULL),(226,4,NULL,3,'adjust',-1.000,110.000,'App\\Models\\StockAdjustment',1,'ADJ-20261101-0001','2026-11-01 13:15:00',NULL),(227,14,NULL,3,'adjust',-1.000,68.000,'App\\Models\\StockAdjustment',1,'ADJ-20261101-0001','2026-11-01 13:15:00',NULL),(228,24,NULL,3,'adjust',-1.000,53.000,'App\\Models\\StockAdjustment',1,'ADJ-20261101-0001','2026-11-01 13:15:00',NULL);
/*!40000 ALTER TABLE `stock_movements` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `stocks`
--

DROP TABLE IF EXISTS `stocks`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `stocks` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `product_id` bigint unsigned NOT NULL,
  `batch_id` bigint unsigned DEFAULT NULL,
  `batch_key` int unsigned NOT NULL DEFAULT '0',
  `quantity` decimal(15,3) NOT NULL DEFAULT '0.000',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `stocks_product_batch_unique` (`product_id`,`batch_key`),
  KEY `stocks_batch_id_foreign` (`batch_id`),
  KEY `stocks_product_id_index` (`product_id`),
  CONSTRAINT `stocks_batch_id_foreign` FOREIGN KEY (`batch_id`) REFERENCES `batches` (`id`) ON DELETE SET NULL,
  CONSTRAINT `stocks_product_id_foreign` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=37 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `stocks`
--

LOCK TABLES `stocks` WRITE;
/*!40000 ALTER TABLE `stocks` DISABLE KEYS */;
INSERT INTO `stocks` VALUES (1,1,NULL,0,40.000,'2026-11-03 03:19:43','2026-11-03 03:19:47'),(2,2,NULL,0,51.000,'2026-11-03 03:19:43','2026-11-03 03:19:46'),(3,3,NULL,0,124.000,'2026-11-03 03:19:43','2026-11-03 03:19:46'),(4,4,NULL,0,110.000,'2026-11-03 03:19:43','2026-11-03 03:19:47'),(5,5,NULL,0,50.000,'2026-11-03 03:19:43','2026-11-03 03:19:47'),(6,6,NULL,0,181.000,'2026-11-03 03:19:43','2026-11-03 03:19:47'),(7,7,NULL,0,58.000,'2026-11-03 03:19:43','2026-11-03 03:19:46'),(8,8,NULL,0,27.000,'2026-11-03 03:19:43','2026-11-03 03:19:47'),(9,9,NULL,0,68.000,'2026-11-03 03:19:43','2026-11-03 03:19:47'),(10,10,NULL,0,69.000,'2026-11-03 03:19:43','2026-11-03 03:19:47'),(11,11,NULL,0,43.000,'2026-11-03 03:19:43','2026-11-03 03:19:47'),(12,13,NULL,0,81.000,'2026-11-03 03:19:44','2026-11-03 03:19:47'),(13,14,NULL,0,68.000,'2026-11-03 03:19:44','2026-11-03 03:19:47'),(14,15,NULL,0,94.000,'2026-11-03 03:19:44','2026-11-03 03:19:46'),(15,16,NULL,0,71.000,'2026-11-03 03:19:44','2026-11-03 03:19:47'),(16,17,NULL,0,44.000,'2026-11-03 03:19:44','2026-11-03 03:19:47'),(17,18,NULL,0,64.000,'2026-11-03 03:19:44','2026-11-03 03:19:47'),(18,19,NULL,0,75.000,'2026-11-03 03:19:44','2026-11-03 03:19:46'),(19,20,NULL,0,101.000,'2026-11-03 03:19:44','2026-11-03 03:19:47'),(20,21,NULL,0,63.000,'2026-11-03 03:19:44','2026-11-03 03:19:46'),(21,22,NULL,0,60.000,'2026-11-03 03:19:44','2026-11-03 03:19:47'),(22,23,NULL,0,52.000,'2026-11-03 03:19:44','2026-11-03 03:19:47'),(23,24,NULL,0,53.000,'2026-11-03 03:19:44','2026-11-03 03:19:47'),(24,25,NULL,0,101.000,'2026-11-03 03:19:44','2026-11-03 03:19:47'),(25,26,NULL,0,83.000,'2026-11-03 03:19:44','2026-11-03 03:19:46'),(26,27,NULL,0,78.000,'2026-11-03 03:19:44','2026-11-03 03:19:47'),(27,28,NULL,0,85.000,'2026-11-03 03:19:44','2026-11-03 03:19:47'),(28,29,NULL,0,61.000,'2026-11-03 03:19:44','2026-11-03 03:19:47'),(29,30,NULL,0,75.000,'2026-11-03 03:19:44','2026-11-03 03:19:47'),(30,31,NULL,0,165.000,'2026-11-03 03:19:44','2026-11-03 03:19:47'),(31,32,NULL,0,63.000,'2026-11-03 03:19:44','2026-11-03 03:19:46'),(32,33,NULL,0,46.000,'2026-11-03 03:19:44','2026-11-03 03:19:47'),(33,34,NULL,0,67.000,'2026-11-03 03:19:44','2026-11-03 03:19:47'),(34,35,NULL,0,56.000,'2026-11-03 03:19:44','2026-11-03 03:19:47'),(35,36,NULL,0,59.000,'2026-11-03 03:19:44','2026-11-03 03:19:47'),(36,12,NULL,0,60.000,'2026-11-03 03:19:44','2026-11-03 03:19:44');
/*!40000 ALTER TABLE `stocks` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `units`
--

DROP TABLE IF EXISTS `units`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `units` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `short_name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `units_short_name_unique` (`short_name`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `units`
--

LOCK TABLES `units` WRITE;
/*!40000 ALTER TABLE `units` DISABLE KEYS */;
INSERT INTO `units` VALUES (1,'Pieces','pcs','2026-11-03 03:19:43','2026-11-03 03:19:43'),(2,'Botol','btl','2026-11-03 03:19:43','2026-11-03 03:19:43'),(3,'Kilogram','kg','2026-11-03 03:19:43','2026-11-03 03:19:43'),(4,'Liter','ltr','2026-11-03 03:19:43','2026-11-03 03:19:43'),(5,'Pack','pack','2026-11-03 03:19:43','2026-11-03 03:19:43');
/*!40000 ALTER TABLE `units` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `users`
--

DROP TABLE IF EXISTS `users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `users` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `email` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `email_verified_at` timestamp NULL DEFAULT NULL,
  `password` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `role` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'cashier',
  `pin_hash` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT '1',
  `remember_token` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `users_email_unique` (`email`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `users`
--

LOCK TABLES `users` WRITE;
/*!40000 ALTER TABLE `users` DISABLE KEYS */;
INSERT INTO `users` VALUES (1,'Owner KasirKu','owner@kasirku.test',NULL,'$2y$12$UcWVi.Hm6/bWYaMqmxZKLOGpHbYK0D3b0V0P9cwUHTvQFEcCs3.ee','owner','$2y$12$dzCR/S0NpUkkRrOMu.3LXu6GlMhW13QNfx5n8nhYJSbZj1EuULMmm',1,NULL,'2026-11-03 03:19:43','2026-11-03 03:19:43'),(2,'Kasir Utama','kasir@kasirku.test',NULL,'$2y$12$pljIrkAKHaEPxmDYJu7Ws.91IpKtx.7AQ8mjVm5jrliFXz/iuqwHW','cashier',NULL,1,NULL,'2026-11-03 03:19:43','2026-11-03 03:19:43'),(3,'Manajer Toko','manager@kasirku.test',NULL,'$2y$12$nsGjGnz429YV6e/3tqw3g.Hf01R7pVowAbTE5VCKxB8SNJPc2KKmy','manager','$2y$12$iI9FcpdM3EFefvfjTX.2TeRiz/9eT6rr/5gw7IgGkK7LsaXrSmrPW',1,NULL,'2026-11-03 03:19:43','2026-11-03 03:19:43');
/*!40000 ALTER TABLE `users` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping routines for database 'kasirku_deploy'
--
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-11-03 17:19:53
