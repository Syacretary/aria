import '../../../../core/companion/aria_tone.dart';

/// Everything the Settings screen reads and writes.
///
/// One aggregate rather than a provider per toggle: settings are a small,
/// coherent set, and loading them together keeps the screen from flickering as
/// each row resolves independently.
class AppSettings {
  const AppSettings({
    required this.tone,
    required this.dailyTarget,
    required this.hapticsEnabled,
    required this.quietHoursEnabled,
    required this.quietHoursFrom,
    required this.quietHoursUntil,
    required this.maskAppNames,
  });

  /// Voice ARIA uses when speaking on Beranda and in chat.
  final AriaTone tone;

  /// The user's own screentime target, used as the reference line in charts.
  final Duration dailyTarget;

  /// Whether taps produce haptic feedback.
  ///
  /// Honoured by the motion layer — when false, `AriaTap` uses the silent
  /// haptic variants.
  final bool hapticsEnabled;

  /// Whether ARIA stays quiet during a window of the day.
  final bool quietHoursEnabled;
  final Duration quietHoursFrom;
  final Duration quietHoursUntil;

  /// Whether app names are aliased on Beranda (privacy in shared spaces).
  final bool maskAppNames;

  /// Sensible defaults for a first launch: gentle voice, 3-hour target,
  /// haptics on, no quiet hours, real app names.
  static const AppSettings defaults = AppSettings(
    tone: AriaTone.gentle,
    dailyTarget: Duration(hours: 3),
    hapticsEnabled: true,
    quietHoursEnabled: false,
    quietHoursFrom: Duration(hours: 22),
    quietHoursUntil: Duration(hours: 6),
    maskAppNames: false,
  );

  AppSettings copyWith({
    AriaTone? tone,
    Duration? dailyTarget,
    bool? hapticsEnabled,
    bool? quietHoursEnabled,
    Duration? quietHoursFrom,
    Duration? quietHoursUntil,
    bool? maskAppNames,
  }) {
    return AppSettings(
      tone: tone ?? this.tone,
      dailyTarget: dailyTarget ?? this.dailyTarget,
      hapticsEnabled: hapticsEnabled ?? this.hapticsEnabled,
      quietHoursEnabled: quietHoursEnabled ?? this.quietHoursEnabled,
      quietHoursFrom: quietHoursFrom ?? this.quietHoursFrom,
      quietHoursUntil: quietHoursUntil ?? this.quietHoursUntil,
      maskAppNames: maskAppNames ?? this.maskAppNames,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppSettings &&
          runtimeType == other.runtimeType &&
          tone == other.tone &&
          dailyTarget == other.dailyTarget &&
          hapticsEnabled == other.hapticsEnabled &&
          quietHoursEnabled == other.quietHoursEnabled &&
          quietHoursFrom == other.quietHoursFrom &&
          quietHoursUntil == other.quietHoursUntil &&
          maskAppNames == other.maskAppNames;

  @override
  int get hashCode => Object.hash(
    tone,
    dailyTarget,
    hapticsEnabled,
    quietHoursEnabled,
    quietHoursFrom,
    quietHoursUntil,
    maskAppNames,
  );
}
