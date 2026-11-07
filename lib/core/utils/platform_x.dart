import 'dart:io';

import 'package:flutter/foundation.dart';

/// Platform predicates.
///
/// Screentime data is only real on Android; everything else falls back to the
/// mock data source. Features ask these rather than checking
/// `Platform.isAndroid` inline, so the fallback policy lives in one place.
extension PlatformX on Object {
  bool get isAndroid => !kIsWeb && Platform.isAndroid;
  bool get isIOS => !kIsWeb && Platform.isIOS;
  bool get isMobile => isAndroid || isIOS;
}

/// Top-level helpers for call sites that read better without a receiver.
bool get runningOnAndroid => !kIsWeb && Platform.isAndroid;

bool get runningOnMobile => !kIsWeb && (Platform.isAndroid || Platform.isIOS);
