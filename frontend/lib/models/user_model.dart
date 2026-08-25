class UserModel {
  final String id;
  final String fullName;
  final String? phone;
  final String? email;
  final String role;
  final bool isVerified;
  final double rating;

  UserModel({
    required this.id,
    required this.fullName,
    this.phone,
    this.email,
    required this.role,
    this.isVerified = false,
    this.rating = 0.0,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'],
      fullName: map['full_name'],
      phone: map['phone'],
      email: map['email'],
      role: map['role'],
      isVerified: map['is_verified'] ?? false,
      rating: (map['rating'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'full_name': fullName,
      'phone': phone,
      'email': email,
      'role': role,
      'is_verified': isVerified,
      'rating': rating,
    };
  }
}