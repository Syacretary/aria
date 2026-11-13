import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/providers.dart';
import '../data/spot_check_store.dart';
import '../domain/spot_check_models.dart';

final spotCheckStoreProvider = Provider<SpotCheckStore>(
  (ref) => SpotCheckStore(ref.watch(sharedPreferencesProvider)),
);

class SpotCheckOverview {
  const SpotCheckOverview({
    required this.preferences,
    required this.sessions,
    required this.trend,
  });

  final SpotCheckPreferences preferences;
  final List<SpotCheckSession> sessions;
  final UsageTrend trend;
}

final spotCheckOverviewProvider = FutureProvider<SpotCheckOverview>((
  ref,
) async {
  final store = ref.watch(spotCheckStoreProvider);
  final values = await Future.wait<Object>([
    store.readSessions(),
    store.readTrend(),
  ]);
  return SpotCheckOverview(
    preferences: store.readPreferences(),
    sessions: values[0] as List<SpotCheckSession>,
    trend: values[1] as UsageTrend,
  );
});
