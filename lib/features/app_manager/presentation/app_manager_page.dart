import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/motion/aria_feedback.dart';
import '../../../../core/presentation/aria_empty_state.dart';
import '../../../../core/presentation/aria_loading.dart';
import '../../../../core/presentation/aria_scaffold.dart';
import '../../../../core/presentation/aria_section_header.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/aria_semantic_colors.dart';
import '../../../../core/utils/duration_x.dart';
import '../domain/entities/managed_app.dart';
import 'providers/app_manager_providers.dart';
import 'widgets/limit_editor_sheet.dart';
import 'widgets/managed_app_tile.dart';

/// Kelola Aplikasi — set, adjust and toggle daily usage limits.
///
/// The list is sorted busiest-first, so the apps most likely to need a limit
/// are already at the top when the user arrives.
class AppManagerPage extends ConsumerWidget {
  const AppManagerPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final apps = ref.watch(managedAppsProvider);

    return AriaScaffold(
      title: 'Kelola Aplikasi',
      subtitle: 'Batas pemakaian harian',
      child: apps.when(
        loading: () => const Padding(
          padding: EdgeInsets.all(AppSpacing.pageGutter),
          child: Column(
            children: [
              AriaSkeleton(height: 68, radius: 20),
              SizedBox(height: AppSpacing.md),
              AriaSkeleton(height: 68, radius: 20),
              SizedBox(height: AppSpacing.md),
              AriaSkeleton(height: 68, radius: 20),
            ],
          ),
        ),
        error: (error, _) => Padding(
          padding: const EdgeInsets.all(AppSpacing.pageGutter),
          child: AriaEmptyState(
            icon: Icons.error_outline_rounded,
            title: 'Gagal memuat daftar aplikasi',
            message: failureMessage(error),
          ),
        ),
        data: (data) => _Content(apps: data),
      ),
    );
  }
}

class _Content extends ConsumerWidget {
  const _Content({required this.apps});

  final List<ManagedApp> apps;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final limited = apps.where((a) => a.hasLimit).toList(growable: false);
    final unlimited = apps.where((a) => !a.hasLimit).toList(growable: false);

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.pageGutter,
        0,
        AppSpacing.pageGutter,
        AppSpacing.huge,
      ),
      children: [
        _SummaryStrip(apps: apps),
        const SizedBox(height: AppSpacing.xl),
        if (limited.isNotEmpty) ...[
          const AriaSectionHeader(title: 'DENGAN BATAS'),
          for (final app in limited) ...[
            ManagedAppTile(
              app: app,
              onTap: () => _editLimit(context, ref, app),
              onToggle: (value) => _toggle(context, ref, app, value),
            ),
            const SizedBox(height: AppSpacing.md),
          ],
          const SizedBox(height: AppSpacing.sm),
        ],
        const AriaSectionHeader(
          title: 'TANPA BATAS',
          caption: 'Ketuk untuk menetapkan batas harian',
        ),
        for (final app in unlimited) ...[
          ManagedAppTile(app: app, onTap: () => _editLimit(context, ref, app)),
          const SizedBox(height: AppSpacing.md),
        ],
      ],
    );
  }

  Future<void> _editLimit(
    BuildContext context,
    WidgetRef ref,
    ManagedApp app,
  ) async {
    final result = await LimitEditorSheet.show(context, app: app);
    if (result == null || !context.mounted) return;

    final notifier = ref.read(managedAppsProvider.notifier);

    // A zero quota means the user chose "Hapus".
    if (result.quota == Duration.zero) {
      final failure = await notifier.removeLimit(app.packageName);
      if (!context.mounted) return;
      if (failure == null) {
        AriaFeedback.info(context, 'Batas ${app.appName} dihapus.');
      } else {
        AriaFeedback.warning(context, failure.message);
      }
      return;
    }

    final failure = await notifier.setLimit(
      packageName: app.packageName,
      quota: result.quota,
      enabled: result.enabled,
      enforcement: result.enforcement,
    );
    if (!context.mounted) return;

    if (failure == null) {
      AriaFeedback.success(
        context,
        'Batas ${app.appName} disetel ${result.quota.compact}/hari.',
      );
    } else {
      AriaFeedback.warning(context, failure.message);
    }
  }

  Future<void> _toggle(
    BuildContext context,
    WidgetRef ref,
    ManagedApp app,
    bool value,
  ) async {
    final failure = await ref
        .read(managedAppsProvider.notifier)
        .setEnabled(app.packageName, value);
    if (!context.mounted || failure == null) return;
    AriaFeedback.warning(context, failure.message);
  }
}

/// Total screen time under management at a glance.
class _SummaryStrip extends StatelessWidget {
  const _SummaryStrip({required this.apps});

  final List<ManagedApp> apps;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.ariaColors;

    final limitedCount = apps.where((a) => a.isLimitActive).length;
    final overCount = apps.where((a) => a.isOverQuota).length;
    final totalManaged = apps
        .where((a) => a.isLimitActive)
        .fold(Duration.zero, (sum, app) => sum + app.usedToday);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: overCount > 0
            ? colors.over.withValues(alpha: 0.08)
            : theme.colorScheme.surfaceContainer,
        borderRadius: AppRadius.shellBorder,
      ),
      child: Row(
        children: [
          Expanded(
            child: _Stat(label: 'Aplikasi dibatasi', value: '$limitedCount'),
          ),
          Container(width: 1, height: 34, color: colors.hairline),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: AppSpacing.lg),
              child: _Stat(
                label: 'Pemakaian terbatas',
                value: totalManaged.compact,
              ),
            ),
          ),
          Container(width: 1, height: 34, color: colors.hairline),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: AppSpacing.lg),
              child: _Stat(
                label: 'Lewat batas',
                value: '$overCount',
                emphasize: overCount > 0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({
    required this.label,
    required this.value,
    this.emphasize = false,
  });

  final String label;
  final String value;
  final bool emphasize;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: theme.textTheme.headlineSmall?.copyWith(
            color: emphasize ? context.ariaColors.over : null,
          ),
        ),
        const SizedBox(height: AppSpacing.xxs),
        Text(
          label.toUpperCase(),
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            letterSpacing: 0.8,
            fontSize: 9.5,
          ),
        ),
      ],
    );
  }
}
