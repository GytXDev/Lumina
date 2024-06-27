import 'package:cloud_firestore/cloud_firestore.dart';

class AlertModel {
  final String alertId;
  final String orderId;
  final String userId;
  final String userName;
  final String sellerId;
  final String sellerName;
  final String carId;
  final DateTime alertTime;

  AlertModel({
    required this.alertId,
    required this.orderId,
    required this.userId,
    required this.userName,
    required this.sellerId,
    required this.sellerName,
    required this.carId,
    required this.alertTime,
  });

  factory AlertModel.fromMap(Map<String, dynamic> map, String id) {
    return AlertModel(
      alertId: id,
      orderId: map['orderId'] ?? '',
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? '',
      sellerId: map['sellerId'] ?? '',
      sellerName: map['sellerName'] ?? '',
      carId: map['carId'] ?? '',
      alertTime: (map['alertTime'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'orderId': orderId,
      'userId': userId,
      'userName': userName,
      'sellerId': sellerId,
      'sellerName': sellerName,
      'carId': carId,
      'alertTime': alertTime,
    };
  }
}
