/// Model representing an authentic user profile for Senders and Travellers.
class UserProfileModel {
  final String id;
  final String fullName;
  final String email;
  final String phone;
  final String bio;
  final String photoPreset;
  final String role;
  final bool isVerified;
  final double rating;
  final int totalTrips;
  final int totalRequests;
  final int completedDeliveries;
  final int cancelledDeliveries;

  const UserProfileModel({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phone,
    this.bio = '',
    this.photoPreset = 'person_rounded',
    required this.role,
    this.isVerified = true,
    this.rating = 4.8,
    this.totalTrips = 12,
    this.totalRequests = 15,
    this.completedDeliveries = 14,
    this.cancelledDeliveries = 1,
  });

  UserProfileModel copyWith({
    String? id,
    String? fullName,
    String? email,
    String? phone,
    String? bio,
    String? photoPreset,
    String? role,
    bool? isVerified,
    double? rating,
    int? totalTrips,
    int? totalRequests,
    int? completedDeliveries,
    int? cancelledDeliveries,
  }) {
    return UserProfileModel(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      bio: bio ?? this.bio,
      photoPreset: photoPreset ?? this.photoPreset,
      role: role ?? this.role,
      isVerified: isVerified ?? this.isVerified,
      rating: rating ?? this.rating,
      totalTrips: totalTrips ?? this.totalTrips,
      totalRequests: totalRequests ?? this.totalRequests,
      completedDeliveries: completedDeliveries ?? this.completedDeliveries,
      cancelledDeliveries: cancelledDeliveries ?? this.cancelledDeliveries,
    );
  }
}
