
class UserProfile {
  final String uid;
  final String name;
  final String email;
  final String phoneNumber;
  final String? photoUrl;
  final double monthlyIncome;
  final String currency;

  const UserProfile({
    required this.uid,
    required this.name,
    required this.email,
    required this.phoneNumber,
    this.photoUrl,
    this.monthlyIncome = 0.0,
    this.currency = 'INR',
  });

  factory UserProfile.fromMap(
      String uid,
      Map<String, dynamic> data,
      ) {
    return UserProfile(
      uid: uid,
      name: data['name'] as String? ?? '',
      email: data['email'] as String? ?? '',
      phoneNumber: data['phoneNumber'] as String? ?? '',
      photoUrl: data['photoUrl'] as String?,
      monthlyIncome:
      (data['monthlyIncome'] as num?)?.toDouble() ?? 0.0,
      currency: data['currency'] as String? ?? 'INR',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'phoneNumber': phoneNumber,
      'photoUrl': photoUrl,
      'monthlyIncome': monthlyIncome,
      'currency': currency,
    };
  }

  UserProfile copyWith({
    String? name,
    String? email,
    String? phoneNumber,
    String? photoUrl,
    double? monthlyIncome,
    String? currency,
  }) {
    return UserProfile(
      uid: uid,
      name: name ?? this.name,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      photoUrl: photoUrl ?? this.photoUrl,
      monthlyIncome: monthlyIncome ?? this.monthlyIncome,
      currency: currency ?? this.currency,
    );
  }
}
