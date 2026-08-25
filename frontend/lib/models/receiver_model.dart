/// Data model representing a parcel Receiver in TRAVGO.
class ReceiverModel {
  final String id;
  final String fullName;
  final String phoneNumber;
  final String deliveryAddress;
  final String? landmark;
  final String? pincode;
  final bool isSaved;

  const ReceiverModel({
    required this.id,
    required this.fullName,
    required this.phoneNumber,
    required this.deliveryAddress,
    this.landmark,
    this.pincode,
    this.isSaved = true,
  });

  ReceiverModel copyWith({
    String? id,
    String? fullName,
    String? phoneNumber,
    String? deliveryAddress,
    String? landmark,
    String? pincode,
    bool? isSaved,
  }) {
    return ReceiverModel(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
      landmark: landmark ?? this.landmark,
      pincode: pincode ?? this.pincode,
      isSaved: isSaved ?? this.isSaved,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'phoneNumber': phoneNumber,
      'deliveryAddress': deliveryAddress,
      'landmark': landmark,
      'pincode': pincode,
      'isSaved': isSaved,
    };
  }

  factory ReceiverModel.fromJson(Map<String, dynamic> json) {
    return ReceiverModel(
      id: json['id'] as String? ?? 'REC-101',
      fullName: json['fullName'] as String? ?? '',
      phoneNumber: json['phoneNumber'] as String? ?? '',
      deliveryAddress: json['deliveryAddress'] as String? ?? '',
      landmark: json['landmark'] as String?,
      pincode: json['pincode'] as String?,
      isSaved: json['isSaved'] as bool? ?? true,
    );
  }
}
