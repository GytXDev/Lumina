import 'package:cloud_firestore/cloud_firestore.dart';

class OrderCars {
  final String orderId;
  final DateTime orderTime;
  final String carId;
  final String carName;
  final List<String> carImages;
  final String username;
  final double price;
  final String brand;
  final String userId;
  final String requesterName;
  final String requesterPhone;
  final String requesterId;
  final String orderDescription;
  bool isAlert; 
  final String orderCurrency;
  OrderCars({
    required this.orderId,
    required this.orderTime,
    required this.carId,
    required this.carName,
    required this.carImages,
    required this.username,
    required this.price,
    required this.brand,
    required this.userId,
    required this.requesterName,
    required this.requesterPhone,
    required this.requesterId,
    required this.orderDescription,
    this.isAlert = false,
    this.orderCurrency = '',
  });

  factory OrderCars.fromMap(Map<String, dynamic> map, String id) {
    return OrderCars(
      orderId: id,
      orderTime: (map['orderTime'] as Timestamp).toDate(),
      carId: map['carId'] ?? '',
      carName: map['carName'] ?? '',
      carImages: List<String>.from(map['carImages'] ?? []),
      username: map['username'] ?? '',
      price: map['price'] ?? 0.0,
      brand: map['brand'] ?? '',
      userId: map['userId'] ?? '',
      requesterName: map['requesterName'] ?? '',
      requesterPhone: map['requesterPhone'] ?? '',
      requesterId: map['requesterId'] ?? '',
      orderDescription: map['orderDescription'] ?? '',
      isAlert: map['isAlert'] ?? false,
      orderCurrency: map['orderCurrency'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'orderTime': orderTime,
      'carId': carId,
      'carName': carName,
      'carImages': carImages,
      'username': username,
      'price': price,
      'brand': brand,
      'userId': userId,
      'requesterName': requesterName,
      'requesterPhone': requesterPhone,
      'requesterId': requesterId,
      'orderDescription': orderDescription,
      'isAlert': isAlert,
      'orderCurrency' : orderCurrency,
    };
  }
}
