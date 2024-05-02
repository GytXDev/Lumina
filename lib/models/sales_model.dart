// sales_models.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class SalesModel {
  final String saleId;
  final DateTime saleTime;
  final String carId;
  final List<String> carImages;
  final String username;
  final double price;
  final String brand;
  final String userId;
  final String requesterName;
  final String requesterPhone;
  final String requesterId;
  final String saleDescription;
  // ... autres champs ...

  SalesModel({
    required this.saleId,
    required this.saleTime,
    required this.carId,
    required this.carImages,
    required this.username,
    required this.price,
    required this.brand,
    required this.userId,
    required this.requesterName,
    required this.requesterPhone,
    required this.requesterId, 
    required this.saleDescription,
    // ... autres champs ...
  });

  Map<String, dynamic> toMap() {
    return {
      'saleId': saleId,
      'saleTime': saleTime,
      'carId': carId,
      'carImages': carImages,
      'username': username,
      'price': price,
      'brand': brand,
      'userId': userId,
      'requesterName': requesterName,
      'requesterPhone': requesterPhone,
      'requesterId': requesterId,
      'saleDescription': saleDescription,
      // ... autres champs ...
    };
  }

  factory SalesModel.fromMap(Map<String, dynamic> map, String id) {
    return SalesModel(
      saleId: map['saleId'],
       saleTime: (map['saleTime'] as Timestamp).toDate(),
      carId: map['carId'] ?? '',
      carImages: List<String>.from(map['carImages'] ?? []),
      username: map['username'] ?? '',
      price: map['price'] ?? 0.0,
      brand: map['brand'] ?? '',
      userId: map['userId'] ?? '',
      requesterName: map['requesterName'] ?? '',
      requesterPhone: map['requesterPhone'] ?? '',
      requesterId: map['requesterId'] ?? '',
      saleDescription: map['saleDescription'] ?? '',
      // ... autres champs ...
    );
  }
}
