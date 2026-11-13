import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'core/di/provider_observer.dart';
import 'core/di/providers.dart';

/// Runs one-time async setup and builds the root [ProviderScope].
Future<Widget> bootstrapApp(Widget app) async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();

  final container = ProviderContainer(
    observers: const [AriaProviderObserver()],
    overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
  );

  return UncontrolledProviderScope(container: container, child: app);
}

/// Keeps Android's splash screen from masking an unresponsive first frame.
/// Preferences initialize after this small loading surface has been drawn;
/// failures expose a retry action instead of leaving a permanent splash.
class AriaBootstrapGate extends StatefulWidget {
  const AriaBootstrapGate({super.key});

  @override
  State<AriaBootstrapGate> createState() => _AriaBootstrapGateState();
}

class _AriaBootstrapGateState extends State<AriaBootstrapGate> {
  Widget? _app;
  Object? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _initialize());
  }

  Future<void> _initialize() async {
    if (!mounted) return;
    setState(() => _error = null);
    try {
      final app = await bootstrapApp(const AriaApp())
          .timeout(const Duration(seconds: 15));
      if (mounted) setState(() => _app = app);
    } on Object catch (_) {
      if (mounted) setState(() => _error = 'startup');
    }
  }

  @override
  Widget build(BuildContext context) {
    final app = _app;
    if (app != null) return app;

    const ink = Color(0xFF332F2A);
    const canvas = Color(0xFFF8F6F1);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: canvas,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.spa_rounded, size: 42, color: ink),
                const SizedBox(height: 16),
                const Text(
                  'ARIA',
                  style: TextStyle(
                    color: ink,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _error == null
                      ? 'Menyiapkan ruang yang lebih sadar…'
                      : 'ARIA belum siap dibuka. Coba lagi sebentar.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Color(0xFF777168)),
                ),
                if (_error == null) ...[
                  const SizedBox(height: 20),
                  const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Color(0xFF8C7351),
                    ),
                  ),
                ] else ...[
                  const SizedBox(height: 16),
                  FilledButton.tonal(
                    onPressed: _initialize,
                    child: const Text('Coba lagi'),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
