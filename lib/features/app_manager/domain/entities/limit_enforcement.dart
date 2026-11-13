/// What happens when an app's daily limit is reached.
///
/// The Android accessibility service applies the selected response when the
/// daily usage quota is reached.
enum LimitEnforcement {
  /// ARIA sends a nudge but does not intervene.
  warn,

  /// The app is blocked until tomorrow.
  block,

  /// A short breathing-pause overlay appears instead of a hard block.
  breathe,

  /// The limit is tracked but never enforced — a purely reflective setting.
  trackOnly,
}

extension LimitEnforcementX on LimitEnforcement {
  String get label => switch (this) {
    LimitEnforcement.warn => 'Peringatkan saja',
    LimitEnforcement.block => 'Blokir aplikasi',
    LimitEnforcement.breathe => 'Jeda bernapas',
    LimitEnforcement.trackOnly => 'Catat saja',
  };

  String get description => switch (this) {
    LimitEnforcement.warn =>
      'ARIA mengirim pengingat lembut saat batas terpakai.',
    LimitEnforcement.block => 'Aplikasi tidak bisa dibuka sampai besok.',
    LimitEnforcement.breathe => 'Muncul jeda 15 detik untuk menenangkan diri.',
    LimitEnforcement.trackOnly => 'Tidak ada tindakan; hanya untuk refleksi.',
  };
}
