import 'package:flutter/services.dart';

/// Thin Android bridge for scheduling one local reminder at a time.
abstract final class SpotCheckNotifications {
  static const _channel = MethodChannel('com.aria.aria/check_ins');

  static Future<void> schedule(int intervalDays) =>
      _channel.invokeMethod<void>('schedule', {'intervalDays': intervalDays});

  static Future<void> cancel() => _channel.invokeMethod<void>('cancel');

  static Future<bool> notificationsGranted() async =>
      await _channel.invokeMethod<bool>('notificationsGranted') ?? false;
}
