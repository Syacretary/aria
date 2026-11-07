/// Central asset paths. Empty in iteration 1 (icons come from Material);
/// kept so adding assets never means hunting for string literals.
abstract final class AssetPaths {
  static const String _images = 'assets/images';
  static const String _icons = 'assets/icons';

  static const String ariaAvatar = '$_images/aria_avatar.png';
  static const String emptyState = '$_images/empty_state.png';
  static const String appFallbackIcon = '$_icons/app_fallback.svg';
}
