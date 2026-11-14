import 'package:flutter/material.dart';

import '../../../../core/motion/aria_tap.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../domain/entities/permission_status.dart';
import 'settings_section.dart';

/// One permission row, designed to be understood in less than a second.
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

    final content = Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: AppSpacing.md,
      ),
      child: Row(
        children: [
          SettingsIcon(
            icon: _icon,
            color: granted
                ? const Color(0xFF4A7C59)
                : theme.colorScheme.onSurfaceVariant,
            backgroundColor: granted
                ? const Color(0xFF4A7C59).withValues(alpha: 0.12)
                : theme.colorScheme.surfaceContainerHigh,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Row(
              children: [
                Flexible(
                  child: Text(
                    permission.label,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (permission.isRequired && !granted) ...[
                  const SizedBox(width: AppSpacing.xs),
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: Color(0xFFB0574B),
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          _StatusPill(
            permission: permission,
            state: state,
            onRequest: onRequest,
          ),
        ],
      ),
    );

    if (granted || state == PermissionState.restricted) {
      return content;
    }

    return AriaTap.button(onTap: onRequest, child: content);
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({
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
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: const Color(0xFF4A7C59).withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_rounded, size: 12, color: Color(0xFF4A7C59)),
            SizedBox(width: 3),
            Text(
              'Aktif',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Color(0xFF4A7C59),
              ),
            ),
          ],
        ),
      );
    }

    if (state == PermissionState.restricted) {
      return Text(
        'Tidak didukung',
        style: theme.textTheme.labelSmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      );
    }

    final isRequired = permission.isRequired;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: isRequired
            ? const Color(0xFFB0574B)
            : theme.colorScheme.primary,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        permission.requiresManualGrant ? 'Buka' : 'Izinkan',
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    );
  }
}
