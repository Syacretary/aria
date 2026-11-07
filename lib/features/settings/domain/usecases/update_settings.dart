import '../../../../core/companion/aria_tone.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/error/result.dart';
import '../entities/app_settings.dart';
import '../repositories/settings_repository.dart';

/// Persists a partial settings update and returns the new aggregate.
class UpdateSettings {
  const UpdateSettings(this._repository);

  final SettingsRepository _repository;

  Future<Result<AppSettings>> call({
    AriaTone? tone,
    Duration? dailyTarget,
    bool? hapticsEnabled,
    bool? quietHoursEnabled,
    Duration? quietHoursFrom,
    Duration? quietHoursUntil,
    bool? maskAppNames,
  }) {
    if (dailyTarget != null && dailyTarget.inMinutes < _minimumTargetMinutes) {
      return Future.value(
        const Err(NotFoundFailure('Target harian minimal 15 menit.')),
      );
    }

    return _repository.updateSettings(
      tone: tone,
      dailyTarget: dailyTarget,
      hapticsEnabled: hapticsEnabled,
      quietHoursEnabled: quietHoursEnabled,
      quietHoursFrom: quietHoursFrom,
      quietHoursUntil: quietHoursUntil,
      maskAppNames: maskAppNames,
    );
  }

  static const int _minimumTargetMinutes = 15;
}
