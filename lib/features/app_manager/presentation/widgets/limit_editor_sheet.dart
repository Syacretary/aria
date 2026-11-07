import 'package:flutter/material.dart';

import '../../../../core/motion/aria_haptics.dart';
import '../../../../core/motion/aria_motion.dart';
import '../../../../core/motion/aria_sheet.dart';
import '../../../../core/motion/aria_tap.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/duration_x.dart';
import '../../domain/entities/limit_enforcement.dart';
import '../../domain/entities/managed_app.dart';

/// Result of the limit editor: the chosen quota, enforcement and enabled state.
///
/// Returned rather than applied directly, so the sheet stays a pure UI
/// component and the caller decides what to persist.
class LimitEditorResult {
  const LimitEditorResult({
    required this.quota,
    required this.enforcement,
    required this.enabled,
  });

  final Duration quota;
  final LimitEnforcement enforcement;
  final bool enabled;
}

/// Sheet for editing one app's daily limit.
///
/// Opens through [AriaSheet.show] — the slide-up spring, top radius and drag
/// behaviour come from the shared wrapper, not from anything here.
class LimitEditorSheet extends StatefulWidget {
  const LimitEditorSheet({super.key, required this.app});

  final ManagedApp app;

  /// Preset quotas offered as one-tap chips.
  static const List<int> presets = [15, 30, 45, 60, 90, 120];

  static const int _minMinutes = 5;
  static const int _maxMinutes = 240;

  static Future<LimitEditorResult?> show(
    BuildContext context, {
    required ManagedApp app,
  }) {
    return AriaSheet.show<LimitEditorResult>(
      context: context,
      builder: (_) => LimitEditorSheet(app: app),
    );
  }

  @override
  State<LimitEditorSheet> createState() => _LimitEditorSheetState();
}

class _LimitEditorSheetState extends State<LimitEditorSheet> {
  late double _minutes;
  late LimitEnforcement _enforcement;
  late bool _enabled;

  bool get _hadLimit => widget.app.hasLimit;

  @override
  void initState() {
    super.initState();
    final existing = widget.app.limit;
    _minutes =
        (existing?.dailyQuota.inMinutes ??
                widget.app.usedToday.inMinutes.clamp(30, 120))
            .toDouble()
            .clamp(
              LimitEditorSheet._minMinutes.toDouble(),
              LimitEditorSheet._maxMinutes.toDouble(),
            );
    _enforcement = existing?.enforcement ?? LimitEnforcement.breathe;
    _enabled = existing?.enabled ?? true;
  }

  void _applyPreset(int minutes) {
    AriaHaptics.selection();
    setState(() {
      _minutes = minutes.toDouble();
      _enabled = true;
    });
  }

  void _submit() {
    Navigator.of(context).pop(
      LimitEditorResult(
        quota: Duration(minutes: _minutes.round()),
        enforcement: _enforcement,
        enabled: _enabled,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final app = widget.app;

    return SafeArea(
      top: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Batas harian', style: theme.textTheme.titleLarge),
            const SizedBox(height: AppSpacing.xxs),
            Text(
              app.appName,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            // The headline number: the single most important value in the
            // sheet, so it gets the largest type.
            Center(
              child: Column(
                children: [
                  Text(
                    Duration(minutes: _minutes.round()).compact,
                    style: theme.textTheme.displaySmall,
                  ),
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    'per hari',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            Slider(
              value: _minutes,
              min: LimitEditorSheet._minMinutes.toDouble(),
              max: LimitEditorSheet._maxMinutes.toDouble(),
              divisions:
                  (LimitEditorSheet._maxMinutes -
                      LimitEditorSheet._minMinutes) ~/
                  5,
              onChanged: (value) => setState(() => _minutes = value),
              onChangeEnd: (_) => AriaHaptics.tap(),
            ),

            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                for (final preset in LimitEditorSheet.presets)
                  _PresetChip(
                    minutes: preset,
                    selected: _minutes.round() == preset,
                    onTap: () => _applyPreset(preset),
                  ),
              ],
            ),

            const SizedBox(height: AppSpacing.xl),
            Text('Saat batas tercapai', style: theme.textTheme.titleMedium),
            const SizedBox(height: AppSpacing.sm),
            for (final option in LimitEnforcement.values)
              _EnforcementOption(
                option: option,
                selected: _enforcement == option,
                onTap: () {
                  AriaHaptics.selection();
                  setState(() => _enforcement = option);
                },
              ),

            const SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Aktifkan batas',
                    style: theme.textTheme.bodyLarge,
                  ),
                ),
                Switch.adaptive(
                  value: _enabled,
                  onChanged: (value) => setState(() => _enabled = value),
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                if (_hadLimit)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(
                        // A zero quota is the sentinel the caller reads as
                        // "remove this limit".
                        const LimitEditorResult(
                          quota: Duration.zero,
                          enforcement: LimitEnforcement.trackOnly,
                          enabled: false,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(48),
                        shape: const RoundedRectangleBorder(
                          borderRadius: AppRadius.pill,
                        ),
                      ),
                      child: const Text('Hapus'),
                    ),
                  ),
                if (_hadLimit) const SizedBox(width: AppSpacing.md),
                Expanded(
                  flex: 2,
                  child: AriaTap.button(
                    onTap: _submit,
                    borderRadius: AppRadius.pill,
                    child: Container(
                      height: 48,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary,
                        borderRadius: AppRadius.pill,
                      ),
                      child: Text(
                        'Simpan',
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: theme.colorScheme.onPrimary,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
          ],
        ),
      ),
    );
  }
}

class _PresetChip extends StatelessWidget {
  const _PresetChip({
    required this.minutes,
    required this.selected,
    required this.onTap,
  });

  final int minutes;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AriaTap.button(
      onTap: onTap,
      borderRadius: AppRadius.pill,
      semanticLabel: '$minutes menit',
      child: AnimatedContainer(
        duration: AriaMotion.medium,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: selected
              ? theme.colorScheme.primaryContainer
              : theme.colorScheme.surfaceContainerHigh,
          borderRadius: AppRadius.pill,
        ),
        child: Text(
          Duration(minutes: minutes).compact,
          style: theme.textTheme.labelMedium?.copyWith(
            color: selected
                ? theme.colorScheme.onPrimaryContainer
                : theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

class _EnforcementOption extends StatelessWidget {
  const _EnforcementOption({
    required this.option,
    required this.selected,
    required this.onTap,
  });

  final LimitEnforcement option;
  final bool selected;
  final VoidCallback onTap;

  IconData get _icon => switch (option) {
    LimitEnforcement.warn => Icons.notifications_none_rounded,
    LimitEnforcement.block => Icons.block_rounded,
    LimitEnforcement.breathe => Icons.self_improvement_rounded,
    LimitEnforcement.trackOnly => Icons.visibility_outlined,
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: AriaTap.button(
        onTap: onTap,
        borderRadius: AppRadius.shellBorder,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              Icon(
                _icon,
                size: 20,
                color: selected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(option.label, style: theme.textTheme.bodyLarge),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      option.description,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              AnimatedScale(
                scale: selected ? 1 : 0,
                duration: AriaMotion.fast,
                curve: Curves.easeOutCubic,
                child: Icon(
                  Icons.check_circle_rounded,
                  size: 20,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
