import 'package:flutter/material.dart';

import '../../../../core/motion/aria_haptics.dart';
import '../../../../core/motion/aria_motion.dart';
import '../../../../core/motion/aria_sheet.dart';
import '../../../../core/motion/aria_tap.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/aria_semantic_colors.dart';
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
    required this.remindOnOpen,
  });

  final Duration quota;
  final LimitEnforcement enforcement;
  final bool enabled;
  final bool remindOnOpen;
}

/// Sheet for editing one app's daily limit.
///
/// Opens through [AriaSheet.show] — the slide-up spring, top radius and drag
/// behaviour come from the shared wrapper, not from anything here.
class LimitEditorSheet extends StatefulWidget {
  const LimitEditorSheet({super.key, required this.app});

  final ManagedApp app;

  /// Preset quotas offered as one-tap chips.
  static const List<int> presets = [5, 15, 30, 60, 120];

  static const int _minMinutes = 5;
  static const int _maxMinutes = 240;

  static Future<LimitEditorResult?> show(
    BuildContext context, {
    required ManagedApp app,
  }) {
    return AriaSheet.show<LimitEditorResult>(
      context: context,
      maxHeightFactor: 0.97,
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
  late bool _remindOnOpen;

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
    _remindOnOpen = existing?.remindOnOpen ?? false;
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
        remindOnOpen: _remindOnOpen,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final app = widget.app;

    return SafeArea(
      top: false,
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                0,
                AppSpacing.lg,
                AppSpacing.sm,
              ),
              child: Column(
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
                        const SizedBox(height: AppSpacing.sm),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _MinuteStepButton(
                              icon: Icons.remove_rounded,
                              onTap: () => setState(
                                () => _minutes = (_minutes - 5).clamp(5, 240),
                              ),
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Text(
                              'atur per 5 menit',
                              style: theme.textTheme.labelSmall,
                            ),
                            const SizedBox(width: AppSpacing.md),
                            _MinuteStepButton(
                              icon: Icons.add_rounded,
                              onTap: () => setState(
                                () => _minutes = (_minutes + 5).clamp(5, 240),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _QuotaFeedback(minutes: _minutes.round()),
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
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Saat batas tercapai',
                          style: theme.textTheme.titleMedium,
                        ),
                      ),
                      const Icon(Icons.touch_app_outlined, size: 18),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: AppSpacing.sm,
                    crossAxisSpacing: AppSpacing.sm,
                    childAspectRatio: 1.75,
                    children: [
                      for (final option in LimitEnforcement.values)
                        _EnforcementOption(
                          option: option,
                          selected: _enforcement == option,
                          onTap: () {
                            AriaHaptics.selection();
                            setState(() => _enforcement = option);
                          },
                        ),
                    ],
                  ),

                  const SizedBox(height: AppSpacing.md),
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

                  SwitchListTile.adaptive(
                    contentPadding: EdgeInsets.zero,
                    value: _remindOnOpen,
                    onChanged: (value) => setState(() => _remindOnOpen = value),
                    title: const Text('Ingatkan saat dibuka'),
                    subtitle: const Text(
                      'Jeda 8 detik untuk memilih dengan sadar',
                    ),
                    secondary: const Icon(Icons.mark_chat_unread_outlined),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.sm,
              AppSpacing.lg,
              AppSpacing.md,
            ),
            child: Row(
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
                          remindOnOpen: false,
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
                        _hadLimit ? 'Terapkan perubahan' : 'Aktifkan batas',
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: theme.colorScheme.onPrimary,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QuotaFeedback extends StatelessWidget {
  const _QuotaFeedback({required this.minutes});

  final int minutes;

  ({IconData icon, String title, String body}) get _message =>
      switch (minutes) {
        <= 10 => (
          icon: Icons.bolt_rounded,
          title: 'Target fokus',
          body: 'Pilihan yang menantang. Pastikan durasi ini terasa realistis untukmu.',
        ),
        <= 30 => (
          icon: Icons.spa_outlined,
          title: 'Ritme ringan',
          body: 'Ada waktu untuk cek kabar tanpa harus berlama-lama. Pelan-pelan saja.',
        ),
        <= 60 => (
          icon: Icons.balance_rounded,
          title: 'Ritme moderat',
          body: 'Masih ada ruang untuk bersosialisasi—dan itu tidak apa-apa.',
        ),
        <= 120 => (
          icon: Icons.waves_rounded,
          title: 'Batas fleksibel',
          body:
              'Lebih longgar untuk hiburan. Kamu bisa mengubahnya kapan saja.',
        ),
        _ => (
          icon: Icons.tune_rounded,
          title: 'Pilihanmu sendiri',
          body:
              'Batas ini cukup longgar. Sesuaikan lagi jika ritmenya berubah.',
        ),
      };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.ariaColors;
    final message = _message;
    return AnimatedSwitcher(
      duration: AriaMotion.medium,
      child: Container(
        key: ValueKey(
          minutes <= 10
              ? 10
              : minutes <= 30
              ? 30
              : minutes <= 60
              ? 60
              : minutes <= 120
              ? 120
              : 240,
        ),
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: colors.winSurface.withValues(alpha: .72),
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(message.icon, size: 20, color: colors.win),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.title,
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    message.body,
                    style: theme.textTheme.bodySmall?.copyWith(height: 1.35),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MinuteStepButton extends StatelessWidget {
  const _MinuteStepButton({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => IconButton.filledTonal(
    onPressed: onTap,
    icon: Icon(icon),
    tooltip: icon == Icons.add_rounded ? 'Tambah 5 menit' : 'Kurangi 5 menit',
  );
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

  String get _title => switch (option) {
    LimitEnforcement.warn => 'Ingatkan',
    LimitEnforcement.block => 'Blokir',
    LimitEnforcement.breathe => 'Jeda 15 dtk',
    LimitEnforcement.trackOnly => 'Catat saja',
  };

  String get _hint => switch (option) {
    LimitEnforcement.warn => 'Notifikasi',
    LimitEnforcement.block => 'Kembali ke beranda',
    LimitEnforcement.breathe => 'Tarik napas',
    LimitEnforcement.trackOnly => 'Tanpa tindakan',
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.ariaColors;
    return AriaTap.button(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.md),
      semanticLabel:
          '${option.label}, ${selected ? 'dipilih' : 'ketuk untuk memilih'}',
      child: AnimatedContainer(
        duration: AriaMotion.fast,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: selected
              ? colors.winSurface.withValues(alpha: .85)
              : theme.colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: selected
                ? colors.win.withValues(alpha: .7)
                : theme.colorScheme.outlineVariant.withValues(alpha: .55),
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Stack(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: Icon(
                selected ? Icons.check_circle_rounded : _icon,
                size: 19,
                color: selected
                    ? colors.win
                    : theme.colorScheme.onSurfaceVariant,
              ),
            ),
            Align(
              alignment: Alignment.bottomLeft,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _hint,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
