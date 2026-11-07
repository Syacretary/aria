import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/motion/aria_tap.dart';
import '../../../../core/presentation/aria_loading.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/aria_semantic_colors.dart';
import '../../domain/entities/aria_message.dart';
import '../providers/home_providers.dart';
import 'ngobrol_sheet.dart';

/// ARIA's own voice on the feed: one message plus its follow-up action.
///
/// Visually distinct without being a different colour language: the surface is
/// a warm tint, the border is a hairline of the same hue, and the avatar is a
/// squircle rather than a circle (the audit flags circles-everywhere as a
/// generic tell).
class AriaMessageCard extends ConsumerWidget {
  const AriaMessageCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final message = ref.watch(ariaMessageProvider);

    return message.when(
      loading: () => const AriaVoiceCard(child: AriaSkeletonLines(lines: 4)),
      error: (error, _) => AriaVoiceCard(
        child: Text(
          failureMessage(error),
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ),
      data: (data) => _Content(message: data),
    );
  }
}

class _Content extends StatelessWidget {
  const _Content({required this.message});

  final AriaMessage message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AriaVoiceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const _AriaAvatar(),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('ARIA', style: theme.textTheme.titleMedium),
                    const SizedBox(height: 1),
                    Text(
                      'Pendampingmu',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        letterSpacing: 0.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          Text(
            message.text,
            style: theme.textTheme.bodyLarge?.copyWith(height: 1.6),
          ),
          if (message.hasAction) ...[
            const SizedBox(height: AppSpacing.xl),
            Align(
              alignment: Alignment.centerLeft,
              child: _NgobrolButton(message: message),
            ),
          ],
        ],
      ),
    );
  }
}

/// The "Ngobrol" button.
///
/// Uses the button-in-button pattern: the trailing icon sits inside its own
/// circular well, flush with the button's inner padding, so the icon and label
/// read as one machined object rather than an icon parked next to text.
class _NgobrolButton extends StatelessWidget {
  const _NgobrolButton({required this.message});

  final AriaMessage message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.ariaColors;

    return AriaTap.button(
      onTap: () => NgobrolSheet.show(context, initialMessage: message),
      borderRadius: AppRadius.pill,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.companion,
          borderRadius: AppRadius.pill,
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.xl,
            AppSpacing.sm,
            AppSpacing.sm,
            AppSpacing.sm,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                message.resolvedActionLabel,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: theme.colorScheme.onPrimary,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.22),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.arrow_outward_rounded,
                  size: 15,
                  color: theme.colorScheme.onPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The ARIA mark. A squircle with a soft wash and a fine ring — not a plain
/// filled circle.
class _AriaAvatar extends StatelessWidget {
  const _AriaAvatar();

  @override
  Widget build(BuildContext context) {
    final colors = context.ariaColors;
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: colors.companion.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(color: colors.companionBorder),
      ),
      child: Icon(
        Icons.auto_awesome_rounded,
        size: 19,
        color: colors.companion,
      ),
    );
  }
}

/// The tinted surface shared by the loading, error and data states.
///
/// Also uses the nested shell, so the companion card is built the same way as
/// every other card — it just happens to be tinted.
class AriaVoiceCard extends StatelessWidget {
  const AriaVoiceCard({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = context.ariaColors;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.shellWash,
        borderRadius: AppRadius.shellBorder,
        border: Border.all(color: colors.companionBorder),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.shellInset),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: colors.companionSurface,
            borderRadius: AppRadius.innerDefault,
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: child,
          ),
        ),
      ),
    );
  }
}
