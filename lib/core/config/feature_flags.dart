/// Compile-time-ish switches for swapping implementations.
///
/// Iteration 1 runs entirely on mock data: [useMockData] is `true`, so the
/// Riverpod wiring in each feature resolves its mock data source. To move a
/// feature onto real Android APIs, flip the relevant flag (or override the
/// provider in `bootstrap.dart`) — no UI code changes.
abstract final class FeatureFlags {
  /// When true, all repositories read from mock data sources.
  /// Release builds read the device's Usage Access data on Android. Tests can
  /// still override the source provider with [UsageStatsMockSource].
  static const bool useMockData = false;

  /// Whether the ARIA companion chat is available. The sheet itself is a stub
  /// in iteration 1.
  static const bool companionChatEnabled = true;

  /// Whether app limit enforcement (blocking/warnings) is active. Off until
  /// the Android `UsageStatsManager` integration lands.
  static const bool limitEnforcementEnabled = false;
}
