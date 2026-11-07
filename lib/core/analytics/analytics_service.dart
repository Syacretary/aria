import 'package:flutter/foundation.dart';

/// Analytics boundary.
///
/// Iteration 1 logs to the console. A real implementation (Firebase, PostHog)
/// drops in behind this interface without touching feature code.
abstract interface class AnalyticsService {
  void logEvent(String name, {Map<String, Object?> parameters});

  void setUserProperty(String name, Object? value);
}

/// Debug implementation: prints events so you can verify tracking while
/// developing.
class ConsoleAnalyticsService implements AnalyticsService {
  const ConsoleAnalyticsService();

  @override
  void logEvent(String name, {Map<String, Object?> parameters = const {}}) {
    if (!kDebugMode) return;
    debugPrint('[aria:analytics] $name $parameters');
  }

  @override
  void setUserProperty(String name, Object? value) {
    if (!kDebugMode) return;
    debugPrint('[aria:analytics] user.$name = $value');
  }
}

/// Discards everything. Used in tests.
class NoopAnalyticsService implements AnalyticsService {
  const NoopAnalyticsService();

  @override
  void logEvent(String name, {Map<String, Object?> parameters = const {}}) {}

  @override
  void setUserProperty(String name, Object? value) {}
}
