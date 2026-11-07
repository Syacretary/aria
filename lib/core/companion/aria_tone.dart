/// Voice ARIA uses when speaking to the user.
///
/// Lives in core rather than the home feature because it is a property of ARIA
/// herself: the home feed renders messages with it, Settings configures it, and
/// future features (weekly reports, reminders) will read it too.
enum AriaTone { gentle, firm, playful, scriptural }

extension AriaToneX on AriaTone {
  String get label => switch (this) {
    AriaTone.gentle => 'Lembut',
    AriaTone.firm => 'Tegas',
    AriaTone.playful => 'Humoris',
    AriaTone.scriptural => 'Alkitabiah',
  };

  String get description => switch (this) {
    AriaTone.gentle => 'Menemani tanpa menghakimi',
    AriaTone.firm => 'Langsung dan jelas',
    AriaTone.playful => 'Ringan dan jenaka',
    AriaTone.scriptural => 'Mengutip ayat sebagai penguat',
  };

  static AriaTone fromName(String? raw) => switch (raw) {
    'firm' => AriaTone.firm,
    'playful' => AriaTone.playful,
    'scriptural' => AriaTone.scriptural,
    _ => AriaTone.gentle,
  };
}
