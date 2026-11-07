import 'package:aria/core/presentation/aria_card.dart';
import 'package:aria/core/presentation/aria_texture.dart';
import 'package:aria/core/theme/app_shadows.dart';
import 'package:aria/core/theme/app_spacing.dart';
import 'package:aria/core/theme/app_theme.dart';
import 'package:aria/core/theme/aria_semantic_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Reference renders of the visual system, one file per theme.
///
/// Purpose: make a palette, surface or shadow regression show up as a diff
/// instead of being discovered on a device. The composition is deliberately
/// small and fixed (nested card, ambient wash, grain, shadow swatches) — a
/// whole-feed golden would change every time copy or mock data changes.
///
/// Determinism: Plus Jakarta Sans is vendored in `assets/fonts/` and declared
/// in `pubspec.yaml`, so the render needs no network and produces the same
/// pixels everywhere.
///
/// Regenerate after an intentional design change:
///   flutter test test/golden/theme_render_test.dart --update-goldens
Widget _referenceComposition(ThemeData theme) {
  final colors = theme.brightness == Brightness.light
      ? AriaSemanticColors.light
      : AriaSemanticColors.dark;

  return MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: theme,
    home: AriaTextureLayer(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Padding(
          padding: const EdgeInsets.all(AppSpacing.pageGutter),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Nested card with an eyebrow and a display-size figure.
              AriaCard(
                eyebrow: 'Hari ini',
                trailing: Container(
                  width: 44,
                  height: 22,
                  decoration: BoxDecoration(
                    color: colors.win.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                child: Text('47', style: theme.textTheme.displaySmall),
              ),
              const SizedBox(height: AppSpacing.cardGap),
              // Tappable nested card, covering the interactive variant.
              AriaCard(
                eyebrow: 'Dengan batas',
                title: 'TikTok',
                onTap: () {},
                child: Text(
                  'Sisa 12m dari 1j 30m',
                  style: theme.textTheme.bodyMedium,
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),
              // Shadow swatches, so the tinted elevation appears in the diff.
              Row(
                children: [
                  for (final shadows in [
                    AppShadows.raised(theme.brightness),
                    AppShadows.lifted(theme.brightness),
                  ])
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                        ),
                        child: Container(
                          height: 48,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surfaceContainerLowest,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: shadows,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

void main() {
  // Fonts are loaded from the bundled asset, so nothing here touches the
  // network and no fetch-config hook is needed.

  testWidgets('theme reference — light', (tester) async {
    tester.view.physicalSize = const Size(820, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(_referenceComposition(AppTheme.light()));
    await tester.pumpAndSettle();

    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('reference_light.png'),
    );
  });

  testWidgets('theme reference — dark', (tester) async {
    tester.view.physicalSize = const Size(820, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(_referenceComposition(AppTheme.dark()));
    await tester.pumpAndSettle();

    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('reference_dark.png'),
    );
  });
}
