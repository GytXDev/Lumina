enum CarType { old, news }

class CarsModel {
  final String carId;
  late final String carName;
  late final String brand;
  late final CarType yearOrNew;
  late final String? duration;
  final List<String> imageUrls;
  late final String description;
  late final double price;
  final String userId;
  final int totalLike;
  final String username;
  final String userImage;
  final bool isSale;
  final int orderCount;
  final bool isAsk;
  final bool isOkay;
  final List<String> usersLiked;
  final double latitude;
  final double longitude;
  String currency;
  final bool isPayed;

  CarsModel({
    required this.carId,
    required this.carName,
    required this.brand,
    required this.yearOrNew,
    this.duration,
    required this.imageUrls,
    required this.description,
    required this.price,
    required this.userId,
    required this.username,
    required this.userImage,
    required this.totalLike,
    this.isSale = false,
    this.isAsk = false,
    this.orderCount = 0,
    this.isOkay = false,
    this.usersLiked = const [],
    this.latitude = 0,
    this.longitude = 0,
    this.currency = '',
    this.isPayed = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'carId': carId,
      'carName': carName,
      'brand': brand,
      'yearOrNew': yearOrNew == CarType.old ? 'old' : 'new',
      'duration': duration,
      'imageUrls': imageUrls,
      'description': description,
      'price': price,
      'userId': userId,
      'totalLike': totalLike,
      'username': username,
      'userImage': userImage,
      'isSale': isSale,
      'isAsk': isAsk,
      'orderCount': orderCount,
      'isOkay': isOkay,
      'usersLiked': usersLiked,
      'latitude': latitude,
      'longitude': longitude,
      'currency': currency,
      'isPayed': isPayed,
    };
  }

  factory CarsModel.fromMap(Map<String, dynamic> map, String id) {
    if (map['carName'] == null) {
      throw StateError('Missing required fields for carId: $id');
    }
    return CarsModel(
      carId: id,
      carName: map['carName'] ?? '',
      brand: map['brand'] ?? '',
      yearOrNew: map['yearOrNew'] == 'new' ? CarType.news : CarType.old,
      duration: map['duration'],
      imageUrls: List<String>.from(map['imageUrls'] ?? []),
      description: map['description'] ?? '',
      price: map['price'] ?? 0.0,
      userId: map['userId'] ?? '',
      totalLike: map['totalLike'] ?? 0,
      username: map['username'] ?? '',
      userImage: map['userImage'] ?? '',
      isSale: map['isSale'] ?? false,
      isAsk: map['isAsk'] ?? false,
      orderCount: map['orderCount'] ?? 0,
      isOkay: map['isOkay'] ?? false,
      usersLiked: List<String>.from(map['usersLiked'] ?? []),
      latitude: map['latitude'] ?? 0.0,
      longitude: map['longitude'] ?? 0.0,
      currency: map['currency'] ?? '',
      isPayed: map['isPayed'] ?? false,
    );
  }
}
