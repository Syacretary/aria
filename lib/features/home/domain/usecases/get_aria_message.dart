import '../../../../core/error/result.dart';
import '../entities/aria_message.dart';
import '../repositories/aria_companion_repository.dart';

/// Fetches the single message ARIA is showing right now.
class GetAriaMessage {
  const GetAriaMessage(this._repository);

  final AriaCompanionRepository _repository;

  Future<Result<AriaMessage>> call() => _repository.getCurrentMessage();
}
