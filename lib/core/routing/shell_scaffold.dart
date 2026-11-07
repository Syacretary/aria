import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../motion/aria_haptics.dart';
import '../motion/aria_motion.dart';
import '../motion/aria_tap.dart';
import '../theme/app_spacing.dart';

/// Bottom-navigation shell hosting the three top-level tabs.
///
/// Uses `StatefulShellRoute.indexedStack` so each tab keeps its own scroll
/// position and provider state when the user switches away.
class ShellScaffold extends StatelessWidget {
  const ShellScaffold({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  static const List<_TabSpec> _tabs = [
    _TabSpec(
      label: 'Beranda',
      icon: Icons.home_outlined,
      selectedIcon: Icons.home_rounded,
    ),
    _TabSpec(
      label: 'Kelola',
      icon: Icons.tune_outlined,
      selectedIcon: Icons.tune_rounded,
    ),
    _TabSpec(
      label: 'Pengaturan',
      icon: Icons.settings_outlined,
      selectedIcon: Icons.settings_rounded,
    ),
  ];

  void _onDestinationSelected(int index) {
    // Light haptic on every tab change so navigation feels physical.
    AriaHaptics.selection();
    navigationShell.goBranch(
      index,
      // Tapping the active tab pops that branch back to its root.
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: _AriaNavigationBar(
        tabs: _tabs,
        currentIndex: navigationShell.currentIndex,
        onSelected: _onDestinationSelected,
      ),
    );
  }
}

class _AriaNavigationBar extends StatelessWidget {
  const _AriaNavigationBar({
    required this.tabs,
    required this.currentIndex,
    required this.onSelected,
  });

  final List<_TabSpec> tabs;
  final int currentIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.4),
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.xs,
          ),
          child: Row(
            children: [
              for (var i = 0; i < tabs.length; i++)
                Expanded(
                  child: _NavBarItem(
                    spec: tabs[i],
                    selected: i == currentIndex,
                    onTap: () => onSelected(i),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavBarItem extends StatelessWidget {
  const _NavBarItem({
    required this.spec,
    required this.selected,
    required this.onTap,
  });

  final _TabSpec spec;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = selected
        ? theme.colorScheme.primary
        : theme.colorScheme.onSurfaceVariant;

    return AriaTap(
      onTap: onTap,
      semanticLabel: spec.label,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedSwitcher(
              duration: AriaMotion.medium,
              child: Icon(
                selected ? spec.selectedIcon : spec.icon,
                key: ValueKey(selected),
                size: 24,
                color: color,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              spec.label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: color,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TabSpec {
  const _TabSpec({
    required this.label,
    required this.icon,
    required this.selectedIcon,
  });

  final String label;
  final IconData icon;
  final IconData selectedIcon;
}
