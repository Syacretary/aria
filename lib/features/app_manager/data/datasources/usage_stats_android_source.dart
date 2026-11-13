import 'package:flutter/services.dart';

import '../../../../core/error/exceptions.dart';
import '../../domain/entities/installed_social_app.dart';
import '../../domain/entities/usage_session.dart';
import 'usage_stats_source.dart';

/// Android implementation backed by `UsageStatsManager`.
///
/// Requires the user-granted Usage Access special permission.
class UsageStatsAndroidSource implements UsageStatsSource {
  const UsageStatsAndroidSource();

  static const _channel = MethodChannel('com.aria.aria/usage_stats');
  static const _catalogueChannel = MethodChannel('com.aria.aria/app_catalogue');

  @override
  Future<List<InstalledSocialApp>> installedSocialApps() async {
    final values = await _catalogueChannel.invokeListMethod<dynamic>(
      'installedSocialApps',
    );
    return (values ?? const [])
        .map((value) {
          final map = Map<Object?, Object?>.from(value as Map);
          final icon = map['iconPng'];
          return InstalledSocialApp(
            packageName: map['packageName']! as String,
            appName: map['appName']! as String,
            iconPng: icon is Uint8List ? icon : null,
          );
        })
        .toList(growable: false);
  }

  @override
  Future<Map<String, Duration>> screenTimeByApp({required DateTime day}) async {
    final raw = await _invokeMap('screenTimeByApp', day);
    return raw.map(
      (key, value) =>
          MapEntry(key, Duration(milliseconds: (value as num).toInt())),
    );
  }

  @override
  Future<Map<String, int>> launchCounts({required DateTime day}) async {
    final raw = await _invokeMap('launchCounts', day);
    return raw.map((key, value) => MapEntry(key, (value as num).toInt()));
  }

  @override
  Future<List<UsageSession>> sessions({required DateTime day}) async {
    try {
      final values = await _channel.invokeListMethod<dynamic>(
        'sessions',
        _range(day),
      );
      return (values ?? const [])
          .map((value) {
            final map = Map<Object?, Object?>.from(value as Map);
            return UsageSession(
              packageName: map['packageName']! as String,
              start: DateTime.fromMillisecondsSinceEpoch(
                (map['start']! as num).toInt(),
              ),
              end: DateTime.fromMillisecondsSinceEpoch(
                (map['end']! as num).toInt(),
              ),
            );
          })
          .toList(growable: false);
    } on PlatformException catch (error) {
      throw PlatformExceptionWrapper(
        error.message ?? 'Usage Access belum aktif.',
      );
    }
  }

  @override
  Future<bool> hasUsageAccess() async =>
      await _channel.invokeMethod<bool>('hasUsageAccess') ?? false;

  @override
  Future<int> scrollCount({required DateTime day}) async {
    final value = await _channel.invokeMethod<num>('scrollCount', _range(day));
    return value?.toInt() ?? 0;
  }

  Future<Map<String, dynamic>> _invokeMap(String method, DateTime day) async {
    try {
      final value = await _channel.invokeMapMethod<String, dynamic>(
        method,
        _range(day),
      );
      return value ?? const {};
    } on PlatformException catch (error) {
      throw PlatformExceptionWrapper(
        error.message ?? 'Usage Access belum aktif.',
      );
    }
  }

  Map<String, int> _range(DateTime day) {
    final start = DateTime(day.year, day.month, day.day);
    return {
      'startMillis': start.millisecondsSinceEpoch,
      'endMillis': start.add(const Duration(days: 1)).millisecondsSinceEpoch,
    };
  }
}
