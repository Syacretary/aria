import '../../../../core/error/result.dart';
import '../entities/app_limit.dart';
import '../entities/managed_app.dart';

/// Read/write contract for the apps App Manager governs.
abstract interface class AppManagerRepository {
  /// Installed apps with usage and any configured limit.
  Future<Result<List<ManagedApp>>> getManagedApps();

  /// A single app's row, refreshed.
  Future<Result<ManagedApp>> getApp(String packageName);

  /// Creates or replaces the limit for [packageName].
  Future<Result<void>> setLimit(AppLimit limit);

  /// Removes the limit entirely.
  Future<Result<void>> removeLimit(String packageName);

  /// Turns an existing limit on or off without discarding its configuration.
  Future<Result<void>> setLimitEnabled(String packageName, bool enabled);
}
