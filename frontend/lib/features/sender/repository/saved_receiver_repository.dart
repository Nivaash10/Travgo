import '../../../models/receiver_model.dart';

/// In-memory singleton repository for managing Sender's Saved Receivers.
class SavedReceiverRepository {
  static final SavedReceiverRepository _instance = SavedReceiverRepository._internal();
  factory SavedReceiverRepository() => _instance;
  SavedReceiverRepository._internal();

  final List<ReceiverModel> _receivers = [
    const ReceiverModel(
      id: 'REC-101',
      fullName: 'Priya Sharma',
      phoneNumber: '+91 98765 01234',
      deliveryAddress: 'Flat 402, Sunshine Apartments, Anna Nagar, Chennai',
      landmark: 'Near Tower Park',
      pincode: '600040',
      isSaved: true,
    ),
    const ReceiverModel(
      id: 'REC-102',
      fullName: 'Arun Kumar',
      phoneNumber: '+91 98765 56789',
      deliveryAddress: 'No. 12, 5th Cross, Indiranagar, Bangalore',
      landmark: 'Behind Metro Station',
      pincode: '560038',
      isSaved: true,
    ),
    const ReceiverModel(
      id: 'REC-103',
      fullName: 'Meena Sundaram',
      phoneNumber: '+91 94433 11223',
      deliveryAddress: '15/A North Street, KK Nagar, Madurai',
      landmark: 'Opposite Government Hospital',
      pincode: '625020',
      isSaved: true,
    ),
  ];

  List<ReceiverModel> get receivers => List.unmodifiable(_receivers);

  void addReceiver(ReceiverModel receiver) {
    _receivers.removeWhere((r) => r.id == receiver.id);
    _receivers.insert(0, receiver);
  }

  void removeReceiver(String id) {
    _receivers.removeWhere((r) => r.id == id);
  }

  ReceiverModel? getById(String id) {
    final idx = _receivers.indexWhere((r) => r.id == id);
    if (idx != -1) return _receivers[idx];
    return null;
  }
}
