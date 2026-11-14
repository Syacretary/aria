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
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/routing/routes.dart';
import '../../../../core/utils/duration_x.dart';
import '../../check_ins/data/spot_check_notifications.dart';
import '../domain/entities/app_settings.dart';
import '../domain/entities/permission_status.dart';
import 'providers/settings_providers.dart';
import 'widgets/permission_row.dart';
import 'widgets/settings_section.dart';

/// Pengaturan — permissions, ARIA's voice, and data controls.
class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);

    return AriaScaffold(
      title: 'Pengaturan',
      subtitle: 'Izin dan preferensi ARIA',
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
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.pageGutter,
        0,
        AppSpacing.pageGutter,
        AppSpacing.huge,
      ),
      children: [
        // --- Permissions -----------------------------------------------------
        _PermissionsSection(),
        const SizedBox(height: AppSpacing.xl),

        // --- ARIA's voice ----------------------------------------------------
        SettingsSection(
          title: 'ARIA',
          children: [
            SettingsRow(
              label: 'Nada bicara',
              value: _toneLabel(settings.tone),
              subtitle: 'Bagaimana ARIA berbicara kepadamu',
              onTap: () => _pickTone(context, ref, settings.tone),
            ),
            SettingsRow(
              label: 'Target screentime harian',
              value: settings.dailyTarget.compact,
              subtitle: 'Garis acuan pada grafik tren',
              onTap: () => _pickTarget(context, ref, settings.dailyTarget),
            ),
            SettingsRow(
              label: 'Jam tenang',
              value: settings.quietHoursEnabled
                  ? '${Duration(minutes: settings.quietHoursFrom.inMinutes).compact}'
                        '–${Duration(minutes: settings.quietHoursUntil.inMinutes).compact}'
                  : 'Nonaktif',
              subtitle: 'ARIA tidak mengirim pesan pada jam ini',
              trailing: Switch.adaptive(
                value: settings.quietHoursEnabled,
                onChanged: (value) =>
                    _save(context, ref, quietHoursEnabled: value),
              ),
            ),
            SettingsRow(
              label: 'AI Penasihat ARIA',
              subtitle: 'Koneksi model, privasi, dan pesan proaktif',
              trailing: Icon(
                Icons.chevron_right_rounded,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              onTap: () => context.push(Routes.settingsAriaAi),
            ),
            SettingsRow(
              label: 'Check-in berkala',
              subtitle: 'Refleksi singkat tentang ritme dan fokusmu',
              trailing: Icon(
                Icons.chevron_right_rounded,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              onTap: () => context.push(Routes.spotCheck),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xl),

        // --- Feel ------------------------------------------------------------
        SettingsSection(
          title: 'Rasa & Sentuhan',
          caption: 'Prinsip interaksi ARIA',
          children: [
            SettingsRow(
              label: 'Getaran halus',
              subtitle: 'Ketukan ringan saat menekan tombol, seperti menyentuh kertas',
              trailing: Switch.adaptive(
                value: settings.hapticsEnabled,
                onChanged: (value) =>
                    _save(context, ref, hapticsEnabled: value),
              ),
            ),
            SettingsRow(
              label: 'Samarkan nama aplikasi',
              subtitle: 'Ganti nama app di beranda untuk menjaga privasi',
              trailing: Switch.adaptive(
                value: settings.maskAppNames,
                onChanged: (value) => _save(context, ref, maskAppNames: value),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xl),

        // --- Data ------------------------------------------------------------
        SettingsSection(
          title: 'Data & Privasi',
          caption: 'Semua data ARIA disimpan di perangkat ini',
          children: [
            SettingsRow(
              label: 'Hapus semua data',
              subtitle: 'Menghapus batas, preferensi, dan riwayat lokal',
              trailing: Icon(
                Icons.chevron_right_rounded,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              onTap: () => _confirmClear(context, ref),
            ),
            const SettingsRow(
              label: 'Tentang ARIA',
              value: 'v${AppConfig.version}',
              subtitle: 'Pendamping digitalmu',
            ),
          ],
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
      AriaFeedback.success(context, 'Semua data ARIA telah dihapus.');
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

/// Permissions block, loaded separately so a slow OS query doesn't hold up the
/// rest of the screen.
class _PermissionsSection extends ConsumerStatefulWidget {
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

    return SettingsSection(
      title: 'Izin aplikasi',
      caption: 'Pilih fitur yang ingin kamu aktifkan. Izin dapat dicabut kapan saja.',
      children: [
        permissions.when(
          loading: () => const Padding(
            padding: EdgeInsets.all(AppSpacing.lg),
            child: AriaSkeletonLines(lines: 4, lineHeight: 18),
          ),
          error: (error, _) => Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Text(
              failureMessage(error),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          data: (states) => Column(
            children: [
              if (!(states[AppPermission.usageAccess]?.isGranted ?? false))
                const _PermissionContextCard(),
              for (var i = 0; i < AppPermission.values.length; i++) ...[
                if (i > 0)
                  Divider(
                    height: 1,
                    indent: AppSpacing.lg,
                    endIndent: AppSpacing.lg,
                    color: Theme.of(context).colorScheme.outlineVariant
                        .withValues(alpha: 0.4),
                  ),
                PermissionRow(
                  permission: AppPermission.values[i],
                  state:
                      states[AppPermission.values[i]] ?? PermissionState.denied,
                  onRequest: () => _request(context, AppPermission.values[i]),
                ),
              ],
            ],
          ),
        ),
      ],
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
        // Re-read the states; on a real device this also needs to re-query when
        // the app resumes from the system Settings screen.
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

class _PermissionContextCard extends StatelessWidget {
  const _PermissionContextCard();

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.all(AppSpacing.md),
    padding: const EdgeInsets.all(AppSpacing.md),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.primaryContainer
          .withValues(alpha: .55),
      borderRadius: BorderRadius.circular(16),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          Icons.insights_outlined,
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(width: AppSpacing.sm),
        const Expanded(
          child: Text(
            'Beranda masih menunggu data pemakaian. Aktifkan “Akses data pemakaian” untuk melihat screentime dan frekuensi buka aplikasi.',
          ),
        ),
      ],
    ),
  );
}
