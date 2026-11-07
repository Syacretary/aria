import '../../../../core/companion/aria_tone.dart';

/// The kind of follow-up ARIA offers alongside a message.
enum AriaMessageAction {
  /// Opens the companion chat sheet.
  chat,

  /// Sends the user to App Manager to adjust a limit.
  manageLimits,

  /// Opens the 7-day trend detail.
  viewTrend,

  /// Nothing to do — a message with no call to action.
  none,
}

/// One message from ARIA on the home feed.
///
/// Kept small and presentation-agnostic: the tone is conveyed by the copy
/// itself, and [action] tells the UI which button to render.
class AriaMessage {
  const AriaMessage({
    required this.id,
    required this.text,
    required this.createdAt,
    this.action = AriaMessageAction.chat,
    this.actionLabel,
    this.tone = AriaTone.gentle,
  });

  final String id;
  final String text;
  final DateTime createdAt;
  final AriaMessageAction action;

  /// Overrides the default button label for [action].
  final String? actionLabel;

  final AriaTone tone;

  /// "Ngobrol" when the message invites a conversation, otherwise a sensible
  /// default so every message has a clear way forward.
  String get resolvedActionLabel =>
      actionLabel ??
      switch (action) {
        AriaMessageAction.chat => 'Ngobrol',
        AriaMessageAction.manageLimits => 'Atur batas',
        AriaMessageAction.viewTrend => 'Lihat tren',
        AriaMessageAction.none => '',
      };

  bool get hasAction => action != AriaMessageAction.none;
}
