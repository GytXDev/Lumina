class UserModel {
  final String username;
  final String uid;
  final String email;
  final String profileImageUrl;
  final bool active;
  final int lastSeen;
  final String phoneNumber;
  final String userType;
  final double latitude;
  final double longitude;
  final String isConcessionary;
  final bool? isCertified;
  final DateTime? subscriptionEndDate;
  final String subscriptionType;

  UserModel({
    required this.lastSeen,
    required this.username,
    required this.uid,
    required this.profileImageUrl,
    required this.active,
    required this.email,
    required this.phoneNumber,
    required this.userType,
    required this.isConcessionary,
    this.isCertified,
    this.latitude = 0,
    this.longitude = 0,
    this.subscriptionEndDate,
    this.subscriptionType = 'standard',
  });

  Map<String, dynamic> toMap() {
    return {
      'username': username,
      'uid': uid,
      'profileImageUrl': profileImageUrl,
      'active': active,
      'lastSeen': lastSeen,
      'email': email,
      'phoneNumber': phoneNumber,
      'userType': userType,
      'isConcessionary': isConcessionary,
      'isCertified': isCertified,
      'latitude': latitude,
      'longitude': longitude,
      'subscriptionEndDate': subscriptionEndDate?.toIso8601String(),
      'subscriptionType': subscriptionType,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      username: map['username'] ?? '',
      uid: map['uid'] ?? '',
      profileImageUrl: map['profileImageUrl'] ?? '',
      active: map['active'] ?? false,
      lastSeen: map['lastSeen'] ?? 0,
      email: map['email'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      userType: map['userType'] ?? 'user',
      isConcessionary: map['isConcessionary'] ?? 'particular',
      isCertified: map['isCertified'] ?? false,
      latitude: map['latitude'] ?? 0.0,
      longitude: map['longitude'] ?? 0.0,
      subscriptionEndDate: map['subscriptionEndDate'] != null
          ? DateTime.parse(map['subscriptionEndDate'])
          : null,
      subscriptionType: map['subscriptionType'] ?? 'standard',
    );
  }

  UserModel copyWith({
    String? username,
    String? uid,
    String? profileImageUrl,
    bool? active,
    int? lastSeen,
    String? email,
    String? phoneNumber,
    String? userType,
    String? isConcessionary,
    bool? isCertified,
    double? latitude,
    double? longitude,
    DateTime? subscriptionEndDate,
    String? subscriptionType,
  }) {
    return UserModel(
      username: username ?? this.username,
      uid: uid ?? this.uid,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      active: active ?? this.active,
      lastSeen: lastSeen ?? this.lastSeen,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      userType: userType ?? this.userType,
      isConcessionary: isConcessionary ?? this.isConcessionary,
      isCertified: isCertified ?? this.isCertified,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      subscriptionEndDate: subscriptionEndDate ?? this.subscriptionEndDate,
      subscriptionType: subscriptionType ?? this.subscriptionType,
    );
  }
}
