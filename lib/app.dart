import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';

import 'core/config/app_config.dart';
import 'core/presentation/aria_texture.dart';
import 'core/routing/app_router.dart';
import 'core/routing/routes.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_provider.dart';

/// Root widget. Watches the theme mode so switching light/dark in Settings
/// re-renders the whole app instantly.
class AriaApp extends ConsumerStatefulWidget {
  const AriaApp({super.key});

  @override
  ConsumerState<AriaApp> createState() => _AriaAppState();
}

class _AriaAppState extends ConsumerState<AriaApp> {
  static const _checkInChannel = MethodChannel('com.aria.aria/check_ins');

  @override
  void initState() {
    super.initState();
    _checkInChannel.setMethodCallHandler((call) async {
      if (call.method == 'openRoute' && mounted) {
        final route = call.arguments as String?;
        ref
            .read(routerProvider)
            .go(
              route == '/beranda/ngobrol'
                  ? Routes.companionChat
                  : Routes.spotCheck,
            );
      }
    });
  }

  @override
  void dispose() {
    _checkInChannel.setMethodCallHandler(null);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ref = this.ref;
    final router = ref.watch(routerProvider);
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      title: AppConfig.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: themeMode,
      // The texture sits above the router, so ambient light and grain apply to
      // every screen without each page having to opt in.
      builder: (context, child) =>
          AriaTextureLayer(child: child ?? const SizedBox.shrink()),
      routerConfig: router,
      locale: const Locale('id', 'ID'),
      supportedLocales: const [Locale('id', 'ID'), Locale('en', 'US')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
    );
  }
}
