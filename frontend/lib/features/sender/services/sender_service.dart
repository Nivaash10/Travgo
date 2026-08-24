import '../repositories/sender_repository.dart';
import '../repositories/sender_repository_factory.dart';
import 'sender_api_service.dart';

/// Service boundary for the Sender Module.
///
/// Holds references to [SenderRepository] (provided via [SenderRepositoryFactory])
/// and [SenderApiService] placeholders for Person 1 backend contracts.
class SenderService {
  final SenderRepository repository;
  final SenderApiService apiService;

  SenderService({
    SenderRepository? repository,
    SenderApiService? apiService,
  })  : repository = repository ?? SenderRepositoryFactory.createRepository(),
        apiService = apiService ?? const SenderApiService();
}
