# Pelacakan penggunaan ARIA

## Yang diukur saat ini

Di Android, setelah pengguna menyalakan **Usage Access** secara manual, ARIA
membaca `UsageStatsManager`: total waktu aplikasi berada di foreground dan
event aplikasi masuk foreground. Yang kedua ditampilkan sebagai **frekuensi
membuka aplikasi**, bukan jumlah tap/click; Android tidak mengekspos tap di
dalam aplikasi pihak ketiga. Ringkasan harian yang hanya berisi menit, jumlah
buka, dan jumlah video sesi disimpan lokal selama 35 hari. Ini membuat total
mingguan/bulanan tidak bergantung pada retensi event mentah Android.

## Floating island dan jumlah video

Tidak ada API yang aman dan universal untuk mengetahui bahwa sebuah video
TikTok/Reels/Shorts telah di-scroll. Usage Access tidak berisi event scroll.
Jangan mengklaim angka presisi dari waktu layar atau jumlah app-open.

Untuk feed yang dimiliki ARIA, pasang `ScrollSessionTracker` pada callback
visibilitas item (atau `PageController` untuk PageView), lalu letakkan
`VideoSessionIsland` pada `Stack`/`Overlay` halaman. Tracker menghitung item
baru hanya bila >=65% terlihat selama >=450 ms, sehingga drag kecil dan
bounce tidak dihitung. Simpan total sesi ketika halaman ditutup dan tambahkan
ke snapshot harian.

Untuk aplikasi pihak ketiga di Android, satu-satunya pendekatan teknis adalah
`AccessibilityService` dengan persetujuan eksplisit. Ia hanya boleh aktif
untuk paket yang dipilih pengguna, memproses `TYPE_VIEW_SCROLLED` secara lokal,
menyimpan counter agregat, menyediakan tombol pause permanen, dan tidak boleh
membaca/menyimpan teks, struktur view, akun, atau isi layar. Banyak aplikasi
tidak mengirim event yang cukup untuk memastikan sebuah video benar-benar
berubah; tampilkan hasil sebagai **perkiraan scroll**, lengkap dengan status
akurasi. System overlay di luar aplikasi juga memerlukan izin overlay eksplisit
dan kebijakan Play Store yang sesuai; gunakan hanya untuk counter yang
pengguna aktifkan, bukan sebagai mekanisme pengambilan data.

Di iOS, Screen Time/Family Controls membutuhkan entitlement dan otorisasi;
aksesnya berbasis kontrol/aktivitas yang dijaga privasi dan bukan stream scroll
feed. Karena itu floating island lintas aplikasi dan counter video presisi
tidak dapat dipenuhi secara setara di iOS.

## Kemenangan Hari Ini

`TodaysWinGenerator` adalah mesin aturan lokal, tanpa LLM. Ia memprioritaskan:

1. penurunan screen time minimal 10 menit dibanding kemarin;
2. penurunan frekuensi membuka aplikasi minimal dua kali;
3. tetap di bawah target menit yang dipilih pengguna.

Variasi teks dirotasi dari tanggal agar tidak monoton; aturan dan template
dapat ditambah tanpa menyentuh UI. Tidak ada kemenangan yang dibuat-buat bila
data belum cukup.
