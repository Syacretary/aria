/// Central asset paths. Empty in iteration 1 (icons come from Material);
/// kept so adding assets never means hunting for string literals.
abstract final class AssetPaths {
  static const String _images = 'assets/images';
  static const String _icons = 'assets/icons';

  static const String ariaAvatar = '$_images/aria_avatar.png';
  static const String emptyState = '$_images/empty_state.png';
  static const String appFallbackIcon = '$_icons/app_fallback.svg';

  static const String _permissions = 'assets/permissions';
  static const String permBackground = '$_permissions/background.jpg';
  static const String permDisplayOverApps1 =
      '$_permissions/displayoverotherapps1.jpg';
  static const String permDisplayOverApps2 =
      '$_permissions/displayotherapps2.jpg';
  static const String permScroll1 = '$_permissions/scroll1.jpg';
  static const String permScroll2 = '$_permissions/scroll2.jpg';
  static const String permScroll3 = '$_permissions/scroll3.jpg';
  static const String permUsageAccess1 = '$_permissions/usageaccess1.jpg';
  static const String permUsageAccess2 = '$_permissions/usageaccess2.jpg';
}
