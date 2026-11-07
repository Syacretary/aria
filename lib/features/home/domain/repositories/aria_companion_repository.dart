import '../../../../core/companion/aria_tone.dart';
import '../../../../core/error/result.dart';
import '../entities/aria_message.dart';

/// Contract for ARIA's own voice on the home feed.
///
/// Separate from [HomeRepository] because it is the one part of Beranda that
/// will eventually come from a backend (or an on-device model), while the rest
/// is local usage data.
abstract interface class AriaCompanionRepository {
  /// The single message ARIA is showing right now.
  Future<Result<AriaMessage>> getCurrentMessage();

  /// Sends a user reply in the chat sheet and returns ARIA's response.
  Future<Result<AriaMessage>> reply(String userMessage);

  /// Records the tone preference so future messages match it.
  Future<Result<void>> setTone(AriaTone tone);
}
