import 'sender_search_query.dart';
import 'sender_traveller_match.dart';

/// Presentation model for a Sender's delivery request.
///
/// Note: This is a frontend presentation model.
/// Official API/backend mapping will be provided by Person 1.
class SenderDeliveryRequest {
  final SenderSearchQuery searchQuery;
  final SenderTravellerMatch traveller;
  final String parcelDescription;
  final double parcelWeightKg;
  final String parcelCategory;
  final String? specialInstructions;

  const SenderDeliveryRequest({
    required this.searchQuery,
    required this.traveller,
    required this.parcelDescription,
    required this.parcelWeightKg,
    required this.parcelCategory,
    this.specialInstructions,
  });

  SenderDeliveryRequest copyWith({
    SenderSearchQuery? searchQuery,
    SenderTravellerMatch? traveller,
    String? parcelDescription,
    double? parcelWeightKg,
    String? parcelCategory,
    String? specialInstructions,
  }) {
    return SenderDeliveryRequest(
      searchQuery: searchQuery ?? this.searchQuery,
      traveller: traveller ?? this.traveller,
      parcelDescription: parcelDescription ?? this.parcelDescription,
      parcelWeightKg: parcelWeightKg ?? this.parcelWeightKg,
      parcelCategory: parcelCategory ?? this.parcelCategory,
      specialInstructions: specialInstructions ?? this.specialInstructions,
    );
  }
}
