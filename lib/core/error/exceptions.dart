/// Low-level exceptions raised inside the data layer.
///
/// These never leave the data layer: repositories catch them and return a
/// [Failure] via `Result`.
sealed class AppException implements Exception {
  const AppException(this.message, {this.cause});

  final String message;
  final Object? cause;

  @override
  String toString() => '$runtimeType: $message';
}

final class StorageException extends AppException {
  const StorageException(super.message, {super.cause});
}

final class PlatformExceptionWrapper extends AppException {
  const PlatformExceptionWrapper(super.message, {super.cause});
}

final class PermissionException extends AppException {
  const PermissionException(super.message, {super.cause});
}

final class ParseException extends AppException {
  const ParseException(super.message, {super.cause});
}
