/// All route paths in one place.
///
/// Features reference these constants rather than string literals, so a path
/// change is a single edit and typos become compile errors.
abstract final class Routes {
  // Top-level tabs (rendered inside the shell).
  static const String home = '/beranda';
  static const String appManager = '/kelola';
  static const String settings = '/pengaturan';
  static const String achievements = '/pencapaian';
  static const String spotCheck = '/refleksi';
  static const String spotCheckTest = '/refleksi/tes';
  static const String achievementsSegment = 'pencapaian';

  // Nested detail routes.
  static const String companionChat = '/beranda/ngobrol';
  static const String companionChatSegment = 'ngobrol';
  static const String settingsPermissions = '/pengaturan/izin';
  static const String settingsAppearance = '/pengaturan/tampilan';
  static const String settingsAriaAi = '/pengaturan/aria-ai';

  /// Segment names used by go_router's `StatefulShellRoute`.
  static const String homeSegment = 'beranda';
  static const String appManagerSegment = 'kelola';
  static const String settingsSegment = 'pengaturan';
}
