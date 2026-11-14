# ARIA — Mindful Digital Wellbeing Companion

<p align="center">
  <em>Mengubah dorongan scrolling tanpa sadar menjadi kesadaran penuh melalui pendampingan digital yang empatik, terukur, dan menghormati privasi.</em>
</p>

---

## 1. Latar Belakang & Mengapa ARIA Dibutuhkan (The Problem & Use Case)

### Krisis *Doomscrolling* di Era Perhatian *(Attention Economy)*
Di era media sosial modern (TikTok, Instagram Reels, YouTube Shorts), antarmuka dirancang dengan *frictionless infinite scroll* dan algoritma prediktif berbasis *variable reward schedule*. Mekanisme ini mengeksploitasi refleks dopamin manusia, memicu kondisi *trance* digital di mana pengguna kehilangan kendali waktu dan kesadaran (*dissociative scrolling*). Dampaknya nyata: penurunan rentang atensi (*attention span*), kelelahan mental, kecemasan (*FOMO*), dan penurunan kualitas tidur serta produktivitas.

### Pendekatan Sebagian Besar App Blocker Konvensional (Yang Sering Gagal)
Aplikasi pengontrol waktu layar konvensional umumnya bersandar pada **restriksi keras (punitive blocking)**: memblokir total aplikasi dengan password, mengunci layar, atau mempermalukan pengguna (*guilt-tripping*). Penelitian dan pengalaman membuktikan pendekatan represif ini sering memicu resistensi pengguna (*reactance theory*): pengguna akhirnya menghapus izin atau meng-uninstall aplikasi karena merasa dihakimi dan dikekang.

### Mengapa ARIA Berbeda: Genre *Healthy Wellbeing* & *Mindful Friction*
ARIA hadir bukan sebagai "penjara digital", melainkan sebagai **pendamping sadar (*mindful companion*)**. Filosofi ARIA berpusat pada:
1. **Mindful Friction (Friksi Berkesadaran)**: Alih-alih langsung memblokir paksa, ARIA menyisipkan jeda napas (*breathing pause*) dan pertanyaan reflektif saat pengguna membuka aplikasi sosial media atau saat batas waktu tercapai. Friksi beberapa detik ini mengaktifkan kembali korteks prafrontal (*prefrontal cortex*) sehingga pengguna membuat keputusan sadar: apakah benar-benar butuh lanjut, atau lebih baik menutup aplikasi.
2. **Refleksi Tanpa Penghakiman**: ARIA menyapa dengan nada hangat (*gentle/firm/playful/scriptural*) dan merayakan langkah kecil (*Today's Wins*), bukan mencela durasi scroll.
3. **Penyadaran Waktu Nyata di Tempat (*On-The-Spot Awareness*)**: Melalui *Floating Island* yang melayang lembut tanpa menghalangi pandangan, pengguna selalu memiliki "cermin waktu" yang memperlihatkan berapa video yang sudah dilewati.
4. **Gamifikasi Berbasis Usaha Positif**: Menghargai kemauan pengguna untuk berhenti sejenak, keluar dari aplikasi dalam 60 detik (*intentional exit*), atau menurunkan durasi konsumsi.

---

## 2. Fitur-Fitur Utama

* **Floating Island (Hitungan Video Mengambang)**:
  Overlay mengambang non-intrusif dan non-touchable di area notification bar yang menghitung estimasi jumlah konten video yang telah digulir saat membuka aplikasi sosial media (Instagram, YouTube, TikTok). Pada milestone tertentu (misal 20, 40, 60 video), pulau ini menampilkan pesan jeda singkat.
* **Beranda Berisi Wawasan Komprehensif**:
  * **Ringkasan Harian (Daily Summary)**: Total perkiraan video digulir, frekuensi membuka aplikasi (*social opens*), dan waktu pemakaian dibanding hari sebelumnya.
  * **Tren Frekuensi Membuka Aplikasi (1 Hari, 1 Minggu, 1 Bulan)**: Menampilkan frekuensi pembukaan media sosial secara periodik beserta rasio perubahan (*delta ratio*).
  * **Tren 7 Hari (Weekly Trend Chart)**: Grafik batang visual screen time harian dibandingkan garis target yang ditentukan pengguna.
  * **Top 3 Aplikasi Sosial**: Waktu pakai dan frekuensi membuka aplikasi sosial media teratas.
  * **Kemenangan Hari Ini (Today's Wins)**: Penghargaan otomatis berbasis aturan lokal ketika pengguna berhasil menurunkan screen time, mengurangi frekuensi buka, atau tetap di bawah target harian.
* **AI Penasihat Digital (ARIA AI Companion)**:
  * Widget kartu dinamis di beranda yang memberikan saran, apresiasi, atau pertanyaan reflektif berdasarkan perbandingan tren penggunaan.
  * Fitur **Ngobrol Langsung (`/beranda/ngobrol`)** untuk dialog pendampingan reflektif tanpa penghakiman.
  * Opsi pengingat proaktif terjadwal yang dikirimkan ke perangkat pengguna.
* **Perjalanan & Gamifikasi (Halaman Pencapaian / Level Journey)**:
  * Pelacakan progres kebiasaan dalam 5 level bertingkat: *Self-control* (kembali dalam 60 detik), *Menjaga batas* (sesuai target), *Hari lebih ringan* (penurunan durasi ≥ 10 menit), *Keluar dengan sadar*, dan *Menyelesaikan jeda napas*.
* **Refleksi & Tes Fokus Spontan (Spot Check / Check-in Singkat)**:
  * Tes berkala (default mingguan) berisi 5 pertanyaan: evaluasi perasaan (*wellbeing rating*), pertanyaan reflektif kontekstual berdasarkan tren, mini latihan fokus visual, dan uji memori kerja.
  * Riwayat ditampilkan dalam bentuk visual grafik batang tren perasaan pribadi.
* **Pengelola Aplikasi & Batas Waktu (App Manager)**:
  * Penyetelan kuota harian per aplikasi dengan opsi penegakan (*enforcement*): Pantau saja (*Track Only*), Peringatan notifikasi (*Warn*), Jeda napas reflektif (*Breathe* / 15 detik), atau Kembali ke Beranda (*Block*).
  * Pengingat saat aplikasi baru dibuka (*Remind on open* / jeda 8 detik).

---

## 3. Cara Menggunakan ARIA

```
[ Instal & Buka ARIA ] ──> [ Berikan Izin di Pengaturan ] ──> [ Tetapkan Target Waktu ]
          │                                                               │
          ▼                                                               ▼
[ Buka Sosial Media ] ◄──────────────────────────────────────── [ Pantau di Beranda ]
   ├── Floating Island menghitung video                                   │
   ├── Prompt reflektif saat membuka (opsional)                           ├── Today's Wins & Tren
   └── Jeda napas saat kuota tercapai                                     ├── Konsultasi AI (Ngobrol)
                                                                          └── Tes Fokus Spontan
```

1. **Inisialisasi & Pengaturan Izin**:
   * Buka menu **Pengaturan (`/pengaturan`) > Izin Sistem**.
   * Aktifkan izin wajib: **Akses Penggunaan (Usage Access)**, **Layanan Aksesibilitas (Pelacak Scroll ARIA)**, dan **Tampilkan di Atas Aplikasi Lain (Overlay)**.
   * Aktifkan izin pendukung: **Notifikasi** (untuk pengingat jeda & check-in) dan **Pengecualian Hemat Baterai** (agar alarm refleksi tidak tertidur oleh OS).
2. **Menentukan Batas Aplikasi**:
   * Masuk ke tab **Kelola (`/kelola`)**.
   * Pilih aplikasi sosial media yang terinstal (Instagram, YouTube, TikTok, dll.).
   * Tentukan kuota harian (misal: 45 menit) dan mode penegakan (disarankan: *Jeda napas*).
   * Aktifkan *Pengingat saat dibuka* jika ingin friksi sadar 8 detik sebelum mulai berselancar.
3. **Berselancar dengan Sadar**:
   * Saat membuka aplikasi target, *Floating Island* akan otomatis muncul di bagian tengah atas notification bar.
   * Angka akan bertambah sesuai scroll yang dilakukan. Jika mencapai angka milestone (misal 20 video), pulau akan menampilkan pengingat lembut.
   * Jika kuota harian tercapai, kartu intervensi jeda napas akan muncul selama 15 detik untuk memberi Anda waktu menimbang apakah ingin menyudahi sesi.
4. **Melihat Refleksi & Merayakan Kemajuan**:
   * Buka tab **Beranda (`/beranda`)** untuk melihat ringkasan harian, kemenangan hari ini (*Today's Wins*), dan pesan harian dari AI ARIA.
   * Ketuk ikon piala di kiri atas untuk membuka **Pencapaian (`/pencapaian`)** dan melihat kenaikan level perjalanan sadar Anda.
   * Saat notifikasi refleksi mingguan masuk, ketuk notifikasi untuk mengisi **Check-in Singkat (`/refleksi`)** dan uji fokus Anda.

---

## 4. Keamanan, Privasi, & Pemrosesan Data Aman

ARIA dibangun dengan prinsip **Privacy by Design** dan **Local-First Processing**:

| Komponen | Mekanisme Perlindungan Privasi |
| :--- | :--- |
| **Pelacakan Scroll (Accessibility Service)** | **Zero Text & Content Scraping**. Layanan aksesibilitas ARIA disetel khusus (`importantForAccessibility = NO`) dan hanya membaca metadata gerakan (`TYPE_VIEW_SCROLLED`, scroll delta, pager index) pada aplikasi target terpilih. ARIA **tidak pernah** membaca teks layar, teks postingan, komentar, username, sandi, atau konten visual. |
| **Statistik Penggunaan (UsageStats)** | ARIA hanya membaca durasi foreground agregat dan jumlah event activity resumed. Data mentah OS tidak pernah diunggah ke internet; ARIA mengagregasikannya ke dalam snapshot harian yang disimpan secara lokal di `SharedPreferences` selama maksimal 35 hari. |
| **Jawaban Refleksi & Tes Fokus** | Disimpan 100% secara lokal di dalam memori internal perangkat. Tidak ada transmisi ke server cloud mana pun. |
| **Penyimpanan Kredensial di Klien** | Menggunakan `AriaSecureStore` berbasis **Android Keystore hardware-backed encryption (AES-GCM 128-bit)** untuk menyimpan token sesi otentikasi anonim. Tidak ada plaintext token yang tersimpan di disk. |
| **Arsitektur AI Zero-Trust Gateway** | Aplikasi mobile **tidak pernah menyimpan provider API Key** (OpenAI/DeepSeek/dsb). Semua panggilan AI disalurkan melalui Supabase Edge Function (`aria-chat`) terotentikasi JWT anonim. API key disimpan di Supabase Database Vault. Konteks yang dikirim ke AI hanyalah teks pesan chat dan ringkasan agregat habit (contoh: *"Rata-rata 45 menit/hari, tren menurun"*), tanpa rincian aplikasi atau identitas pengguna (*No PII*). |

---

## 5. Daftar Izin Sistem (Permissions) & Justifikasi

Aplikasi meminta izin spesifik berikut di Android:

| Izin Android | Tingkat | Alasan & Fungsi |
| :--- | :--- | :--- |
| `android.permission.PACKAGE_USAGE_STATS` | *Special Access* | Membaca total waktu pemakaian harian dan frekuensi membuka aplikasi sosial media melalui Android `UsageStatsManager`. |
| `android.permission.SYSTEM_ALERT_WINDOW` | *Special Access* | Menampilkan *Floating Island* (indikator jumlah scroll) dan kartu jeda napas (*intervention pause card*) mengambang di atas aplikasi target. |
| `android.permission.BIND_ACCESSIBILITY_SERVICE` | *Accessibility* | Mendeteksi event gulir layar (`TYPE_VIEW_SCROLLED`) di aplikasi media sosial yang didukung guna memperkirakan jumlah konten yang telah di-scroll. |
| `android.permission.POST_NOTIFICATIONS` | *Runtime (Android 13+)* | Mengirimkan notifikasi peringatan kuota aplikasi, pengingat refleksi berkala (Spot Check), dan pesan pendampingan proaktif. |
| `android.permission.RECEIVE_BOOT_COMPLETED` | *Normal* | Menjadwalkan ulang alarm pengingat refleksi mingguan dan pengingat proaktif setelah perangkat di-restart (*reboot*). |
| `android.permission.INTERNET` | *Normal* | Menghubungkan aplikasi ke Supabase Edge Function untuk fitur dialog AI Companion (jika pengguna mengaktifkan fitur AI). |
| `android.permission.REQUEST_IGNORE_BATTERY_OPTIMIZATIONS` | *Special Access* | Menjaga agar penjadwalan alarm refleksi dan layanan pengingat latar belakang tidak dibunuh secara agresif oleh sistem manajemen daya perangkat. |

---

## 6. Struktur Arsitektur Aplikasi

ARIA menerapkan arsitektur gabungan **Clean Architecture** dan **Feature-First modularity**, dikombinasikan dengan **Flutter Riverpod** untuk reaktivitas state dan **GoRouter** untuk deklarasi navigasi.

```
ARIA/
├── android/app/src/main/kotlin/com/aria/aria/
│   ├── MainActivity.kt                      # Bridge MethodChannel untuk stats, permissions, app list, & alarms
│   ├── AriaScrollAccessibilityService.kt    # Service background pengukur scroll, Floating Island, & overlay jeda
│   ├── SpotCheckAlarm.kt                    # AlarmManager & BroadcastReceiver untuk refleksi spontan/berkala
│   └── AriaSecureStore.kt                   # Enkripsi sesi lokal berbasis Android Keystore (AES-GCM)
│
├── lib/
│   ├── core/                                # Pondasi lintas fitur
│   │   ├── companion/                       # Definisi kepribadian & tone ARIA (gentle, firm, playful, scriptural)
│   │   ├── config/                          # AppConfig & FeatureFlags
│   │   ├── constants/                       # Konstanta aset, kunci preferensi lokal (PrefKeys)
│   │   ├── di/                              # Root Riverpod provider & observer
│   │   ├── error/                           # Abstraksi Result, Failure, & Exception
│   │   ├── motion/                          # Haptics, motion tokens, micro-interactions
│   │   ├── presentation/                    # Reusable atom UI (AriaScaffold, AriaCard, AriaBarChart, dsb.)
│   │   ├── routing/                         # GoRouter konfigurasi & ShellScaffold beranda
│   │   └── theme/                           # Sistem warna semantik (AppColors), tipografi, & tema terang/gelap
│   │
│   ├── features/                            # Modul fungsional berorientasi Clean Architecture
│   │   ├── home/                            # Fitur Beranda & AI Companion
│   │   │   ├── domain/                      # Entities (DailySummary, AriaMessage, PeriodStats), Repositories, Use Cases
│   │   │   ├── data/                        # DTOs, Mappers, Datasources (UsageTrackingHomeDatasource), AriaLlmService
│   │   │   └── presentation/                # UI widgets (DailySummaryCard, UsagePeriodCard, SevenDayTrendCard, NgobrolSheet)
│   │   │
│   │   ├── app_manager/                     # Fitur Pengelola Batas Aplikasi (App Manager)
│   │   │   ├── domain/                      # Entitas AppLimit, LimitEnforcement (trackOnly, warn, breathe, block)
│   │   │   ├── data/                        # Repositories & UsageStatsAndroidSource
│   │   │   └── presentation/                # AppManagerPage, LimitEditorSheet, AppUsageRing
│   │   │
│   │   ├── achievements/                    # Fitur Level & Gamifikasi Perjalanan
│   │   │   ├── data/                        # AchievementProgressStore (menghitung progres 5 kategori)
│   │   │   └── presentation/                # AchievementsPage (Visual level, lencana, & progress bar)
│   │   │
│   │   ├── check_ins/                       # Fitur Refleksi & Tes Fokus Spontan (Spot Check)
│   │   │   ├── domain/                      # SpotCheckModels & SpotCheckQuestionBank (refleksi, fokus, memori)
│   │   │   ├── data/                        # SpotCheckStore & SpotCheckNotifications
│   │   │   └── presentation/                # SpotCheckPage (riwayat tren perasaan) & SpotCheckTestPage (antarmuka tes)
│   │   │
│   │   ├── usage_tracking/                  # Domain logika pelacakan & snapshot harian
│   │   │   ├── domain/                      # SocialApps catalogue, TodaysWinGenerator, ScrollSessionTracker
│   │   │   ├── data/                        # DailyUsageStore (retensi 35 hari snapshot lokal)
│   │   │   └── presentation/                # VideoSessionIsland (widget in-app tracking)
│   │   │
│   │   └── settings/                        # Pengaturan sistem, izin, & preferensi AI
│   │       ├── domain/                      # PermissionStatus, AppSettings
│   │       ├── data/                        # PermissionAndroidSource
│   │       └── presentation/                # SettingsPage, AriaAiSettingsPage
│   │
│   ├── app.dart                             # Widget akar aplikasi (AriaApp)
│   ├── bootstrap.dart                       # Inisialisasi asynchronous awal & splash fallback
│   └── main.dart                            # Titik masuk Flutter (entry point)
│
└── supabase/                                # Infrastruktur Serverless Cloud Gateway
    ├── functions/aria-chat/index.ts         # Edge function otentikasi JWT, rate limiting, & proxy ke LLM
    └── migrations/                          # Skrip SQL untuk schema privat & integrasi Vault
```

---

## 7. Checklist Analisis Implementasi Fitur

Tabel berikut menganalisis kesesuaian antara ikhtisar fitur yang direncanakan dengan implementasi riil pada repositori:

| Spesifikasi Fitur | Status | Detail Implementasi & Catatan Kode |
| :--- | :---: | :--- |
| **Floating Island Jumlah Scroll**<br>Muncul saat membuka sosmed, posisi mengapung tepat di tengah notification bar. | ✅ **Sudah** | Diimplementasikan di `AriaScrollAccessibilityService.kt` (`ensureIsland()` & `showIsland()`). Menggunakan overlay `WindowManager` dengan `Gravity.TOP or Gravity.CENTER_HORIZONTAL; y = 6dp`, non-touchable, menampilkan counter `${session}x` dan pesan reflektif di milestone tertentu. Didukung juga widget in-app `VideoSessionIsland.dart`. |
| **Tren Frekuensi Membuka Sosmed (Beranda)**<br>Frekuensi membuka sosmed dalam kurun waktu 1 hari, 1 minggu, dan 1 bulan. | ✅ **Sudah** | Diimplementasikan di `UsagePeriodCard.dart` yang didukung `UsageTrackingHomeDatasource.dart` (`fetchPeriodBreakdown()`). Menampilkan tab tersegmentasi Harian, Mingguan, dan Bulanan dengan hitungan frekuensi pembukaan (*social opens*) dan perbandingan tren. |
| **UI AI Penasihat Dinamis (Beranda)**<br>Pesan saran, apresiasi, refleksi berbasis perbandingan hari sebelumnya vs saat ini. | ✅ **Sudah** | Diimplementasikan di `AriaMessageCard.dart` dan `AriaCompanionRepositoryImpl.dart`. Memiliki fallback aturan lokal (membandingkan perbedaan waktu layar dengan hari kemarin untuk apresiasi/refleksi) serta integrasi LLM dinamis via `AriaLlmService.dart` yang mengirimkan konteks arah tren. |
| **Halaman Level/Journey & Gamifikasi**<br>Menunjukkan perjalanan/usaha mengurangi sosmed dengan rewarding saat frekuensi/durasi menurun. | ✅ **Sudah** | Diimplementasikan di `AchievementsPage.dart` (`/pencapaian`, dapat diakses dari header Beranda). Memiliki 5 kategori pencapaian (masing-masing 5 level) termasuk *"Hari lebih ringan"* yang memberi reward saat screen time berkurang ≥ 10 menit dari hari sebelumnya. Di beranda juga didukung kartu `TodaysWinsCard.dart`. |
| **Halaman Tes Self-Rating Fokus Spontan**<br>Tes spontan berupa pertanyaan atau tes fokus, hasil ditampilkan sebagai grafik/tren pribadi. | ✅ **Sudah** | Diimplementasikan di `SpotCheckPage.dart` (`/refleksi`) dan `SpotCheckTestPage.dart` (`/refleksi/tes`). Menguji wellbeing, refleksi, fokus visual (menghitung simbol/angka genap), dan ingatan kata. Hasil tersimpan lokal dan dirender dalam grafik tren batang `_SelfRatingTrend`. Dijadwalkan otomatis melalui `SpotCheckAlarm.kt`. |
| **AI Konsultan & Nasihat Proaktif**<br>Konsultasi proaktif berdasarkan kebiasaan pengguna. | ✅ **Sudah** | Tersedia dialog interaktif di `CompanionChatPage.dart` (`/beranda/ngobrol`) dan sistem penjadwalan pesan proaktif harian via `AriaProactiveAlarm` & `AriaProactiveReceiver`. |
| **Sistem Gamifikasi/Rewarding**<br>Menghargai usaha pengguna dalam mengurangi konsumsi. | ✅ **Sudah** | Mesin aturan lokal `TodaysWinGenerator.dart` mendeteksi kemenangan harian secara otomatis, dan `AchievementProgressStore.dart` mengakumulasikan poin untuk membuka level dan lencana baru. |
| **Tes Mingguan Spontan untuk Self-Rating Fokus** | ✅ **Sudah** | Dikelola oleh alarm latar belakang `SpotCheckAlarm.kt` dengan interval default 7 hari (mingguan) yang memicu notifikasi acak menuju rute `/refleksi`. |

---

## 8. Panduan Menjalankan & Membangun Aplikasi

### Prasyarat
* Flutter SDK (3.24+ disarankan)
* Android SDK (API Level 26 ke atas; compileSdkVersion 34+)
* Perangkat fisik Android (disarankan untuk menguji *UsageStats*, *Accessibility Service*, dan *System Alert Window*)

### Langkah Instalasi
1. Gandakan repositori dan masuk ke direktori:
   ```bash
   git clone <repo_url>
   cd ARIA
   ```
2. Pasang dependensi Flutter:
   ```bash
   flutter pub get
   ```
3. Konfigurasi Environment (Opsional untuk Fitur AI Companion):
   Salin `.env.example` ke `.env` dan masukkan kredensial Supabase Anda:
   ```bash
   cp .env.example .env
   ```
4. Jalankan aplikasi pada perangkat Android:
   ```bash
   flutter run
   ```
5. Untuk kompilasi APK rilis dengan dart-define:
   ```bash
   flutter build apk --release --dart-define-from-file=.env
   ```
