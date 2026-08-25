import 'package:flutter/foundation.dart';
import '../models/user_profile_model.dart';

/// Centralized ChangeNotifier repository serving as the single source of truth
/// for authenticated Sender and Traveller profile data.
class UserProfileRepository extends ChangeNotifier {
  static final UserProfileRepository _instance = UserProfileRepository._internal();
  factory UserProfileRepository() => _instance;
  UserProfileRepository._internal();

  UserProfileModel _senderProfile = const UserProfileModel(
    id: 'SND-101',
    fullName: 'Ramesh Kumar',
    email: 'ramesh.kumar@travgo.com',
    phone: '+91 98765 12345',
    bio: 'Frequent parcel sender across Tamil Nadu.',
    role: 'sender',
    isVerified: true,
    rating: 4.8,
    totalRequests: 15,
    completedDeliveries: 14,
    cancelledDeliveries: 1,
  );

  UserProfileModel _travellerProfile = const UserProfileModel(
    id: 'TRV-101',
    fullName: 'Alex Morgan',
    email: 'alex.morgan@travgo.com',
    phone: '+91 98765 43210',
    bio: 'Verified frequent traveller on Coimbatore - Chennai route.',
    role: 'traveller',
    isVerified: true,
    rating: 4.9,
    totalTrips: 18,
    completedDeliveries: 16,
    cancelledDeliveries: 0,
  );

  UserProfileModel get senderProfile => _senderProfile;
  UserProfileModel get travellerProfile => _travellerProfile;

  Future<void> updateSenderProfile({
    required String fullName,
    required String phone,
    String? bio,
    String? photoPreset,
  }) async {
    // Simulate backend network latency
    await Future.delayed(const Duration(milliseconds: 600));

    _senderProfile = _senderProfile.copyWith(
      fullName: fullName,
      phone: phone,
      bio: bio,
      photoPreset: photoPreset,
    );

    notifyListeners();
  }

  Future<void> updateTravellerProfile({
    required String fullName,
    required String phone,
    String? bio,
    String? photoPreset,
  }) async {
    // Simulate backend network latency
    await Future.delayed(const Duration(milliseconds: 600));

    _travellerProfile = _travellerProfile.copyWith(
      fullName: fullName,
      phone: phone,
      bio: bio,
      photoPreset: photoPreset,
    );

    notifyListeners();
  }
}
