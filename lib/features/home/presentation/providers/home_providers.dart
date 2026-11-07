import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/config/feature_flags.dart';
import '../../../../core/di/providers.dart';
import '../../data/datasources/home_datasource.dart';
import '../../data/datasources/home_local_datasource.dart';
import '../../data/datasources/home_mock_datasource.dart';
import '../../data/datasources/home_remote_datasource.dart';
import '../../data/repositories/home_repository_impl.dart';
import '../../domain/entities/aria_message.dart';
import '../../domain/entities/daily_summary.dart';
import '../../domain/entities/period_stats.dart';
import '../../domain/entities/top_app_usage.dart';
import '../../domain/entities/trend_point.dart';
import '../../domain/entities/win_entry.dart';
import '../../domain/repositories/aria_companion_repository.dart';
import '../../domain/repositories/home_repository.dart';
import '../../domain/usecases/get_aria_message.dart';
import '../../domain/usecases/get_daily_summary.dart';
import '../../domain/usecases/get_period_breakdown.dart';
import '../../domain/usecases/get_todays_wins.dart';
import '../../domain/usecases/get_top_apps.dart';
import '../../domain/usecases/get_weekly_trend.dart';

// -----------------------------------------------------------------------------
// Data sources
// -----------------------------------------------------------------------------

/// Chooses the datasource implementation.
///
/// This is the single switch that moves Beranda from mock to real data. When
/// the Android usage-stats source lands, add it here — nothing else changes.
final homeDatasourceProvider = Provider<HomeDatasource>((ref) {
  if (FeatureFlags.useMockData) {
    return HomeMockDatasource(now: ref.watch(clockProvider)());
  }
  return HomeRemoteDatasource(ref.watch(apiClientProvider));
});

/// Local cache, available to whichever datasource is active.
final homeLocalDatasourceProvider = Provider<HomeLocalDatasource>(
  (ref) => HomeLocalDatasource(ref.watch(sharedPreferencesProvider)),
);

// -----------------------------------------------------------------------------
// Repositories
// -----------------------------------------------------------------------------

final homeRepositoryProvider = Provider<HomeRepository>(
  (ref) => HomeRepositoryImpl(ref.watch(homeDatasourceProvider)),
);

final ariaCompanionRepositoryProvider = Provider<AriaCompanionRepository>(
  (ref) => AriaCompanionRepositoryImpl(ref.watch(homeDatasourceProvider)),
);

// -----------------------------------------------------------------------------
// Use cases
// -----------------------------------------------------------------------------

final getDailySummaryProvider = Provider<GetDailySummary>(
  (ref) => GetDailySummary(ref.watch(homeRepositoryProvider)),
);

final getPeriodBreakdownProvider = Provider<GetPeriodBreakdown>(
  (ref) => GetPeriodBreakdown(ref.watch(homeRepositoryProvider)),
);

final getWeeklyTrendProvider = Provider<GetWeeklyTrend>(
  (ref) => GetWeeklyTrend(ref.watch(homeRepositoryProvider)),
);

final getTopAppsProvider = Provider<GetTopApps>(
  (ref) => GetTopApps(ref.watch(homeRepositoryProvider)),
);

final getTodaysWinsProvider = Provider<GetTodaysWins>(
  (ref) => GetTodaysWins(ref.watch(homeRepositoryProvider)),
);

final getAriaMessageProvider = Provider<GetAriaMessage>(
  (ref) => GetAriaMessage(ref.watch(ariaCompanionRepositoryProvider)),
);

// -----------------------------------------------------------------------------
// Card state
// -----------------------------------------------------------------------------

/// Each card owns its own async state.
///
/// Deliberately not one giant "home state": a failure in the trend chart must
/// not blank the wins list, and each card can refresh on its own.
/// Refresh semantics are `ref.invalidate(provider)`.
final dailySummaryProvider = FutureProvider<DailySummary>((ref) async {
  final result = await ref.watch(getDailySummaryProvider)();
  return result.when(ok: (value) => value, err: (failure) => throw failure);
});

final periodBreakdownProvider = FutureProvider<PeriodBreakdown>((ref) async {
  final result = await ref.watch(getPeriodBreakdownProvider)();
  return result.when(ok: (value) => value, err: (failure) => throw failure);
});

final weeklyTrendProvider = FutureProvider<List<TrendPoint>>((ref) async {
  final result = await ref.watch(getWeeklyTrendProvider)();
  return result.when(ok: (value) => value, err: (failure) => throw failure);
});

final topAppsProvider = FutureProvider<List<TopAppUsage>>((ref) async {
  final result = await ref.watch(getTopAppsProvider)();
  return result.when(ok: (value) => value, err: (failure) => throw failure);
});

final todaysWinsProvider = FutureProvider<List<WinEntry>>((ref) async {
  final result = await ref.watch(getTodaysWinsProvider)();
  return result.when(ok: (value) => value, err: (failure) => throw failure);
});

final ariaMessageProvider = FutureProvider<AriaMessage>((ref) async {
  final result = await ref.watch(getAriaMessageProvider)();
  return result.when(ok: (value) => value, err: (failure) => throw failure);
});
