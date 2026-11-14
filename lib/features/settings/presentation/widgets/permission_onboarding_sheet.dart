import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/constants/asset_paths.dart';
import '../../../../core/constants/pref_keys.dart';
import '../../../../core/motion/aria_feedback.dart';
import '../../../../core/motion/aria_haptics.dart';
import '../../../../core/motion/aria_sheet.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../domain/entities/permission_status.dart';
import '../providers/settings_providers.dart';

/// One step in the permission onboarding workflow.
class _PermissionStepData {
  const _PermissionStepData({
    required this.permission,
    required this.title,
    required this.subtitle,
    required this.rationale,
    required this.steps,
    required this.screenshots,
    this.restrictedSettingTip,
    this.primaryActionLabel = 'Buka Pengaturan',
  });

  final AppPermission permission;
  final String title;
  final String subtitle;
  final String rationale;
  final List<String> steps;
  final List<String> screenshots;
  final String? restrictedSettingTip;
  final String primaryActionLabel;
}

const _kSteps = <_PermissionStepData>[
  _PermissionStepData(
    permission: AppPermission.usageAccess,
    title: 'Akses Data Pemakaian',
    subtitle: 'Wajib untuk menghitung screen time',
    rationale:
        'Diperlukan agar ARIA dapat mengukur waktu pemakaian dan frekuensi membuka aplikasi sosial media secara lokal tanpa mengirimkan data ke internet.',
    steps: [
      'Ketuk tombol "Buka Pengaturan" di bawah.',
      'Cari dan pilih aplikasi "aria" dari daftar.',
      'Aktifkan switch "Izinkan akses penggunaan" / "Permit usage access".',
    ],
    screenshots: [
      AssetPaths.permUsageAccess1,
      AssetPaths.permUsageAccess2,
    ],
    primaryActionLabel: 'Buka Pengaturan',
  ),
  _PermissionStepData(
    permission: AppPermission.scrollDetection,
    title: 'Deteksi Scroll Video',
    subtitle: 'Wajib untuk Floating Island',
    rationale:
        'ARIA menghitung perkiraan video yang dilewati (TikTok, Reels, Shorts) murni dari sensor gerakan layar (Zero Content Scraping). ARIA tidak pernah membaca teks, postingan, atau percakapan Anda.',
    restrictedSettingTip:
        'Penting di Android 13/14/15: Jika tombol abu-abu ("Setelan dibatasi"), ketuk tombol "Buka Info Aplikasi" di bawah ➔ tap ikon titik tiga (⋮) di pojok kanan atas ➔ pilih "Izinkan setelan terbatas".',
    steps: [
      'Di menu Aksesibilitas, pilih "Aplikasi yang didownload" / "Downloaded apps".',
      'Pilih "ARIA pelacak scroll".',
      'Nyalakan toggle "ARIA pelacak scroll".',
    ],
    screenshots: [
      AssetPaths.permScroll1,
      AssetPaths.permScroll2,
      AssetPaths.permScroll3,
    ],
    primaryActionLabel: 'Buka Aksesibilitas',
  ),
  _PermissionStepData(
    permission: AppPermission.overlay,
    title: 'Tampil di Atas Aplikasi Lain',
    subtitle: 'Wajib untuk pulau pengingat video',
    rationale:
        'Menampilkan Floating Island (counter video mengambang) di sudut atas layar saat Anda berselancar di media sosial agar Anda selalu memiliki cermin waktu.',
    steps: [
      'Ketuk tombol "Buka Pengaturan" di bawah.',
      'Cari dan pilih aplikasi "aria".',
      'Aktifkan "Izinkan ditampilkan di atas aplikasi lain".',
    ],
    screenshots: [
      AssetPaths.permDisplayOverApps1,
      AssetPaths.permDisplayOverApps2,
    ],
    primaryActionLabel: 'Buka Pengaturan',
  ),
  _PermissionStepData(
    permission: AppPermission.batteryExemption,
    title: 'Jalankan di Latar Belakang',
    subtitle: 'Dukungan akurasi & kestabilan',
    rationale:
        'Mencegah sistem Android menghentikan ARIA saat layar mati atau saat Anda berpindah antar aplikasi sehingga limit dan pengingat selalu tepat waktu.',
    steps: [
      'Ketuk tombol "Minta Izin" di bawah.',
      'Pada dialog sistem yang muncul, pilih "Izinkan" / "Allow".',
    ],
    screenshots: [
      AssetPaths.permBackground,
    ],
    primaryActionLabel: 'Minta Izin',
  ),
];

/// Interactive visual permission onboarding flow that guides the user
/// step-by-step through granting permissions with real screenshots.
class PermissionOnboardingSheet extends ConsumerStatefulWidget {
  const PermissionOnboardingSheet({super.key});

  /// Opens the onboarding sheet as a bottom sheet.
  static Future<void> show(BuildContext context) async {
    await AriaSheet.show<void>(
      context: context,
      isDismissible: true,
      enableDrag: true,
      maxHeightFactor: 0.94,
      builder: (_) => const PermissionOnboardingSheet(),
    );
  }

  @override
  ConsumerState<PermissionOnboardingSheet> createState() =>
      _PermissionOnboardingSheetState();
}

class _PermissionOnboardingSheetState
    extends ConsumerState<PermissionOnboardingSheet>
    with WidgetsBindingObserver {
  late final PageController _pageController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _pageController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      ref.invalidate(permissionStatesProvider);
    }
  }

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(PrefKeys.permissionOnboardingCompleted, true);
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  Future<void> _requestCurrentPermission(AppPermission permission) async {
    unawaited(AriaHaptics.tap());
    final result = await ref.read(checkPermissionsProvider).request(permission);
    if (!mounted) return;

    result.when(
      ok: (_) {
        ref.invalidate(permissionStatesProvider);
      },
      err: (failure) {
        AriaFeedback.warning(context, failure.message);
      },
    );
  }

  Future<void> _openAppInfo() async {
    unawaited(AriaHaptics.tap());
    // Trigger Settings.ACTION_APPLICATION_DETAILS_SETTINGS via channel
    final repo = ref.read(permissionSourceProvider);
    try {
      await repo.request(AppPermission.scrollDetection); // fallback
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLight = theme.brightness == Brightness.light;
    final permissionsAsync = ref.watch(permissionStatesProvider);
    final states = permissionsAsync.value ?? const {};

    final currentStep = _kSteps[_currentIndex];
    final isCurrentGranted =
        states[currentStep.permission] == PermissionState.granted;

    // Check if all essential permissions are granted
    final allGranted = _kSteps.every(
      (s) => states[s.permission] == PermissionState.granted,
    );

    return Container(
      decoration: BoxDecoration(
        color: isLight ? AppColors.parchment : AppColors.espresso,
        borderRadius: AppRadius.sheetTop,
      ),
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            // Handle bar
            const SizedBox(height: AppSpacing.sm),
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.2),
                  borderRadius: AppRadius.pill,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // Top Header: Title & Step indicators
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.pageGutter,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Aktivasi Izin ARIA',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.2,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Langkah ${_currentIndex + 1} dari ${_kSteps.length}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: _completeOnboarding,
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                      ),
                      visualDensity: VisualDensity.compact,
                    ),
                    child: Text(
                      allGranted ? 'Selesai' : 'Nanti saja',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Stepper pills
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.pageGutter,
                AppSpacing.sm,
                AppSpacing.pageGutter,
                AppSpacing.md,
              ),
              child: Row(
                children: [
                  for (int i = 0; i < _kSteps.length; i++) ...[
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          _pageController.animateToPage(
                            i,
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        },
                        child: _StepPill(
                          index: i,
                          currentIndex: _currentIndex,
                          isGranted: states[_kSteps[i].permission] ==
                              PermissionState.granted,
                        ),
                      ),
                    ),
                    if (i < _kSteps.length - 1)
                      const SizedBox(width: AppSpacing.xs),
                  ],
                ],
              ),
            ),

            const Divider(height: 1, thickness: 0.5),

            // Step Content PageView
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _kSteps.length,
                onPageChanged: (index) {
                  setState(() => _currentIndex = index);
                },
                itemBuilder: (context, index) {
                  final step = _kSteps[index];
                  final isGranted =
                      states[step.permission] == PermissionState.granted;
                  return _StepContent(
                    step: step,
                    isGranted: isGranted,
                    onRequest: () => _requestCurrentPermission(step.permission),
                    onOpenAppInfo: _openAppInfo,
                  );
                },
              ),
            ),

            const Divider(height: 1, thickness: 0.5),

            // Bottom Navigation & Actions
            Padding(
              padding: const EdgeInsets.all(AppSpacing.pageGutter),
              child: Row(
                children: [
                  if (_currentIndex > 0) ...[
                    OutlinedButton(
                      onPressed: () {
                        _pageController.previousPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.md),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.lg,
                          vertical: AppSpacing.md,
                        ),
                      ),
                      child: const Text('Sebelumnya'),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                  ],
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () {
                        if (!isCurrentGranted) {
                          _requestCurrentPermission(currentStep.permission);
                        } else if (_currentIndex < _kSteps.length - 1) {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        } else {
                          _completeOnboarding();
                        }
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: isCurrentGranted
                            ? AppColors.win
                            : theme.colorScheme.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.md),
                        ),
                        padding: const EdgeInsets.symmetric(
                          vertical: AppSpacing.md,
                        ),
                      ),
                      icon: Icon(
                        isCurrentGranted
                            ? (_currentIndex < _kSteps.length - 1
                                ? Icons.arrow_forward
                                : Icons.check)
                            : Icons.lock_open,
                        size: 18,
                      ),
                      label: Text(
                        isCurrentGranted
                            ? (_currentIndex < _kSteps.length - 1
                                ? 'Izin Aktif — Lanjut'
                                : 'Selesai & Masuk')
                            : currentStep.primaryActionLabel,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
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

/// Pill indicator for one step in the stepper.
class _StepPill extends StatelessWidget {
  const _StepPill({
    required this.index,
    required this.currentIndex,
    required this.isGranted,
  });

  final int index;
  final int currentIndex;
  final bool isGranted;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isSelected = index == currentIndex;

    final color = isGranted
        ? AppColors.win
        : (isSelected
            ? theme.colorScheme.primary
            : theme.colorScheme.onSurface.withValues(alpha: 0.15));

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      height: 6,
      decoration: BoxDecoration(
        color: color,
        borderRadius: AppRadius.pill,
      ),
    );
  }
}

/// Detailed content of a single permission step.
class _StepContent extends StatelessWidget {
  const _StepContent({
    required this.step,
    required this.isGranted,
    required this.onRequest,
    required this.onOpenAppInfo,
  });

  final _PermissionStepData step;
  final bool isGranted;
  final VoidCallback onRequest;
  final VoidCallback onOpenAppInfo;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLight = theme.brightness == Brightness.light;

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.pageGutter),
      children: [
        // Title & status badge
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    step.title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    step.subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            _StatusBadge(isGranted: isGranted),
          ],
        ),

        const SizedBox(height: AppSpacing.md),

        // Rationale card (Why ARIA needs it)
        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: isLight
                ? AppColors.paper.withValues(alpha: 0.8)
                : AppColors.espressoRaised,
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(
              color: isLight
                  ? const Color(0x1F9A783E)
                  : const Color(0x2E7FA99C),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.privacy_tip_outlined,
                size: 20,
                color: isLight ? AppColors.sage : AppColors.sageSoft,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  step.rationale,
                  style: theme.textTheme.bodySmall?.copyWith(
                    height: 1.45,
                    color: isLight ? AppColors.ink : AppColors.inkLight,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Restricted Setting Warning (for Android 13/14/15 accessibility)
        if (step.restrictedSettingTip != null && !isGranted) ...[
          const SizedBox(height: AppSpacing.sm),
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: isLight
                  ? const Color(0xFFFFF7E6)
                  : const Color(0xFF332717),
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(
                color: const Color(0xFFD4A038).withValues(alpha: 0.5),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.warning_amber_rounded,
                      size: 18,
                      color: Color(0xFFB08A47),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      'Tombol Abu-abu? (Setelan Dibatasi)',
                      style: theme.textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFFB08A47),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  step.restrictedSettingTip!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    height: 1.4,
                    fontSize: 12,
                    color: isLight ? AppColors.ink : AppColors.inkLight,
                  ),
                ),
              ],
            ),
          ),
        ],

        const SizedBox(height: AppSpacing.lg),

        // Tutorial Steps
        Text(
          'Cara Mengaktifkan:',
          style: theme.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        for (int i = 0; i < step.steps.length; i++) ...[
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 3),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 20,
                  height: 20,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '${i + 1}',
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.onPrimaryContainer,
                      fontSize: 11,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    step.steps[i],
                    style: theme.textTheme.bodySmall?.copyWith(
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],

        const SizedBox(height: AppSpacing.lg),

        // Visual Screenshots Section
        Row(
          children: [
            Text(
              'Panduan Tampilan UI:',
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const Spacer(),
            Text(
              'Ketuk gambar untuk memperbesar',
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontSize: 11,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),

        // Horizontal Gallery of Screenshots
        SizedBox(
          height: 190,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: step.screenshots.length,
            separatorBuilder: (context, index) =>
                const SizedBox(width: AppSpacing.sm),
            itemBuilder: (context, index) {
              final path = step.screenshots[index];
              return _ScreenshotThumbnail(
                assetPath: path,
                stepNumber: index + 1,
                totalSteps: step.screenshots.length,
              );
            },
          ),
        ),

        const SizedBox(height: AppSpacing.md),
      ],
    );
  }
}

/// Status badge showing whether the permission is granted or missing.
class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.isGranted});

  final bool isGranted;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (isGranted) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFFE8F5E9),
          borderRadius: AppRadius.pill,
          border: Border.all(color: const Color(0xFF81C784)),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle, size: 14, color: Color(0xFF2E7D32)),
            SizedBox(width: 4),
            Text(
              'Sudah Aktif',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Color(0xFF2E7D32),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3E0),
        borderRadius: AppRadius.pill,
        border: Border.all(color: const Color(0xFFFFB74D)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.radio_button_unchecked,
            size: 14,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(width: 4),
          Text(
            'Belum Aktif',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}

/// Thumbnail of a permission tutorial screenshot with tap-to-zoom support.
class _ScreenshotThumbnail extends StatelessWidget {
  const _ScreenshotThumbnail({
    required this.assetPath,
    required this.stepNumber,
    required this.totalSteps,
  });

  final String assetPath;
  final int stepNumber;
  final int totalSteps;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        unawaited(AriaHaptics.tap());
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => _FullScreenImageViewer(assetPath: assetPath),
          ),
        );
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: Theme.of(context).colorScheme.outlineVariant,
              width: 1,
            ),
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: Stack(
            children: [
              Image.asset(
                assetPath,
                fit: BoxFit.cover,
                width: 160,
                height: 190,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: 160,
                  height: 190,
                  color: Colors.grey.shade200,
                  child: const Center(
                    child: Icon(Icons.broken_image, color: Colors.grey),
                  ),
                ),
              ),
              Positioned(
                bottom: 6,
                right: 6,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.65),
                    borderRadius: AppRadius.pill,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.zoom_in, color: Colors.white, size: 12),
                      const SizedBox(width: 2),
                      Text(
                        '$stepNumber/$totalSteps',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
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

/// Fullscreen zoomable image viewer for inspecting UI screenshot details.
class _FullScreenImageViewer extends StatelessWidget {
  const _FullScreenImageViewer({required this.assetPath});

  final String assetPath;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Panduan Tampilan',
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
      ),
      body: Center(
        child: InteractiveViewer(
          minScale: 0.8,
          maxScale: 4.0,
          child: Image.asset(assetPath, fit: BoxFit.contain),
        ),
      ),
    );
  }
}
