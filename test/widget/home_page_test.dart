import 'package:aria/core/di/providers.dart';
import 'package:aria/core/theme/app_theme.dart';
import 'package:aria/features/home/presentation/home_page.dart';
import 'package:aria/features/home/presentation/widgets/aria_message_card.dart';
import 'package:aria/features/home/presentation/widgets/daily_summary_card.dart';
import 'package:aria/features/home/presentation/widgets/seven_day_trend_card.dart';
import 'package:aria/features/home/presentation/widgets/todays_wins_card.dart';
import 'package:aria/features/home/presentation/widgets/top_apps_card.dart';
import 'package:aria/features/home/presentation/widgets/usage_period_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<Widget> _home(SharedPreferences prefs) async => ProviderScope(
  overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
  child: MaterialApp(theme: AppTheme.light(), home: const HomePage()),
);

Future<void> _scrollTo(WidgetTester tester, Finder target) async {
  await tester.scrollUntilVisible(
    target,
    240,
    scrollable: find.byType(Scrollable).first,
  );
  await tester.pumpAndSettle();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SharedPreferences prefs;

  setUp(() async {
    // Date formatting needs the locale symbols loaded, exactly as bootstrap
    // does at runtime.
    await initializeDateFormatting('id_ID');
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
  });

  testWidgets('shows all six Beranda blocks', (tester) async {
    await tester.pumpWidget(await _home(prefs));
    await tester.pumpAndSettle();

    // The feed is a lazy ListView, so each block has to be scrolled into view
    // before it exists in the tree.
    expect(find.byType(DailySummaryCard), findsOneWidget);
    expect(find.byType(UsagePeriodCard), findsOneWidget);

    await _scrollTo(tester, find.byType(AriaMessageCard));
    expect(find.byType(AriaMessageCard), findsOneWidget);

    await _scrollTo(tester, find.byType(TodaysWinsCard));
    expect(find.byType(TodaysWinsCard), findsOneWidget);

    await _scrollTo(tester, find.byType(SevenDayTrendCard));
    expect(find.byType(SevenDayTrendCard), findsOneWidget);

    await _scrollTo(tester, find.byType(TopAppsCard));
    expect(find.byType(TopAppsCard), findsOneWidget);
  });

  testWidgets('renders the mock daily numbers', (tester) async {
    await tester.pumpWidget(await _home(prefs));
    await tester.pumpAndSettle();

    expect(find.text('47'), findsOneWidget);
    expect(find.text('video dibuka'), findsOneWidget);
  });

  testWidgets('ARIA message card offers the Ngobrol follow-up', (tester) async {
    await tester.pumpWidget(await _home(prefs));
    await tester.pumpAndSettle();

    await _scrollTo(tester, find.text('Ngobrol'));

    expect(find.text('Ngobrol'), findsOneWidget);
  });

  testWidgets('tapping Ngobrol opens the companion sheet', (tester) async {
    await tester.pumpWidget(await _home(prefs));
    await tester.pumpAndSettle();

    await _scrollTo(tester, find.text('Ngobrol'));

    await tester.tap(find.text('Ngobrol'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('Ngobrol dengan ARIA'), findsOneWidget);
    expect(find.text('Tulis pesan…'), findsOneWidget);
  });

  testWidgets('the trend card renders with its target summary', (tester) async {
    await tester.pumpWidget(await _home(prefs));
    await tester.pumpAndSettle();

    // Move down through the feed in order, which is how the lazy ListView
    // expects to be driven.
    await _scrollTo(tester, find.byType(TodaysWinsCard));
    await _scrollTo(tester, find.byType(SevenDayTrendCard));

    expect(find.byType(SevenDayTrendCard), findsOneWidget);
    expect(find.text('TREN 7 HARI'), findsOneWidget);
  });

  testWidgets('switching the period changes the emphasised figure', (
    tester,
  ) async {
    await tester.pumpWidget(await _home(prefs));
    await tester.pumpAndSettle();

    await _scrollTo(tester, find.byType(UsagePeriodCard));

    // "Hari ini" is the default period, so 23 opens is shown first.
    expect(find.text('23'), findsOneWidget);

    await tester.tap(find.text('Minggu ini'));
    await tester.pumpAndSettle();

    // 164 opens for the week, per the mock data.
    expect(find.text('164'), findsOneWidget);
  });
}
