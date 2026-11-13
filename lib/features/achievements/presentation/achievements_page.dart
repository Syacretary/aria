import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/pref_keys.dart';
import '../../../core/di/providers.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/aria_semantic_colors.dart';
import '../../home/presentation/providers/home_providers.dart';
import '../data/achievement_progress_store.dart';

final achievementProgressStoreProvider = Provider<AchievementProgressStore>(
  (ref) => AchievementProgressStore(ref.watch(sharedPreferencesProvider)),
);

final achievementProgressProvider = FutureProvider<AchievementProgress>((
  ref,
) async {
  final daily = await ref.watch(dailySummaryProvider.future);
  final preferences = ref.watch(sharedPreferencesProvider);
  return ref
      .watch(achievementProgressStoreProvider)
      .refresh(
        current: daily,
        targetMinutes: preferences.getInt(PrefKeys.dailyTargetMinutes) ?? 180,
      );
});

class AchievementsPage extends ConsumerStatefulWidget {
  const AchievementsPage({super.key});

  @override
  ConsumerState<AchievementsPage> createState() => _AchievementsPageState();

  static const _achievements = <_AchievementSpec>[
    _AchievementSpec(
      id: 'self_control',
      title: 'Self-control',
      description:
          'Keluar dari aplikasi sosial dalam 60 detik setelah membukanya.',
      icon: Icons.self_improvement_rounded,
      countLabel: 'kali kembali dalam 60 detik',
      thresholds: [5, 15, 30, 60, 100],
      levelTitles: [
        'Mulai menyadari',
        'Jeda yang disadari',
        'Penjaga fokus',
        'Pengarah ritme',
        'Kendali yang kuat',
      ],
    ),
    _AchievementSpec(
      id: 'steady_boundary',
      title: 'Menjaga batas',
      description: 'Gunakan media sosial di bawah target pada hari lengkap yang tercatat.',
      icon: Icons.shield_moon_outlined,
      countLabel: 'hari sesuai target',
      thresholds: [3, 7, 14, 30, 60],
      levelTitles: [
        'Batas pertama',
        'Penjaga kebiasaan',
        'Ritme terjaga',
        'Konsisten bertumbuh',
        'Batas jadi pilihan',
      ],
    ),
    _AchievementSpec(
      id: 'lighter_days',
      title: 'Hari lebih ringan',
      description: 'Kurangi waktu sosial setidaknya 10 menit dibanding hari lengkap sebelumnya.',
      icon: Icons.wb_twilight_rounded,
      countLabel: 'hari lebih singkat',
      thresholds: [3, 7, 14, 30, 60],
      levelTitles: [
        'Ruang mulai terasa',
        'Langkah berulang',
        'Lebih banyak ruang',
        'Perubahan menetap',
        'Ritme pilihanmu',
      ],
    ),
    _AchievementSpec(
      id: 'intentional_exit',
      title: 'Keluar dengan sadar',
      description:
          'Ketuk “Tutup aplikasi” pada pengingat saat membuka aplikasi sosial.',
      icon: Icons.logout_rounded,
      countLabel: 'kali memilih keluar',
      thresholds: [3, 10, 25, 50, 100],
      levelTitles: [
        'Pilihan pertama',
        'Makin sadar',
        'Tujuan terjaga',
        'Fokus kembali',
        'Pilihan yang kuat',
      ],
    ),
    _AchievementSpec(
      id: 'completed_pause',
      title: 'Jeda yang dipilih',
      description: 'Selesaikan jeda batas 15 detik, lalu pilih “Tutup jeda”.',
      icon: Icons.spa_outlined,
      countLabel: 'jeda diselesaikan',
      thresholds: [3, 10, 25, 50, 100],
      levelTitles: [
        'Jeda pertama',
        'Ruang untuk memilih',
        'Tenang sejenak',
        'Kebiasaan mindful',
        'Jeda jadi kekuatan',
      ],
    ),
  ];

  static int _countFor(_AchievementSpec spec, AchievementProgress progress) =>
      switch (spec.id) {
        'self_control' => progress.quickSocialReturns,
        'steady_boundary' => progress.daysWithinTarget,
        'lighter_days' => progress.daysReduced,
        'intentional_exit' => progress.intentionalSocialExits,
        'completed_pause' => progress.completedBreathingPauses,
        _ => 0,
      };

  static int _levelFor(_AchievementSpec spec, int count) =>
      spec.thresholds.lastIndexWhere((threshold) => count >= threshold) + 1;

  static void _showDetails(
    BuildContext context,
    _AchievementSpec spec,
    int count,
  ) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      builder: (context) => _BadgeDetails(spec: spec, count: count),
    );
  }
}

class _AchievementsPageState extends ConsumerState<AchievementsPage> {
  @override
  void initState() {
    super.initState();
    ref.invalidate(achievementProgressProvider);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(achievementProgressProvider);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Kembali ke beranda',
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        title: const Text('Pencapaian'),
        centerTitle: true,
      ),
      body: SafeArea(
        top: false,
        child: RefreshIndicator(
          onRefresh: () async {
            ref
              ..invalidate(dailySummaryProvider)
              ..invalidate(achievementProgressProvider);
            await ref.read(achievementProgressProvider.future);
          },
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.pageGutter,
                  AppSpacing.md,
                  AppSpacing.pageGutter,
                  AppSpacing.huge,
                ),
                sliver: SliverToBoxAdapter(
                  child: state.when(
                    loading: () => const _BadgeGridLoading(),
                    error: (error, stack) => Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 48),
                        child: Text(
                          'Pencapaian belum tersedia. Tarik untuk memuat ulang.',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ),
                    data: (progress) {
                      final counts = AchievementsPage._achievements
                          .map(
                            (spec) =>
                                AchievementsPage._countFor(spec, progress),
                          )
                          .toList(growable: false);
                      final unlocked = List.generate(
                        AchievementsPage._achievements.length,
                        (index) =>
                            AchievementsPage._levelFor(
                              AchievementsPage._achievements[index],
                              counts[index],
                            ) >
                            0,
                      ).where((value) => value).length;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(
                              bottom: AppSpacing.md,
                            ),
                            child: Text(
                              '$unlocked dari ${AchievementsPage._achievements.length} badge terbuka',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                          GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: AchievementsPage._achievements.length,
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 3,
                                  mainAxisExtent: 142,
                                  crossAxisSpacing: 10,
                                  mainAxisSpacing: 10,
                                ),
                            itemBuilder: (context, index) {
                              final spec =
                                  AchievementsPage._achievements[index];
                              final count = counts[index];
                              final level = AchievementsPage._levelFor(
                                spec,
                                count,
                              );
                              return _BadgeTile(
                                spec: spec,
                                level: level,
                                onTap: () => AchievementsPage._showDetails(
                                  context,
                                  spec,
                                  count,
                                ),
                              );
                            },
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BadgeTile extends StatelessWidget {
  const _BadgeTile({
    required this.spec,
    required this.level,
    required this.onTap,
  });

  final _AchievementSpec spec;
  final int level;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.ariaColors;
    final unlocked = level > 0;
    final tone = unlocked ? colors.win : theme.colorScheme.onSurfaceVariant;

    return Semantics(
      button: true,
      label: '${spec.title}, ${unlocked ? 'level $level' : 'belum terbuka'}',
      hint: 'Ketuk untuk melihat detail badge',
      child: Material(
        color: theme.colorScheme.surfaceContainerLowest,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          side: BorderSide(color: tone.withValues(alpha: unlocked ? .2 : .1)),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(6, 12, 6, 10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _Medal(icon: spec.icon, unlocked: unlocked, size: 62),
                const SizedBox(height: 8),
                Text(
                  spec.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  unlocked ? 'Level $level' : 'Terkunci',
                  maxLines: 1,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: tone,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BadgeDetails extends StatelessWidget {
  const _BadgeDetails({required this.spec, required this.count});

  final _AchievementSpec spec;
  final int count;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.ariaColors;
    final level = AchievementsPage._levelFor(spec, count);
    final completed = level >= spec.thresholds.length;
    final nextThreshold = completed ? null : spec.thresholds[level];
    final previousThreshold = level == 0 ? 0 : spec.thresholds[level - 1];
    final fraction = completed
        ? 1.0
        : ((count - previousThreshold) / (nextThreshold! - previousThreshold))
              .clamp(0.0, 1.0);

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _Medal(icon: spec.icon, unlocked: level > 0, size: 78),
                const SizedBox(width: AppSpacing.lg),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(spec.title, style: theme.textTheme.headlineSmall),
                      const SizedBox(height: 4),
                      Text(
                        level > 0
                            ? 'Level $level · ${spec.levelTitles[level - 1]}'
                            : 'Belum terbuka',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colors.win,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              spec.description,
              style: theme.textTheme.bodyMedium?.copyWith(height: 1.45),
            ),
            const SizedBox(height: AppSpacing.xl),
            Row(
              children: [
                Expanded(
                  child: Text(
                    completed
                        ? '${spec.thresholds.last}+ ${spec.countLabel}'
                        : '$count dari $nextThreshold ${spec.countLabel}',
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (!completed)
                  Text(
                    'Level ${level + 1}',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: colors.win,
                    ),
                  )
                else
                  Icon(Icons.verified_rounded, color: colors.win),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            ClipRRect(
              borderRadius: AppRadius.pill,
              child: LinearProgressIndicator(
                minHeight: 9,
                value: fraction,
                backgroundColor: colors.win.withValues(alpha: .12),
                valueColor: AlwaysStoppedAnimation(colors.win),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Text('Tahapan badge', style: theme.textTheme.titleSmall),
            const SizedBox(height: AppSpacing.sm),
            for (var index = 0; index < spec.thresholds.length; index++)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                child: Row(
                  children: [
                    Icon(
                      level > index
                          ? Icons.check_circle_rounded
                          : Icons.circle_outlined,
                      size: 18,
                      color: level > index
                          ? colors.win
                          : theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(child: Text(spec.levelTitles[index])),
                    Text(
                      '${spec.thresholds[index]} ${spec.countLabel}',
                      style: theme.textTheme.bodySmall?.copyWith(
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

class _Medal extends StatelessWidget {
  const _Medal({
    required this.icon,
    required this.unlocked,
    required this.size,
  });

  final IconData icon;
  final bool unlocked;
  final double size;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.ariaColors;
    final tone = unlocked ? colors.win : theme.colorScheme.onSurfaceVariant;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: unlocked
            ? colors.winSurface
            : theme.colorScheme.surfaceContainerLow,
        border: Border.all(
          color: tone.withValues(alpha: unlocked ? .52 : .22),
          width: 2,
        ),
        boxShadow: unlocked
            ? [
                BoxShadow(
                  color: tone.withValues(alpha: .12),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Icon(icon, size: size * .43, color: tone),
    );
  }
}

class _BadgeGridLoading extends StatelessWidget {
  const _BadgeGridLoading();

  @override
  Widget build(BuildContext context) => GridView.builder(
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    itemCount: 3,
    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 3,
      mainAxisExtent: 142,
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
    ),
    itemBuilder: (context, index) => const Center(
      child: SizedBox(
        width: 34,
        height: 34,
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
    ),
  );
}

class _AchievementSpec {
  const _AchievementSpec({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.countLabel,
    required this.thresholds,
    required this.levelTitles,
  });

  final String id;
  final String title;
  final String description;
  final IconData icon;
  final String countLabel;
  final List<int> thresholds;
  final List<String> levelTitles;
}
