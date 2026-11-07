import 'package:aria/core/motion/aria_haptics.dart';
import 'package:aria/core/motion/aria_sheet.dart';
import 'package:aria/core/motion/aria_tap.dart';
import 'package:aria/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _host(Widget child) => MaterialApp(
  theme: AppTheme.light(),
  home: Scaffold(body: Center(child: child)),
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AriaTap', () {
    testWidgets('fires onTap and a light haptic exactly once', (tester) async {
      final hapticCalls = <String>[];
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        (call) async {
          if (call.method == 'HapticFeedback.vibrate') {
            hapticCalls.add(call.arguments.toString());
          }
          return null;
        },
      );

      var taps = 0;
      await tester.pumpWidget(
        _host(
          AriaTap(
            onTap: () => taps++,
            child: const SizedBox(width: 100, height: 100),
          ),
        ),
      );

      await tester.tap(find.byType(AriaTap));
      await tester.pumpAndSettle();

      expect(taps, 1);
      expect(hapticCalls, hasLength(1));
      // House rule: feedback must be the softest one available.
      expect(hapticCalls.single, contains('selectionClick'));

      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        null,
      );
    });

    testWidgets('does not fire when disabled', (tester) async {
      var taps = 0;
      await tester.pumpWidget(
        _host(
          AriaTap(
            enabled: false,
            onTap: () => taps++,
            child: const SizedBox(width: 100, height: 100),
          ),
        ),
      );

      await tester.tap(find.byType(AriaTap), warnIfMissed: false);
      await tester.pumpAndSettle();
      expect(taps, 0);
    });

    testWidgets('scales down while pressed', (tester) async {
      await tester.pumpWidget(
        _host(
          AriaTap(onTap: () {}, child: const SizedBox(width: 100, height: 100)),
        ),
      );

      final gesture = await tester.startGesture(
        tester.getCenter(find.byType(AriaTap)),
      );
      await tester.pumpAndSettle();

      final scale = tester.widget<AnimatedScale>(find.byType(AnimatedScale));
      expect(scale.scale, lessThan(1.0));

      await gesture.up();
      await tester.pumpAndSettle();
    });
  });

  group('AriaSheet', () {
    testWidgets('slides content in and resolves the popped value', (
      tester,
    ) async {
      String? received;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light(),
          home: Scaffold(
            body: Builder(
              builder: (context) => Center(
                child: AriaTap.button(
                  onTap: () async {
                    received = await AriaSheet.show<String>(
                      context: context,
                      builder: (_) => AriaTap.button(
                        onTap: () => Navigator.of(context).pop('chosen'),
                        child: const Text('pilih'),
                      ),
                    );
                  },
                  child: const Text('buka'),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('buka'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.text('pilih'), findsOneWidget);

      await tester.tap(find.text('pilih'));
      await tester.pumpAndSettle();

      expect(received, 'chosen');
    });

    testWidgets('option sheet returns the selected value', (tester) async {
      int? received;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light(),
          home: Scaffold(
            body: Builder(
              builder: (context) => Center(
                child: AriaTap.button(
                  onTap: () async {
                    received = await AriaSheet.showOptions<int>(
                      context: context,
                      title: 'Pilih',
                      options: const [
                        AriaSheetOption(value: 1, label: 'Satu'),
                        AriaSheetOption(value: 2, label: 'Dua'),
                      ],
                    );
                  },
                  child: const Text('buka'),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('buka'));
      await tester.pumpAndSettle();

      expect(find.text('Satu'), findsOneWidget);
      await tester.tap(find.text('Dua'));
      await tester.pumpAndSettle();

      expect(received, 2);
    });
  });

  group('AriaHaptics', () {
    testWidgets('every level stays in the light range', (tester) async {
      final calls = <String>[];
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        (call) async {
          if (call.method == 'HapticFeedback.vibrate') {
            calls.add(call.arguments.toString());
          }
          return null;
        },
      );

      await AriaHaptics.tap();
      await AriaHaptics.selection();
      await AriaHaptics.confirm();
      await AriaHaptics.success();
      await AriaHaptics.warning();

      expect(calls, isNotEmpty);
      // The whole point of the house rule: nothing here may be heavy.
      for (final call in calls) {
        expect(call, isNot(contains('heavyImpact')));
        expect(call, isNot(contains('mediumImpact')));
      }

      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        null,
      );
    });
  });
}
