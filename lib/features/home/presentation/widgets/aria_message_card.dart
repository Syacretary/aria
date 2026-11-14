import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/motion/aria_tap.dart';
import '../../../../core/presentation/aria_card.dart';
import '../../../../core/presentation/aria_loading.dart';
import '../../../../core/routing/routes.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/aria_semantic_colors.dart';
import '../../domain/entities/aria_message.dart';
import '../providers/home_providers.dart';

/// ARIA's companion card on the feed: message + quick conversation trigger.
/// Minimalist, thoughtful, and inviting.
class AriaMessageCard extends ConsumerWidget {
  const AriaMessageCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final message = ref.watch(ariaMessageProvider);

    return message.when(
      loading: () => const AriaCard(child: AriaSkeletonLines(lines: 3)),
      error: (error, _) => AriaCard(
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
    final colors = context.ariaColors;

    return AriaCard(
      padding: const EdgeInsets.all(AppSpacing.xl),
      color: colors.companionSurface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Avatar, Name & Trailing Action
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: colors.companion.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: Icon(
                  Icons.auto_awesome_rounded,
                  size: 17,
                  color: colors.companion,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ARIA',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.4,
                      ),
                    ),
                    Text(
                      'Catatan Reflektif',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              if (message.hasAction)
                AriaTap.button(
                  onTap: () => context.push(Routes.companionChat),
                  borderRadius: AppRadius.pill,
                  semanticLabel: 'Ngobrol dengan ARIA',
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: colors.companion.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Ngobrol',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: colors.companion,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 3),
                        Icon(
                          Icons.arrow_forward_rounded,
                          size: 12,
                          color: colors.companion,
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          // Message Body
          Text(
            message.text,
            style: theme.textTheme.bodyMedium?.copyWith(
              height: 1.5,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}
