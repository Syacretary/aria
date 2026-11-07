import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../analytics/analytics_service.dart';
import '../network/api_client.dart';

/// Infrastructure providers shared by every feature.
///
/// [sharedPreferencesProvider] is intentionally allowed to throw: it is
/// overridden in `bootstrap.dart` once `SharedPreferences.getInstance()`
/// resolves, so by the time any widget reads it the value is present.
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError(
    'sharedPreferencesProvider must be overridden in bootstrap.dart',
  );
});

/// Injectable clock. Tests override this to make "today" deterministic.
final clockProvider = Provider<DateTime Function()>((ref) => DateTime.now);

/// Analytics boundary. Console in debug, swap for the real SDK later.
final analyticsServiceProvider = Provider<AnalyticsService>(
  (ref) => const ConsoleAnalyticsService(),
);

/// Backend boundary. Stubbed until the companion service exists.
final apiClientProvider = Provider<ApiClient>((ref) => const StubApiClient());
