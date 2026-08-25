import '../../../models/receiver_model.dart';
import 'sender_search_query.dart';
import 'sender_traveller_match.dart';

/// Presentation model for a Sender's delivery request.
class SenderDeliveryRequest {
  final SenderSearchQuery searchQuery;
  final SenderTravellerMatch traveller;
  final ReceiverModel? receiver;
  final String parcelDescription;
  final double parcelWeightKg;
  final String parcelCategory;
  final int parcelQuantity;
  final String? specialInstructions;
  final DateTime? deliveryDate;

  const SenderDeliveryRequest({
    required this.searchQuery,
    required this.traveller,
    this.receiver,
    required this.parcelDescription,
    required this.parcelWeightKg,
    required this.parcelCategory,
    this.parcelQuantity = 1,
    this.specialInstructions,
    this.deliveryDate,
  });

  SenderDeliveryRequest copyWith({
    SenderSearchQuery? searchQuery,
    SenderTravellerMatch? traveller,
    ReceiverModel? receiver,
    String? parcelDescription,
    double? parcelWeightKg,
    String? parcelCategory,
    int? parcelQuantity,
    String? specialInstructions,
    DateTime? deliveryDate,
  }) {
    return SenderDeliveryRequest(
      searchQuery: searchQuery ?? this.searchQuery,
      traveller: traveller ?? this.traveller,
      receiver: receiver ?? this.receiver,
      parcelDescription: parcelDescription ?? this.parcelDescription,
      parcelWeightKg: parcelWeightKg ?? this.parcelWeightKg,
      parcelCategory: parcelCategory ?? this.parcelCategory,
      parcelQuantity: parcelQuantity ?? this.parcelQuantity,
      specialInstructions: specialInstructions ?? this.specialInstructions,
      deliveryDate: deliveryDate ?? this.deliveryDate,
    );
  }
}
