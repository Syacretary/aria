/// Domain-level failures. Repositories translate low-level exceptions into
/// these so the presentation layer never sees a `PlatformException`.
sealed class Failure {
  const Failure(this.message, {this.cause});

  final String message;
  final Object? cause;

  @override
  String toString() => '$runtimeType($message)';
}

/// The requested record does not exist.
final class NotFoundFailure extends Failure {
  const NotFoundFailure([super.message = 'Data tidak ditemukan.']);
}

/// Local storage (SharedPreferences, files) failed.
final class StorageFailure extends Failure {
  const StorageFailure([super.message = 'Gagal mengakses penyimpanan lokal.']);
}

/// A platform channel or system API failed (e.g. usage stats unavailable).
final class PlatformFailure extends Failure {
  const PlatformFailure([
    super.message = 'Layanan sistem tidak tersedia di perangkat ini.',
  ]);
}

/// Required permission is missing and cannot be prompted right now.
final class PermissionFailure extends Failure {
  const PermissionFailure([super.message = 'Izin aplikasi belum diberikan.']);
}

/// Network/backend failure. Unused in iteration 1 but part of the contract.
final class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'Tidak dapat menghubungi server.']);
}

/// Anything genuinely unexpected.
final class UnknownFailure extends Failure {
  const UnknownFailure([super.message = 'Terjadi kesalahan tak terduga.']);
}

/// Copy fit for the UI for any thrown error.
///
/// Lives beside [Failure] so every feature gets identical messaging without
/// each one re-implementing the same switch.
String failureMessage(Object error) => switch (error) {
  Failure(:final message) => message,
  _ => 'Terjadi kesalahan saat memuat data.',
};
