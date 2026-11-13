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
import '../domain/entities/limit_enforcement.dart';
import '../domain/entities/managed_app.dart';
import 'providers/app_manager_providers.dart';
import 'widgets/limit_editor_sheet.dart';
import 'widgets/managed_app_tile.dart';

/// Apps move between an active limit drop zone and the installed-app grid.
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
    final limited = apps.where((a) => a.isLimitActive).toList(growable: false);
    final available = apps
        .where((a) => !a.isLimitActive)
        .toList(growable: false);

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
        _ActiveLimitsDropZone(
          apps: limited,
          onAccept: (app) => _enableFromDrop(context, ref, app),
          onEdit: (app) => _editLimit(context, ref, app),
        ),
        const SizedBox(height: AppSpacing.xl),
        AriaSectionHeader(
          title: 'APLIKASI TERPASANG',
          caption: '${available.length} aplikasi belum dibatasi',
        ),
        _InstalledAppsGrid(
          apps: available,
          onAccept: (app) => _disableFromDrop(context, ref, app),
          onTap: (app) => _editLimit(context, ref, app),
        ),
      ],
    );
  }

  Future<void> _enableFromDrop(
    BuildContext context,
    WidgetRef ref,
    ManagedApp app,
  ) async {
    if (app.isLimitActive) return;
    final notifier = ref.read(managedAppsProvider.notifier);
    final failure = app.hasLimit
        ? await notifier.setEnabled(app.packageName, true)
        : await notifier.setLimit(
            packageName: app.packageName,
            quota: const Duration(minutes: 60),
            enabled: true,
            enforcement: LimitEnforcement.breathe,
          );
    if (!context.mounted) return;
    if (failure == null) {
      AriaFeedback.success(
        context,
        app.hasLimit
            ? 'Batas ${app.appName} diaktifkan.'
            : 'Batas 60 menit diaktifkan untuk ${app.appName}.',
      );
    } else {
      AriaFeedback.warning(context, failure.message);
    }
  }

  Future<void> _disableFromDrop(
    BuildContext context,
    WidgetRef ref,
    ManagedApp app,
  ) async {
    if (!app.isLimitActive) return;
    final failure = await ref
        .read(managedAppsProvider.notifier)
        .setEnabled(app.packageName, false);
    if (!context.mounted) return;
    if (failure == null) {
      AriaFeedback.info(context, 'Batas ${app.appName} dijeda.');
    } else {
      AriaFeedback.warning(context, failure.message);
    }
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
      remindOnOpen: result.remindOnOpen,
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
}

class _ActiveLimitsDropZone extends StatelessWidget {
  const _ActiveLimitsDropZone({
    required this.apps,
    required this.onAccept,
    required this.onEdit,
  });

  final List<ManagedApp> apps;
  final ValueChanged<ManagedApp> onAccept;
  final ValueChanged<ManagedApp> onEdit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.ariaColors;
    return DragTarget<ManagedApp>(
      onAcceptWithDetails: (details) => onAccept(details.data),
      builder: (context, candidates, _) {
        final hovering = candidates.isNotEmpty;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: hovering
                ? colors.winSurface
                : theme.colorScheme.surfaceContainerLow,
            borderRadius: AppRadius.shellBorder,
            border: Border.all(
              color: hovering ? colors.win : colors.hairline,
              width: hovering ? 1.6 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.shield_moon_outlined, color: colors.win, size: 20),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      'BATAS AKTIF',
                      style: theme.textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        letterSpacing: .7,
                      ),
                    ),
                  ),
                  Text('${apps.length}', style: theme.textTheme.labelMedium),
                ],
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                apps.isEmpty
                    ? 'Lempar ikon aplikasi ke sini untuk mengaktifkan batas.'
                    : 'Lempar ikon ke sini untuk membatasi · seret keluar untuk menjeda.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              if (apps.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.md),
                for (final app in apps) ...[
                  LongPressDraggable<ManagedApp>(
                    data: app,
                    hapticFeedbackOnStart: true,
                    dragAnchorStrategy: (_, _, _) => const Offset(31, 78),
                    feedback: _AppDragPreview(app: app),
                    ignoringFeedbackSemantics: true,
                    childWhenDragging: Opacity(
                      opacity: .35,
                      child: ManagedAppTile(app: app, onTap: () {}),
                    ),
                    child: ManagedAppTile(app: app, onTap: () => onEdit(app)),
                  ),
                  if (app != apps.last) const SizedBox(height: AppSpacing.sm),
                ],
              ],
            ],
          ),
        );
      },
    );
  }
}

class _InstalledAppsGrid extends StatelessWidget {
  const _InstalledAppsGrid({
    required this.apps,
    required this.onAccept,
    required this.onTap,
  });

  final List<ManagedApp> apps;
  final ValueChanged<ManagedApp> onAccept;
  final ValueChanged<ManagedApp> onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DragTarget<ManagedApp>(
      onAcceptWithDetails: (details) => onAccept(details.data),
      builder: (context, candidates, _) => AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(AppSpacing.xs),
        decoration: BoxDecoration(
          color: candidates.isNotEmpty
              ? context.ariaColors.over.withValues(alpha: .08)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        child: apps.isEmpty
            ? Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
                child: Center(
                  child: Text(
                    candidates.isNotEmpty
                        ? 'Lepaskan untuk menjeda batas'
                        : 'Semua aplikasi sudah memiliki batas aktif.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              )
            : GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: apps.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisExtent: 116,
                  crossAxisSpacing: AppSpacing.sm,
                  mainAxisSpacing: AppSpacing.sm,
                ),
                itemBuilder: (context, index) {
                  final app = apps[index];
                  final tile = _InstalledAppTile(
                    app: app,
                    onTap: () => onTap(app),
                  );
                  return LongPressDraggable<ManagedApp>(
                    data: app,
                    hapticFeedbackOnStart: true,
                    dragAnchorStrategy: (_, _, _) => const Offset(31, 78),
                    feedback: _AppDragPreview(app: app),
                    ignoringFeedbackSemantics: true,
                    childWhenDragging: Opacity(opacity: .3, child: tile),
                    child: tile,
                  );
                },
              ),
      ),
    );
  }
}

class _InstalledAppTile extends StatelessWidget {
  const _InstalledAppTile({required this.app, required this.onTap});

  final ManagedApp app;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: theme.colorScheme.surfaceContainerLow,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _RoundedAppIcon(app: app, size: 54),
              const SizedBox(height: 8),
              Text(
                app.appName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                app.hasLimit ? 'Jeda' : app.usedToday.compact,
                maxLines: 1,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AppDragPreview extends StatelessWidget {
  const _AppDragPreview({required this.app});

  final ManagedApp app;

  @override
  Widget build(BuildContext context) => Material(
    color: Colors.transparent,
    child: _RoundedAppIcon(app: app, size: 62),
  );
}

class _RoundedAppIcon extends StatelessWidget {
  const _RoundedAppIcon({required this.app, required this.size});

  final ManagedApp app;
  final double size;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final icon = app.iconPng;
    return ClipRRect(
      borderRadius: BorderRadius.circular(size * .25),
      child: SizedBox.square(
        dimension: size,
        child: icon == null
            ? ColoredBox(
                color: theme.colorScheme.surfaceContainerHigh,
                child: Icon(
                  app.category == AppCategory.video
                      ? Icons.play_arrow_rounded
                      : Icons.groups_rounded,
                  size: size * .48,
                ),
              )
            : Image.memory(
                icon,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => ColoredBox(
                  color: theme.colorScheme.surfaceContainerHigh,
                  child: Icon(Icons.apps_rounded, size: size * .48),
                ),
              ),
      ),
    );
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
