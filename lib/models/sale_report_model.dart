import 'package:cloud_firestore/cloud_firestore.dart';

class SalesReportModel {
  final String userId;
  final DateTime date;
  final double carPrice;
  final double debitPrice;
  final String carImageUrl;
  final String sellerName;
  final String buyerName;

  SalesReportModel({
    required this.userId,
    required this.date,
    required this.carPrice,
    required this.debitPrice,
    required this.carImageUrl,
    required this.buyerName,
    required this.sellerName,
  });

  // Méthode pour convertir l'objet en Map pour l'ajout dans Firestore
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'date': Timestamp.fromDate(date),
      'carPrice': carPrice,
      'debitPrice': debitPrice,
      'carImageUrl': carImageUrl,
      'buyerName': buyerName,
      'sellerName': sellerName,
    };
  }

  // Méthode pour créer une instance de l'objet à partir d'un document Firestore
  factory SalesReportModel.fromFirestore(DocumentSnapshot document) {
    Map<String, dynamic> data = document.data() as Map<String, dynamic>;

    return SalesReportModel(
      userId: data['userId'] ?? '',
      date: (data['date'] as Timestamp).toDate(),
      carPrice: data['carPrice'] ?? 0.0,
      debitPrice: data['debitPrice'] ?? 0.0,
      carImageUrl: data['carImageUrl'] ?? '',
      buyerName: data['buyerName'] ?? '',
      sellerName: data['sellerName'] ?? '',
    );
  }
}
