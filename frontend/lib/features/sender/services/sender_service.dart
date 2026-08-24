import '../repositories/sender_repository.dart';
import 'sender_api_service.dart';

/// Service boundary for the Sender Module.
///
/// Holds references to [SenderRepository] (defaulting to [MockSenderRepository])
/// and [SenderApiService] placeholders for Person 1 backend contracts.
class SenderService {
  final SenderRepository repository;
  final SenderApiService apiService;

  SenderService({
    SenderRepository? repository,
    SenderApiService? apiService,
  })  : repository = repository ?? MockSenderRepository(),
        apiService = apiService ?? const SenderApiService();
}
