import 'package:flutter/foundation.dart';

import '../error/failure.dart';

/// Backend boundary for ARIA's companion service.
///
/// Stubbed in iteration 1: no networking, no auth. It exists so the companion
/// repository has a real seam to grow into, and so nobody is tempted to call
/// an HTTP client straight from a widget.
abstract interface class ApiClient {
  Future<Map<String, Object?>> get(String path, {Map<String, Object?>? query});

  Future<Map<String, Object?>> post(String path, {Map<String, Object?>? body});
}

/// Returns canned data. Logs the call so the wiring is visible while
/// developing against mocks.
class StubApiClient implements ApiClient {
  const StubApiClient();

  @override
  Future<Map<String, Object?>> get(
    String path, {
    Map<String, Object?>? query,
  }) async {
    if (kDebugMode) debugPrint('[aria:api] GET $path $query');
    return const {};
  }

  @override
  Future<Map<String, Object?>> post(
    String path, {
    Map<String, Object?>? body,
  }) async {
    if (kDebugMode) debugPrint('[aria:api] POST $path $body');
    return const {};
  }
}

/// Placeholder for the real client. Kept next to the stub so switching is a
/// one-line provider override.
class HttpApiClient implements ApiClient {
  const HttpApiClient({required this.baseUrl});

  final String baseUrl;

  @override
  Future<Map<String, Object?>> get(
    String path, {
    Map<String, Object?>? query,
  }) async {
    throw const NetworkFailure('HttpApiClient belum diimplementasikan.');
  }

  @override
  Future<Map<String, Object?>> post(
    String path, {
    Map<String, Object?>? body,
  }) async {
    throw const NetworkFailure('HttpApiClient belum diimplementasikan.');
  }
}
