/// One accomplishment logged today.
///
/// "Wins" are deliberately framed as choices the user made, not metrics: the
/// point is to reinforce agency, not to gamify restraint.
class WinEntry {
  const WinEntry({
    required this.id,
    required this.label,
    required this.detail,
    required this.occurredAt,
    this.icon = WinKind.delay,
  });

  final String id;

  /// Short headline, e.g. "Menunda TikTok".
  final String label;

  /// Supporting line, e.g. "3 kali hari ini".
  final String detail;

  final DateTime occurredAt;
  final WinKind icon;
}

/// Which glyph represents the win.
enum WinKind { delay, limitKept, offline, focus, prayer }
