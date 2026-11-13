import 'dart:typed_data';

class InstalledSocialApp {
  const InstalledSocialApp({
    required this.packageName,
    required this.appName,
    this.iconPng,
  });

  final String packageName;
  final String appName;
  final Uint8List? iconPng;
}
