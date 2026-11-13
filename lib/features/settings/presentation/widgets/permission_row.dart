import 'package:flutter/material.dart';

import '../../../../core/motion/aria_tap.dart';
import '../../../../core/presentation/aria_section_header.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../domain/entities/permission_status.dart';

/// One permission, with its current state and the right action.
///
/// The action differs by permission: two of them can only be granted by the user
/// visiting a system screen, so the row says "Buka pengaturan" instead of
/// offering a request that would silently fail.
class PermissionRow extends StatelessWidget {
  const PermissionRow({
    super.key,
    required this.permission,
    required this.state,
    required this.onRequest,
  });

  final AppPermission permission;
  final PermissionState state;
  final VoidCallback onRequest;

  IconData get _icon => switch (permission) {
    AppPermission.usageAccess => Icons.bar_chart_rounded,
    AppPermission.scrollDetection => Icons.swipe_up_alt_rounded,
    AppPermission.notifications => Icons.notifications_none_rounded,
    AppPermission.overlay => Icons.layers_outlined,
    AppPermission.batteryExemption => Icons.battery_saver_outlined,
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final granted = state.isGranted;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: AppSpacing.lg,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: granted
                  ? theme.colorScheme.primaryContainer
                  : theme.colorScheme.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(AppRadius.xs),
            ),
            child: Icon(
              _icon,
              size: 16,
              color: granted
                  ? theme.colorScheme.onPrimaryContainer
                  : theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        permission.label,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    if (permission.isRequired && !granted) ...[
                      const SizedBox(width: AppSpacing.sm),
                      const AriaTag(label: 'wajib', color: Color(0xFFB0574B)),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  permission.rationale,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                _StatusAndAction(
                  permission: permission,
                  state: state,
                  onRequest: onRequest,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusAndAction extends StatelessWidget {
  const _StatusAndAction({
    required this.permission,
    required this.state,
    required this.onRequest,
  });

  final AppPermission permission;
  final PermissionState state;
  final VoidCallback onRequest;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (state.isGranted) {
      return Row(
        children: [
          Icon(
            Icons.check_circle_rounded,
            size: 14,
            color: theme.colorScheme.tertiary,
          ),
          const SizedBox(width: AppSpacing.xs),
          Text(
            state.label,
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.tertiary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      );
    }

    if (state == PermissionState.restricted) {
      return Text(
        'Tidak tersedia di perangkat ini',
        style: theme.textTheme.labelMedium?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      );
    }

    final label = permission.requiresManualGrant
        ? 'Buka pengaturan'
        : 'Izinkan';

    return AriaTap.button(
      onTap: onRequest,
      borderRadius: AppRadius.pill,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          border: Border.all(color: theme.colorScheme.outlineVariant),
          borderRadius: AppRadius.pill,
        ),
        child: Text(
          label,
          style: theme.textTheme.labelMedium?.copyWith(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
