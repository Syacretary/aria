import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/companion/aria_tone.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/motion/aria_feedback.dart';
import '../../../../core/motion/aria_sheet.dart';
import '../../../../core/presentation/aria_loading.dart';
import '../../../../core/presentation/aria_scaffold.dart';
import '../../../../core/routing/routes.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/duration_x.dart';
import '../../check_ins/data/spot_check_notifications.dart';
import '../domain/entities/app_settings.dart';
import '../domain/entities/permission_status.dart';
import 'providers/settings_providers.dart';
import 'widgets/permission_row.dart';
import 'widgets/settings_section.dart';

/// Pengaturan — minimalis, visual, dan intuitif dalam 3 detik pertama.
class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);

    return AriaScaffold(
      title: 'Pengaturan',
      subtitle: 'Preferensi & privasi ARIA',
      child: settings.when(
        loading: () => const Padding(
          padding: EdgeInsets.all(AppSpacing.pageGutter),
          child: AriaSkeletonLines(lines: 8, lineHeight: 24),
        ),
        error: (error, _) => Padding(
          padding: const EdgeInsets.all(AppSpacing.pageGutter),
          child: Text(failureMessage(error)),
        ),
        data: (data) => _Content(settings: data),
      ),
    );
  }
}

class _Content extends ConsumerWidget {
  const _Content({required this.settings});

  final AppSettings settings;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.pageGutter,
        0,
        AppSpacing.pageGutter,
        AppSpacing.huge,
      ),
      children: [
        // --- 1. Permissions --------------------------------------------------
        const _PermissionsSection(),
        const SizedBox(height: AppSpacing.xl),

        // --- 2. ARIA Companion -----------------------------------------------
        SettingsSection(
          title: 'Preferensi ARIA',
          children: [
            SettingsRow(
              leading: const SettingsIcon(
                icon: Icons.record_voice_over_outlined,
              ),
              label: 'Nada bicara',
              value: _toneLabel(settings.tone),
              onTap: () => _pickTone(context, ref, settings.tone),
            ),
            SettingsRow(
              leading: const SettingsIcon(
                icon: Icons.timer_outlined,
              ),
              label: 'Target harian',
              value: settings.dailyTarget.compact,
              onTap: () => _pickTarget(context, ref, settings.dailyTarget),
            ),
            SettingsRow(
              leading: const SettingsIcon(
                icon: Icons.bedtime_outlined,
              ),
              label: 'Jam tenang',
              value: settings.quietHoursEnabled
                  ? '${Duration(minutes: settings.quietHoursFrom.inMinutes).compact}'
                        '–${Duration(minutes: settings.quietHoursUntil.inMinutes).compact}'
                  : null,
              trailing: Switch.adaptive(
                value: settings.quietHoursEnabled,
                onChanged: (value) =>
                    _save(context, ref, quietHoursEnabled: value),
              ),
            ),
            SettingsRow(
              leading: const SettingsIcon(
                icon: Icons.auto_awesome_outlined,
              ),
              label: 'AI Penasihat ARIA',
              onTap: () => context.push(Routes.settingsAriaAi),
            ),
            SettingsRow(
              leading: const SettingsIcon(
                icon: Icons.spa_outlined,
              ),
              label: 'Refleksi & tes fokus',
              onTap: () => context.push(Routes.spotCheck),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xl),

        // --- 3. Experience & UI ----------------------------------------------
        SettingsSection(
          title: 'Pengalaman & Tampilan',
          children: [
            SettingsRow(
              leading: const SettingsIcon(
                icon: Icons.vibration_rounded,
              ),
              label: 'Efek getar sentuhan',
              trailing: Switch.adaptive(
                value: settings.hapticsEnabled,
                onChanged: (value) =>
                    _save(context, ref, hapticsEnabled: value),
              ),
            ),
            SettingsRow(
              leading: const SettingsIcon(
                icon: Icons.visibility_off_outlined,
              ),
              label: 'Samarkan nama aplikasi',
              trailing: Switch.adaptive(
                value: settings.maskAppNames,
                onChanged: (value) => _save(context, ref, maskAppNames: value),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xl),

        // --- 4. Data & Privacy -----------------------------------------------
        SettingsSection(
          title: 'Penyimpanan & Data',
          children: [
            SettingsRow(
              leading: SettingsIcon(
                icon: Icons.delete_outline_rounded,
                color: theme.colorScheme.error,
                backgroundColor: theme.colorScheme.error.withValues(alpha: 0.12),
              ),
              label: 'Hapus semua data lokal',
              labelColor: theme.colorScheme.error,
              onTap: () => _confirmClear(context, ref),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xxl),

        // --- Minimalist Footer -----------------------------------------------
        Center(
          child: Column(
            children: [
              Text(
                'ARIA v${AppConfig.version}',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Data tersimpan privat di perangkat ini',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.45),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Actions
  // ---------------------------------------------------------------------------

  Future<void> _save(
    BuildContext context,
    WidgetRef ref, {
    AriaTone? tone,
    Duration? dailyTarget,
    bool? hapticsEnabled,
    bool? quietHoursEnabled,
    bool? maskAppNames,
  }) async {
    final failure = await ref
        .read(settingsProvider.notifier)
        .save(
          tone: tone,
          dailyTarget: dailyTarget,
          hapticsEnabled: hapticsEnabled,
          quietHoursEnabled: quietHoursEnabled,
          maskAppNames: maskAppNames,
        );
    if (!context.mounted || failure == null) return;
    AriaFeedback.warning(context, failure.message);
  }

  Future<void> _pickTone(
    BuildContext context,
    WidgetRef ref,
    AriaTone current,
  ) async {
    final selected = await AriaSheet.showOptions<AriaTone>(
      context: context,
      title: 'Nada bicara ARIA',
      options: const [
        AriaSheetOption(
          value: AriaTone.gentle,
          label: 'Lembut',
          subtitle: 'Menemani tanpa menghakimi',
          icon: Icons.spa_outlined,
        ),
        AriaSheetOption(
          value: AriaTone.firm,
          label: 'Tegas',
          subtitle: 'Langsung dan jelas',
          icon: Icons.straighten_rounded,
        ),
        AriaSheetOption(
          value: AriaTone.playful,
          label: 'Humoris',
          subtitle: 'Ringan dan jenaka',
          icon: Icons.sentiment_satisfied_outlined,
        ),
        AriaSheetOption(
          value: AriaTone.scriptural,
          label: 'Alkitabiah',
          subtitle: 'Mengutip ayat sebagai penguat',
          icon: Icons.menu_book_outlined,
        ),
      ],
    );

    if (selected == null || !context.mounted) return;
    if (selected == current) return;
    await _save(context, ref, tone: selected);
    if (!context.mounted) return;
    AriaFeedback.info(context, 'Nada ARIA diubah ke ${_toneLabel(selected)}.');
  }

  Future<void> _pickTarget(
    BuildContext context,
    WidgetRef ref,
    Duration current,
  ) async {
    const options = [60, 120, 180, 240, 300, 360];
    final selected = await AriaSheet.showOptions<int>(
      context: context,
      title: 'Target screentime harian',
      options: [
        for (final minutes in options)
          AriaSheetOption(
            value: minutes,
            label: Duration(minutes: minutes).compact,
            subtitle: minutes == current.inMinutes ? 'Saat ini' : null,
            icon: minutes == current.inMinutes
                ? Icons.check_circle_outline_rounded
                : null,
          ),
      ],
    );

    if (selected == null || !context.mounted) return;
    await _save(context, ref, dailyTarget: Duration(minutes: selected));
  }

  Future<void> _confirmClear(BuildContext context, WidgetRef ref) async {
    final confirmed = await AriaSheet.show<bool>(
      context: context,
      builder: (sheetContext) => Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hapus semua data ARIA?',
              style: Theme.of(sheetContext).textTheme.titleLarge,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Semua batas, preferensi, dan riwayat lokal akan dihapus permanen.',
              style: Theme.of(sheetContext).textTheme.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.xl),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(sheetContext).pop(false),
                    child: const Text('Batal'),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: Theme.of(sheetContext).colorScheme.error,
                    ),
                    onPressed: () => Navigator.of(sheetContext).pop(true),
                    child: const Text('Hapus'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );

    if (confirmed != true || !context.mounted) return;

    final failure = await ref.read(settingsProvider.notifier).clearAllData();
    if (!context.mounted) return;

    if (failure == null) {
      await SpotCheckNotifications.cancel();
      await const MethodChannel('com.aria.aria/proactive')
          .invokeMethod<void>('cancel');
      await const MethodChannel('com.aria.aria/secure_store')
          .invokeMethod<void>('clearSession');
      if (context.mounted) {
        AriaFeedback.success(context, 'Semua data ARIA telah dihapus.');
      }
    } else {
      AriaFeedback.warning(context, failure.message);
    }
  }

  static String _toneLabel(AriaTone tone) => switch (tone) {
    AriaTone.gentle => 'Lembut',
    AriaTone.firm => 'Tegas',
    AriaTone.playful => 'Humoris',
    AriaTone.scriptural => 'Alkitabiah',
  };
}

/// Permissions block, loaded separately so a slow OS query doesn't hold up the screen.
class _PermissionsSection extends ConsumerStatefulWidget {
  const _PermissionsSection();

  @override
  ConsumerState<_PermissionsSection> createState() =>
      _PermissionsSectionState();
}

class _PermissionsSectionState extends ConsumerState<_PermissionsSection>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      ref.invalidate(permissionStatesProvider);
    }
  }

  @override
  Widget build(BuildContext context) {
    final permissions = ref.watch(permissionStatesProvider);

    return permissions.when(
      loading: () => const SettingsSection(
        title: 'Izin aplikasi',
        children: [
          Padding(
            padding: EdgeInsets.all(AppSpacing.lg),
            child: AriaSkeletonLines(lines: 4, lineHeight: 18),
          ),
        ],
      ),
      error: (error, _) => SettingsSection(
        title: 'Izin aplikasi',
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Text(
              failureMessage(error),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
      data: (states) => SettingsSection(
        title: 'Izin aplikasi',
        children: [
          for (final permission in AppPermission.values)
            PermissionRow(
              permission: permission,
              state: states[permission] ?? PermissionState.denied,
              onRequest: () => _request(context, permission),
            ),
        ],
      ),
    );
  }

  Future<void> _request(BuildContext context, AppPermission permission) async {
    if (permission == AppPermission.scrollDetection) {
      final accepted = await _showScrollDisclosure(context);
      if (accepted != true || !context.mounted) return;
    }
    final result = await ref.read(checkPermissionsProvider).request(permission);
    if (!context.mounted) return;

    result.when(
      ok: (_) {
        ref.invalidate(permissionStatesProvider);
        AriaFeedback.info(context, 'Status izin diperbarui.');
      },
      err: (failure) => AriaFeedback.warning(context, failure.message),
    );
  }

  Future<bool?> _showScrollDisclosure(BuildContext context) =>
      AriaSheet.show<bool>(
        context: context,
        builder: (sheetContext) => Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Deteksi scroll',
                style: Theme.of(sheetContext).textTheme.titleLarge,
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'ARIA menghitung perkiraan video yang dilewati di Instagram, YouTube, dan TikTok tanpa membaca isi layar, lalu menyimpan hitungannya di perangkat ini.',
                style: Theme.of(sheetContext).textTheme.bodyMedium,
              ),
              const SizedBox(height: AppSpacing.xl),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(sheetContext, false),
                      child: const Text('Nanti saja'),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: FilledButton(
                      onPressed: () => Navigator.pop(sheetContext, true),
                      child: const Text('Saya mengerti'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
}
