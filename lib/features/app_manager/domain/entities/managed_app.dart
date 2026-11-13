import 'dart:typed_data';

import 'app_limit.dart';

/// An installed app that App Manager can govern.
///
/// Combines what the system knows (name, package, today's usage) with what the
/// user configured ([limit]). This is the single row model the UI renders.
class ManagedApp {
  const ManagedApp({
    required this.packageName,
    required this.appName,
    required this.usedToday,
    required this.sessionCount,
    this.limit,
    this.category = AppCategory.other,
    this.iconPng,
  });

  final String packageName;
  final String appName;

  /// Screen time accumulated today.
  final Duration usedToday;
  final int sessionCount;

  /// Null when no limit is configured for this app.
  final AppLimit? limit;

  final AppCategory category;

  /// Local launcher icon encoded as PNG, when provided by Android.
  final Uint8List? iconPng;

  bool get hasLimit => limit != null;

  bool get isLimitActive => limit?.enabled ?? false;

  /// Quota, or null when unlimited.
  Duration? get quota => limit?.dailyQuota;

  /// Time left before the limit is hit. Null when unlimited; zero when spent.
  Duration? get remaining {
    final q = quota;
    if (q == null) return null;
    final left = q - usedToday;
    return left.isNegative ? Duration.zero : left;
  }

  /// Usage as a fraction of the quota. Null when unlimited.
  ///
  /// Deliberately allowed above 1.0 when the user overshoots, so the UI can
  /// show the overflow rather than silently clamping.
  double? get fractionOfQuota {
    final q = quota;
    if (q == null || q.inSeconds <= 0) return null;
    return usedToday.inSeconds / q.inSeconds;
  }

  bool get isOverQuota {
    final f = fractionOfQuota;
    return f != null && f > 1.0;
  }

  /// Whether usage has crossed the "nearly there" threshold (80%).
  bool get isNearQuota {
    final f = fractionOfQuota;
    return f != null && f >= 0.8 && f <= 1.0;
  }

  ManagedApp copyWith({
    Duration? usedToday,
    int? sessionCount,
    AppLimit? limit,
    bool clearLimit = false,
  }) {
    return ManagedApp(
      packageName: packageName,
      appName: appName,
      usedToday: usedToday ?? this.usedToday,
      sessionCount: sessionCount ?? this.sessionCount,
      limit: clearLimit ? null : (limit ?? this.limit),
      category: category,
      iconPng: iconPng,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ManagedApp &&
          runtimeType == other.runtimeType &&
          packageName == other.packageName &&
          appName == other.appName &&
          usedToday == other.usedToday &&
          sessionCount == other.sessionCount &&
          limit == other.limit &&
          category == other.category;

  @override
  int get hashCode => Object.hash(
    packageName,
    appName,
    usedToday,
    sessionCount,
    limit,
    category,
  );
}

/// Grouping used for the future "limit per category" improvisation and for
/// sensible icon fallbacks.
enum AppCategory { social, video, game, productivity, messaging, other }

extension AppCategoryX on AppCategory {
  String get label => switch (this) {
    AppCategory.social => 'Sosial media',
    AppCategory.video => 'Video',
    AppCategory.game => 'Game',
    AppCategory.productivity => 'Produktivitas',
    AppCategory.messaging => 'Pesan',
    AppCategory.other => 'Lainnya',
  };
}
