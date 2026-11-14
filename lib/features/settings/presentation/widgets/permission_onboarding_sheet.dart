import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/constants/asset_paths.dart';
import '../../../../core/constants/pref_keys.dart';
import '../../../../core/motion/aria_haptics.dart';
import '../../../../core/motion/aria_sheet.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../domain/entities/permission_status.dart';
import '../providers/settings_providers.dart';

// ── Data ─────────────────────────────────────────────────────────────────────

class _Step {
  const _Step({
    required this.permission,
    required this.icon,
    required this.label,
    required this.caption,
    required this.screenshots,
    required this.actionLabel,
    this.restrictedNote,
  });

  final AppPermission permission;
  final IconData icon;
  final String label;      // ≤ 4 kata
  final String caption;    // 1 kalimat manfaat
  final List<String> screenshots;
  final String actionLabel;
  final String? restrictedNote; // hanya jika perlu warning
}

const _steps = <_Step>[
  _Step(
    permission: AppPermission.usageAccess,
    icon: Icons.bar_chart_rounded,
    label: 'Akses Screen Time',
    caption: 'Menghitung waktu pemakaian & frekuensi buka aplikasi.',
    screenshots: [AssetPaths.permUsageAccess1, AssetPaths.permUsageAccess2],
    actionLabel: 'Izinkan',
  ),
  _Step(
    permission: AppPermission.scrollDetection,
    icon: Icons.swipe_up_rounded,
    label: 'Deteksi Scroll Video',
    caption: 'Menghitung video yang dilewati — tanpa membaca isi layar.',
    screenshots: [AssetPaths.permScroll1, AssetPaths.permScroll2, AssetPaths.permScroll3],
    actionLabel: 'Izinkan',
    restrictedNote:
        'Tombol abu-abu? Buka Info Aplikasi → ⋮ → "Izinkan setelan terbatas".',
  ),
  _Step(
    permission: AppPermission.overlay,
    icon: Icons.picture_in_picture_rounded,
    label: 'Tampil di Atas Aplikasi',
    caption: 'Floating Island muncul di atas video — tidak menghalangi layar.',
    screenshots: [AssetPaths.permDisplayOverApps1, AssetPaths.permDisplayOverApps2],
    actionLabel: 'Izinkan',
  ),
  _Step(
    permission: AppPermission.batteryExemption,
    icon: Icons.battery_charging_full_rounded,
    label: 'Latar Belakang',
    caption: 'Limit & pengingat tetap aktif walau layar mati.',
    screenshots: [AssetPaths.permBackground],
    actionLabel: 'Izinkan',
  ),
];

// ── Sheet entry-point ─────────────────────────────────────────────────────────

class PermissionOnboardingSheet extends ConsumerStatefulWidget {
  const PermissionOnboardingSheet({super.key});

  static Future<void> show(BuildContext context) => AriaSheet.show<void>(
        context: context,
        isDismissible: true,
        enableDrag: true,
        maxHeightFactor: 0.92,
        builder: (_) => const PermissionOnboardingSheet(),
      );

  @override
  ConsumerState<PermissionOnboardingSheet> createState() =>
      _PermissionOnboardingSheetState();
}

class _PermissionOnboardingSheetState
    extends ConsumerState<PermissionOnboardingSheet>
    with WidgetsBindingObserver {
  late final PageController _page;
  int _idx = 0;

  @override
  void initState() {
    super.initState();
    _page = PageController();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _page.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      ref.invalidate(permissionStatesProvider);
    }
  }

  Future<void> _done() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(PrefKeys.permissionOnboardingCompleted, true);
    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _next() async {
    if (_idx < _steps.length - 1) {
      await _page.animateToPage(
        _idx + 1,
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeInOut,
      );
    } else {
      await _done();
    }
  }

  Future<void> _request(_Step step) async {
    unawaited(AriaHaptics.tap());
    final result = await ref.read(checkPermissionsProvider).request(step.permission);
    result.when(
      ok: (_) => ref.invalidate(permissionStatesProvider),
      err: (_) {},
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLight = theme.brightness == Brightness.light;
    final states = ref.watch(permissionStatesProvider).value ?? const {};
    final allDone = _steps.every((s) => states[s.permission] == PermissionState.granted);

    return Container(
      decoration: BoxDecoration(
        color: isLight ? AppColors.parchment : AppColors.espresso,
        borderRadius: AppRadius.sheetTop,
      ),
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            // ── Handle + skip ───────────────────────────────────────────────
            const SizedBox(height: AppSpacing.sm),
            Stack(
              alignment: Alignment.center,
              children: [
                _Handle(),
                Positioned(
                  right: AppSpacing.pageGutter,
                  child: TextButton(
                    onPressed: _done,
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm, vertical: 4),
                      visualDensity: VisualDensity.compact,
                    ),
                    child: Text(
                      allDone ? 'Selesai' : 'Lewati',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),

            // ── Step pill indicators ────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pageGutter),
              child: Row(
                children: [
                  for (int i = 0; i < _steps.length; i++) ...[
                    Expanded(
                      child: _PillIndicator(
                        active: i == _idx,
                        done: states[_steps[i].permission] == PermissionState.granted,
                      ),
                    ),
                    if (i < _steps.length - 1) const SizedBox(width: 6),
                  ],
                ],
              ),
            ),

            // ── Page content ────────────────────────────────────────────────
            Expanded(
              child: PageView.builder(
                controller: _page,
                itemCount: _steps.length,
                onPageChanged: (i) => setState(() => _idx = i),
                itemBuilder: (_, i) {
                  final step = _steps[i];
                  final granted = states[step.permission] == PermissionState.granted;
                  return _StepCard(
                    step: step,
                    granted: granted,
                    onRequest: () => _request(step),
                  );
                },
              ),
            ),

            // ── Bottom action ───────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.pageGutter, 0,
                AppSpacing.pageGutter, AppSpacing.lg,
              ),
              child: _BottomBar(
                step: _steps[_idx],
                granted: states[_steps[_idx].permission] == PermissionState.granted,
                isLast: _idx == _steps.length - 1,
                onRequest: () => _request(_steps[_idx]),
                onNext: _next,
                onDone: _done,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Handle ────────────────────────────────────────────────────────────────────

class _Handle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 4,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.15),
        borderRadius: AppRadius.pill,
      ),
    );
  }
}

// ── Pill indicator ────────────────────────────────────────────────────────────

class _PillIndicator extends StatelessWidget {
  const _PillIndicator({required this.active, required this.done});
  final bool active;
  final bool done;

  @override
  Widget build(BuildContext context) {
    final color = done
        ? AppColors.win
        : active
            ? Theme.of(context).colorScheme.primary
            : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.12);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      height: 5,
      decoration: BoxDecoration(color: color, borderRadius: AppRadius.pill),
    );
  }
}

// ── Step card — the main visual content ───────────────────────────────────────

class _StepCard extends StatelessWidget {
  const _StepCard({
    required this.step,
    required this.granted,
    required this.onRequest,
  });

  final _Step step;
  final bool granted;
  final VoidCallback onRequest;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.pageGutter, AppSpacing.md,
        AppSpacing.pageGutter, AppSpacing.sm,
      ),
      children: [
        // ── Icon + Label + Status in one glanceable row ───────────────────
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: granted
                    ? const Color(0xFFE8F5E9)
                    : theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(AppRadius.lg),
              ),
              child: Icon(
                granted ? Icons.check_rounded : step.icon,
                size: 26,
                color: granted
                    ? const Color(0xFF2E7D32)
                    : theme.colorScheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    step.label,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    granted ? 'Sudah aktif ✓' : step.caption,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: granted
                          ? const Color(0xFF2E7D32)
                          : theme.colorScheme.onSurfaceVariant,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),

        // ── Restricted warning — only for accessibility on Android 13+ ────
        if (step.restrictedNote != null && !granted) ...[
          const SizedBox(height: AppSpacing.md),
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md, vertical: AppSpacing.sm),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF8E6),
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(color: const Color(0xFFFFCC80)),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline_rounded,
                    size: 16, color: Color(0xFFB08A47)),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    step.restrictedNote!,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: const Color(0xFF7A5C1E),
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],

        const SizedBox(height: AppSpacing.lg),

        // ── Screenshots — full visual, horizontal swipeable ───────────────
        SizedBox(
          height: 240,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            clipBehavior: Clip.none,
            itemCount: step.screenshots.length,
            separatorBuilder: (context, index) => const SizedBox(width: AppSpacing.sm),
            itemBuilder: (context, i) => _Screenshot(path: step.screenshots[i]),
          ),
        ),

        const SizedBox(height: AppSpacing.sm),
        // hint to swipe if more than 1
        if (step.screenshots.length > 1)
          Center(
            child: Text(
              'Geser untuk lihat selanjutnya →',
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
      ],
    );
  }
}

// ── Screenshot thumbnail with tap-to-fullscreen ───────────────────────────────

class _Screenshot extends StatelessWidget {
  const _Screenshot({required this.path});
  final String path;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        unawaited(AriaHaptics.tap());
        Navigator.push(
          context,
          MaterialPageRoute<void>(
            builder: (_) => _FullScreen(path: path),
          ),
        );
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Image.asset(
          path,
          fit: BoxFit.cover,
          height: 240,
          errorBuilder: (context, error, stack) => Container(
            width: 140,
            height: 240,
            color: Colors.grey.shade200,
            child: const Icon(Icons.broken_image, color: Colors.grey),
          ),
        ),
      ),
    );
  }
}

class _FullScreen extends StatelessWidget {
  const _FullScreen({required this.path});
  final String path;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: InteractiveViewer(
          maxScale: 4,
          child: Image.asset(path, fit: BoxFit.contain),
        ),
      ),
    );
  }
}

// ── Bottom action bar ─────────────────────────────────────────────────────────

class _BottomBar extends StatelessWidget {
  const _BottomBar({
    required this.step,
    required this.granted,
    required this.isLast,
    required this.onRequest,
    required this.onNext,
    required this.onDone,
  });

  final _Step step;
  final bool granted;
  final bool isLast;
  final VoidCallback onRequest;
  final VoidCallback onNext;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (granted) {
      // Already granted → show Next / Done
      return FilledButton.icon(
        onPressed: isLast ? onDone : onNext,
        icon: Icon(isLast ? Icons.check_rounded : Icons.arrow_forward_rounded,
            size: 18),
        label: Text(isLast ? 'Mulai Gunakan ARIA' : 'Lanjut'),
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.win,
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
        ),
      );
    }

    // Not granted → primary CTA = request, secondary = skip step
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FilledButton.icon(
          onPressed: onRequest,
          icon: const Icon(Icons.lock_open_rounded, size: 18),
          label: Text(step.actionLabel),
          style: FilledButton.styleFrom(
            minimumSize: const Size(double.infinity, 52),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        TextButton(
          onPressed: isLast ? onDone : onNext,
          style: TextButton.styleFrom(
            minimumSize: const Size(double.infinity, 36),
            foregroundColor: theme.colorScheme.onSurfaceVariant,
          ),
          child: Text(
            isLast ? 'Nanti saja' : 'Lewati langkah ini',
            style: const TextStyle(fontSize: 13),
          ),
        ),
      ],
    );
  }
}
