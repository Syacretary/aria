import 'dart:math';

/// Counts content advances in an ARIA-owned vertical feed.
///
/// One finger movement is not automatically one video. A new item is counted
/// only after it becomes the dominant item (at least 65% visible) and remains
/// visible for 450 ms. This filters bounce-back physics, tiny adjustments and
/// duplicate scroll notifications without inspecting another app's content.
class ScrollSessionTracker {
  ScrollSessionTracker({DateTime Function()? clock})
    : _clock = clock ?? DateTime.now;

  final DateTime Function() _clock;
  int _currentIndex = -1;
  DateTime? _candidateSince;
  int? _candidateIndex;
  int _advanced = 0;

  int get videosAdvanced => _advanced;

  /// Call from a feed item's visibility callback. [visibleFraction] must be
  /// between zero and one; [index] is the stable adapter/list position.
  bool observe({required int index, required double visibleFraction}) {
    if (_currentIndex == -1 && visibleFraction >= .65) {
      // The first video is an entry point, not a video the user scrolled past.
      _currentIndex = index;
      return false;
    }
    if (visibleFraction < .65 || index == _currentIndex) {
      _candidateIndex = null;
      _candidateSince = null;
      return false;
    }
    final now = _clock();
    if (_candidateIndex != index) {
      _candidateIndex = index;
      _candidateSince = now;
      return false;
    }
    if (now.difference(_candidateSince!) < const Duration(milliseconds: 450)) {
      return false;
    }
    _currentIndex = index;
    _candidateIndex = null;
    _candidateSince = null;
    _advanced += 1;
    return true;
  }

  /// For a PageView, only accept a settled page; round avoids counting partial
  /// drag positions as another video.
  bool observePage(double page) => observe(
    index: page.round(),
    visibleFraction: max(0, 1 - (page - page.round()).abs()),
  );
}
