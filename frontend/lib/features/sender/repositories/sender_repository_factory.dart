import 'sender_repository.dart';

/// Factory class for obtaining the active [SenderRepository] instance.
///
/// Defaults to [MockSenderRepository] until Person 1 publishes official backend contracts.
class SenderRepositoryFactory {
  static bool _useRemote = false;

  /// Enable or disable remote repository usage.
  static void setUseRemote(bool enable) {
    _useRemote = enable;
  }

  /// Check if remote repository is currently active.
  static bool get isRemoteActive => _useRemote;

  /// Returns the current active repository implementation.
  static SenderRepository createRepository() {
    if (_useRemote) {
      return RemoteSenderRepository();
    }
    return MockSenderRepository();
  }
}
