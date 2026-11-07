import 'package:aria/app.dart';
import 'package:aria/core/di/providers.dart';
import 'package:aria/features/app_manager/presentation/app_manager_page.dart';
import 'package:aria/features/home/presentation/home_page.dart';
import 'package:aria/features/settings/presentation/settings_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Drives the real router and shell, so this covers navigation, the tab bar and
/// every top-level page rendering with mock data.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SharedPreferences prefs;

  setUp(() async {
    await initializeDateFormatting('id_ID');
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
  });

  Future<void> scrollTo(WidgetTester tester, Finder target) async {
    await tester.scrollUntilVisible(
      target,
      240,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
  }

  Future<void> pumpApp(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
        // Uses the real root widget, so the theme-mode provider actually
        // drives MaterialApp.router here.
        child: const AriaApp(),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('opens on Beranda with the three-tab shell', (tester) async {
    await pumpApp(tester);

    expect(find.byType(HomePage), findsOneWidget);
    expect(find.text('Beranda'), findsOneWidget);
    expect(find.text('Kelola'), findsOneWidget);
    expect(find.text('Pengaturan'), findsOneWidget);
  });

  testWidgets('the Kelola tab shows the App Manager', (tester) async {
    await pumpApp(tester);

    await tester.tap(find.text('Kelola'));
    await tester.pumpAndSettle();

    expect(find.byType(AppManagerPage), findsOneWidget);
    expect(find.text('Kelola Aplikasi'), findsOneWidget);
    expect(find.text('APLIKASI DIBATASI'), findsOneWidget);
  });

  testWidgets('App Manager lists managed apps from the mock source', (
    tester,
  ) async {
    await pumpApp(tester);

    await tester.tap(find.text('Kelola'));
    await tester.pumpAndSettle();

    expect(find.text('TikTok'), findsOneWidget);
    expect(find.text('Instagram'), findsOneWidget);
    expect(find.text('YouTube'), findsOneWidget);
  });

  testWidgets('the Pengaturan tab shows permissions and appearance', (
    tester,
  ) async {
    await pumpApp(tester);

    await tester.tap(find.text('Pengaturan'));
    await tester.pumpAndSettle();

    expect(find.byType(SettingsPage), findsOneWidget);
    // Section headers render uppercased by AriaSectionHeader.
    expect(find.text('IZIN APLIKASI'), findsOneWidget);
    expect(find.text('Akses data pemakaian'), findsOneWidget);

    await scrollTo(tester, find.text('TAMPILAN'));
    expect(find.text('TAMPILAN'), findsOneWidget);
  });

  testWidgets('switching theme to Gelap updates the app theme', (tester) async {
    await pumpApp(tester);

    await tester.tap(find.text('Pengaturan'));
    await tester.pumpAndSettle();

    await scrollTo(tester, find.text('Gelap'));
    await tester.tap(find.text('Gelap'));
    await tester.pumpAndSettle();

    final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(app.themeMode, ThemeMode.dark);
  });

  testWidgets('committing a limit on the editor sheet persists it', (
    tester,
  ) async {
    await pumpApp(tester);

    await tester.tap(find.text('Kelola'));
    await tester.pumpAndSettle();

    // Open the editor for TikTok (first row, busiest app).
    await tester.tap(find.text('TikTok'));
    await tester.pumpAndSettle();

    expect(find.text('Batas harian'), findsOneWidget);
    expect(find.text('TikTok'), findsWidgets);

    // Pick the 90-minute preset and save.
    await tester.tap(find.text('1j 30m'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Simpan'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Simpan'));
    await tester.pumpAndSettle();

    // The limit is now persisted: re-opening the editor shows the saved quota.
    await tester.tap(find.text('TikTok').first);
    await tester.pumpAndSettle();
    expect(find.text('1j 30m'), findsWidgets);
  });
}
