/// Generic state wrapper representing data loading status in the Sender module.
/// 
/// Helps UI components safely handle [loading], [success], [empty], and [error] states.
enum SenderResourceStatus {
  loading,
  success,
  empty,
  error,
}

class SenderResource<T> {
  final SenderResourceStatus status;
  final T? data;
  final String? errorMessage;

  const SenderResource._({
    required this.status,
    this.data,
    this.errorMessage,
  });

  factory SenderResource.loading() {
    return const SenderResource._(status: SenderResourceStatus.loading);
  }

  factory SenderResource.success(T data) {
    return SenderResource._(
      status: SenderResourceStatus.success,
      data: data,
    );
  }

  factory SenderResource.empty() {
    return const SenderResource._(status: SenderResourceStatus.empty);
  }

  factory SenderResource.error(String message) {
    return SenderResource._(
      status: SenderResourceStatus.error,
      errorMessage: message,
    );
  }

  bool get isLoading => status == SenderResourceStatus.loading;
  bool get isSuccess => status == SenderResourceStatus.success;
  bool get isEmpty => status == SenderResourceStatus.empty;
  bool get isError => status == SenderResourceStatus.error;
}
