import 'package:aria/core/utils/date_x.dart';
import 'package:aria/core/utils/duration_x.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('id_ID');
  });

  group('DurationX', () {
    test('compact format correctly formats different durations', () {
      expect(Duration.zero.compact, '0m');
      expect(const Duration(minutes: 45).compact, '45m');
      expect(const Duration(minutes: 60).compact, '1j');
      expect(const Duration(minutes: 75).compact, '1j 15m');
      expect(const Duration(hours: 2).compact, '2j');
      expect(const Duration(hours: 26).compact, '1h 2j');
    });

    test('inWordsId returns readable Indonesian descriptions', () {
      expect(const Duration(minutes: 30).inWordsId, '30 menit');
      expect(const Duration(hours: 2).inWordsId, '2 jam');
      expect(const Duration(hours: 2, minutes: 15).inWordsId, '2 jam 15 menit');
    });

    test('ratioTo clamps and handles zero limit safely', () {
      expect(const Duration(minutes: 30).ratioTo(Duration.zero), 0.0);
      expect(
        const Duration(minutes: 30).ratioTo(const Duration(minutes: 60)),
        0.5,
      );
      expect(
        const Duration(minutes: 90).ratioTo(const Duration(minutes: 60)),
        1.0,
      );
    });
  });

  group('DateX', () {
    test('startOfDay, endOfDay, and isSameDayAs work accurately', () {
      final date = DateTime(2026, 11, 7, 15, 30, 45);
      final start = date.startOfDay;
      final end = date.endOfDay;

      expect(start, DateTime(2026, 11, 7, 0, 0, 0));
      expect(end, DateTime(2026, 11, 8, 0, 0, 0));
      expect(date.isSameDayAs(DateTime(2026, 11, 7, 23, 59)), isTrue);
      expect(date.isSameDayAs(DateTime(2026, 11, 8, 0, 0)), isFalse);
    });

    test('startOfWeek returns Monday midnight', () {
      // 2026-11-07 is Saturday
      final date = DateTime(2026, 11, 7, 12, 0);
      final monday = date.startOfWeek;
      expect(monday.weekday, DateTime.monday);
      expect(monday, DateTime(2026, 11, 2));
    });

    test('formatting extensions produce valid Indonesian text', () {
      final date = DateTime(2026, 11, 7, 14, 30);
      expect(date.shortWeekdayId, isNotEmpty);
      expect(date.shortDateId, contains('Nov'));
      expect(date.longDateId, contains('November 2026'));
      expect(date.shortTimeId, '14.30');
    });
  });
}
