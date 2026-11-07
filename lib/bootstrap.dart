import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/config/app_config.dart';
import 'core/di/provider_observer.dart';
import 'core/di/providers.dart';

/// Runs one-time async setup and builds the root [ProviderScope].
///
/// This is the single place where real implementations are swapped in. In
/// iteration 1 that means seeding [sharedPreferencesProvider] and loading the
/// `id_ID` date symbols; when the Android usage-stats source lands, its
/// provider overrides go here too — features never change.
Future<Widget> bootstrapApp(Widget app) async {
  WidgetsFlutterBinding.ensureInitialized();

  // `intl` throws at format time until the locale's symbols are loaded, so this
  // must happen before the first frame that renders a date.
  await initializeDateFormatting(AppConfig.locale);

  final prefs = await SharedPreferences.getInstance();

  final container = ProviderContainer(
    observers: const [AriaProviderObserver()],
    overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
  );

  return UncontrolledProviderScope(container: container, child: app);
}
