import 'package:aria/core/error/failure.dart';
import 'package:aria/core/error/result.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Result', () {
    test('Ok carries a value', () {
      const Result<int> result = Ok(42);
      expect(result.isOk, isTrue);
      expect(result.isErr, isFalse);
      expect(result.valueOrNull, 42);
      expect(result.failureOrNull, isNull);
    });

    test('Err carries a failure', () {
      const Result<int> result = Err(NotFoundFailure('kosong'));
      expect(result.isErr, isTrue);
      expect(result.valueOrNull, isNull);
      expect(result.failureOrNull?.message, 'kosong');
    });

    test('map transforms only the ok branch', () {
      const Result<int> ok = Ok(2);
      const Result<int> err = Err(NotFoundFailure());

      expect(ok.map((v) => v * 3).valueOrNull, 6);
      expect(err.map((v) => v * 3).isErr, isTrue);
    });

    test('when folds both branches', () {
      const Result<int> ok = Ok(1);
      const Result<int> err = Err(NotFoundFailure());

      expect(ok.when(ok: (v) => 'ok:$v', err: (f) => 'err'), 'ok:1');
      expect(err.when(ok: (v) => 'ok:$v', err: (f) => 'err'), 'err');
    });
  });

  group('failureMessage', () {
    test('surfaces the failure message', () {
      expect(failureMessage(const StorageFailure('penuh')), 'penuh');
    });

    test('falls back for non-Failure errors', () {
      expect(
        failureMessage(StateError('boom')),
        'Terjadi kesalahan saat memuat data.',
      );
    });
  });
}
