import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/error/failure.dart';
import '../../../core/motion/aria_feedback.dart';
import '../../../core/motion/aria_tap.dart';
import '../../../core/presentation/aria_scaffold.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/routing/routes.dart';
import '../../../core/utils/date_x.dart';
import '../../settings/domain/entities/permission_status.dart';
import '../../settings/presentation/providers/settings_providers.dart';
import '../data/spot_check_notifications.dart';
import '../data/spot_check_store.dart';
import '../domain/spot_check_models.dart';
import 'spot_check_providers.dart';

class SpotCheckPage extends ConsumerWidget {
  const SpotCheckPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final overview = ref.watch(spotCheckOverviewProvider);
    return AriaScaffold(
      title: 'Check-in singkat',
      subtitle: 'Kenali ritmemu, tanpa penilaian',
      child: overview.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text(failureMessage(error))),
        data: (data) => _CheckInContent(overview: data),
      ),
    );
  }
}

class _CheckInContent extends ConsumerWidget {
  const _CheckInContent({required this.overview});
  final SpotCheckOverview overview;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final sessions = overview.sessions;
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.pageGutter,
        0,
        AppSpacing.pageGutter,
        AppSpacing.huge,
      ),
      children: [
        Container(
          padding: const EdgeInsets.all(AppSpacing.xl),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerLow,
            borderRadius: AppRadius.shellBorder,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.spa_outlined, color: theme.colorScheme.primary),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    'Ruang untuk berhenti sejenak',
                    style: theme.textTheme.titleMedium,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                '5 pertanyaan singkat tentang perasaan, fokus, dan ingatan. Tidak ada nilai baik atau buruk.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              _TrendPill(trend: overview.trend),
              const SizedBox(height: AppSpacing.lg),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () => context.push(Routes.spotCheckTest),
                  icon: const Icon(Icons.play_arrow_rounded),
                  label: const Text('Mulai check-in'),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.cardGap),
        _ReminderCard(preferences: overview.preferences),
        const SizedBox(height: AppSpacing.cardGap),
        Row(
          children: [
            Expanded(
              child: Text(
                'Jejak refleksimu',
                style: theme.textTheme.titleMedium,
              ),
            ),
            Text('${sessions.length}', style: theme.textTheme.labelLarge),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        if (sessions
                .where((session) => session.wellbeingLevel != null)
                .length >=
            2) ...[
          _SelfRatingTrend(sessions: sessions),
          const SizedBox(height: AppSpacing.md),
        ],
        if (sessions.isEmpty)
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              border: Border.all(
                color: theme.colorScheme.outlineVariant.withValues(alpha: .5),
              ),
              borderRadius: AppRadius.shellBorder,
            ),
            child: Text(
              'Check-in yang selesai akan muncul di sini. Jawabanmu hanya tersimpan di perangkat ini.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          )
        else
          for (final session in sessions.take(8)) ...[
            _SessionTile(session: session),
            const SizedBox(height: AppSpacing.sm),
          ],
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Refleksi ini bersifat indikatif dan bukan tes kesehatan atau diagnosis. Data tidak dikirim ke mana pun.',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            height: 1.4,
          ),
        ),
      ],
    );
  }
}

class _SelfRatingTrend extends StatelessWidget {
  const _SelfRatingTrend({required this.sessions});
  final List<SpotCheckSession> sessions;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ratings = sessions
        .where((session) => session.wellbeingLevel != null)
        .take(5)
        .toList(growable: false);
    final current = ratings.first.wellbeingLevel!;
    final previous = ratings.last.wellbeingLevel!;
    final message = current - previous >= 1
        ? 'Kesanmu belakangan membaik'
        : previous - current >= 1
        ? 'Belakangan terasa lebih berat; perhatikan apa yang mungkin membantu'
        : 'Kesanmu relatif serupa di check-in terakhir';
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withValues(alpha: .35),
        borderRadius: AppRadius.shellBorder,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Tren perasaanmu', style: theme.textTheme.titleSmall),
          const SizedBox(height: AppSpacing.xs),
          Text(message, style: theme.textTheme.bodySmall),
          const SizedBox(height: AppSpacing.md),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              for (final session in ratings.reversed) ...[
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    child: Container(
                      height: 12 + session.wellbeingLevel! * 8,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withValues(
                          alpha: .35 + session.wellbeingLevel! * .1,
                        ),
                        borderRadius: AppRadius.pill,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Gambaran pribadi dari jawabanmu, bukan ukuran klinis.',
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _ReminderCard extends ConsumerWidget {
  const _ReminderCard({required this.preferences});
  final SpotCheckPreferences preferences;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: AppRadius.shellBorder,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.notifications_active_outlined),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pengingat berkala',
                      style: theme.textTheme.titleSmall,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Sekali setiap ${preferences.intervalDays} hari',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Switch.adaptive(
                value: preferences.enabled,
                onChanged: (value) => _setEnabled(context, ref, value),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            children: [3, 7]
                .map(
                  (days) => ChoiceChip(
                    label: Text(days == 7 ? 'Mingguan' : 'Setiap 3 hari'),
                    selected: preferences.intervalDays == days,
                    onSelected: (_) => _setInterval(context, ref, days),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Notifikasi hanya mengajakmu membuka refleksi. Kamu bisa mematikannya kapan saja.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _setEnabled(
    BuildContext context,
    WidgetRef ref,
    bool enabled,
  ) async {
    final store = ref.read(spotCheckStoreProvider);
    final interval = preferences.intervalDays;
    if (enabled) {
      var granted = await SpotCheckNotifications.notificationsGranted();
      if (!granted) {
        await ref
            .read(checkPermissionsProvider)
            .request(AppPermission.notifications);
        granted = await SpotCheckNotifications.notificationsGranted();
      }
      if (!granted) {
        if (context.mounted) {
          AriaFeedback.info(
            context,
            'Izin notifikasi diperlukan untuk pengingat berkala.',
          );
        }
        return;
      }
      await store.savePreferences(enabled: true, intervalDays: interval);
      await SpotCheckNotifications.schedule(interval);
    } else {
      await store.savePreferences(enabled: false, intervalDays: interval);
      await SpotCheckNotifications.cancel();
    }
    ref.invalidate(spotCheckOverviewProvider);
  }

  Future<void> _setInterval(
    BuildContext context,
    WidgetRef ref,
    int days,
  ) async {
    final store = ref.read(spotCheckStoreProvider);
    await store.savePreferences(
      enabled: preferences.enabled,
      intervalDays: days,
    );
    if (preferences.enabled) await SpotCheckNotifications.schedule(days);
    ref.invalidate(spotCheckOverviewProvider);
  }
}

class _TrendPill extends StatelessWidget {
  const _TrendPill({required this.trend});
  final UsageTrend trend;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final (icon, label, detail) = switch (trend) {
      UsageTrend.decreasing => (
        Icons.south_rounded,
        'Sedang menurun',
        'dibanding beberapa hari sebelumnya',
      ),
      UsageTrend.increasing => (
        Icons.north_rounded,
        'Sedang meningkat',
        'kita lihat apa yang mungkin memengaruhi',
      ),
      UsageTrend.steady => (
        Icons.horizontal_rule_rounded,
        'Cenderung konsisten',
        'ritme belakangan ini relatif sama',
      ),
      UsageTrend.unknown => (
        Icons.more_horiz_rounded,
        'Belum cukup data',
        'jawab check-in tanpa asumsi tren',
      ),
    };
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: .62),
        borderRadius: AppRadius.pill,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 17, color: theme.colorScheme.primary),
          const SizedBox(width: AppSpacing.xs),
          Flexible(
            child: Text('$label · $detail', style: theme.textTheme.labelSmall),
          ),
        ],
      ),
    );
  }
}

class _SessionTile extends StatelessWidget {
  const _SessionTile({required this.session});
  final SpotCheckSession session;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final rating = session.answers
        .where((answer) => answer.promptId == 'wellbeing')
        .firstOrNull;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Row(
        children: [
          Icon(
            Icons.check_circle_outline_rounded,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  session.completedAt.longDateId,
                  style: theme.textTheme.labelLarge,
                ),
                Text(
                  rating == null
                      ? 'Refleksi selesai'
                      : 'Perasaan: ${rating.value}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          if (session.focusTaskCount > 0)
            Text(
              '${session.focusScore}/${session.focusTaskCount}',
              style: theme.textTheme.labelMedium,
            ),
        ],
      ),
    );
  }
}
