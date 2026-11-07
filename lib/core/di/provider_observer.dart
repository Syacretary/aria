import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Logs provider lifecycle events in debug builds.
///
/// Invaluable when a feature suddenly rebuilds 40 times: the output shows
/// exactly which provider changed and why.
final class AriaProviderObserver extends ProviderObserver {
  const AriaProviderObserver();

  @override
  void didUpdateProvider(
    ProviderObserverContext context,
    Object? previousValue,
    Object? newValue,
  ) {
    if (!kDebugMode) return;
    debugPrint(
      '[aria:provider] ${context.provider.name ?? context.provider.runtimeType} updated',
    );
  }

  @override
  void providerDidFail(
    ProviderObserverContext context,
    Object error,
    StackTrace stackTrace,
  ) {
    debugPrint(
      '[aria:provider] ${context.provider.name ?? context.provider.runtimeType} FAILED: $error',
    );
  }
}
