/// Permission ARIA may need from the operating system.
enum AppPermission {
  /// `PACKAGE_USAGE_STATS` — reading screen time and app launches.
  usageAccess,

  /// Observes only `TYPE_VIEW_SCROLLED` events in supported short-video apps.
  scrollDetection,

  /// Posting the "limit reached" notification.
  notifications,

  /// Drawing the breathing-pause overlay above other apps.
  overlay,

  /// Exemption from battery optimisation, so limits fire reliably.
  batteryExemption,
}

/// Grant state of a permission.
enum PermissionState {
  granted,
  denied,

  /// Permanently denied, or unavailable on this device/OS version.
  restricted,
}

extension AppPermissionX on AppPermission {
  String get label => switch (this) {
    AppPermission.usageAccess => 'Akses data pemakaian',
    AppPermission.scrollDetection => 'Deteksi scroll video',
    AppPermission.notifications => 'Notifikasi',
    AppPermission.overlay => 'Tampil di atas aplikasi lain',
    AppPermission.batteryExemption => 'Jalankan di latar belakang',
  };

  /// Why ARIA wants it — phrased as what the user gets, not what ARIA takes.
  String get rationale => switch (this) {
    AppPermission.usageAccess =>
      'Diperlukan untuk menghitung screentime dan jumlah buka aplikasi.',
    AppPermission.scrollDetection => 'Menghitung scroll di aplikasi video yang didukung, tanpa membaca isi layar atau pesan.',
    AppPermission.notifications =>
      'Agar ARIA bisa mengingatkan saat batas hampir tercapai.',
    AppPermission.overlay =>
      'Untuk menampilkan counter scroll kecil di atas aplikasi video yang didukung.',
    AppPermission.batteryExemption =>
      'Supaya batas tetap bekerja walau layar lama tidak dibuka.',
  };

  /// Whether the OS exposes a settings screen the user must visit manually.
  ///
  /// Usage access and battery exemption cannot be granted from a dialog, so the
  /// UI shows a "open settings" action instead of a request button.
  bool get requiresManualGrant => switch (this) {
    AppPermission.usageAccess => true,
    AppPermission.scrollDetection => true,
    AppPermission.batteryExemption => true,
    AppPermission.notifications => false,
    AppPermission.overlay => false,
  };

  bool get isRequired => this == AppPermission.usageAccess;
}

extension PermissionStateX on PermissionState {
  String get label => switch (this) {
    PermissionState.granted => 'Diizinkan',
    PermissionState.denied => 'Belum diizinkan',
    PermissionState.restricted => 'Tidak tersedia',
  };

  bool get isGranted => this == PermissionState.granted;
}
