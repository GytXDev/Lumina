// ignore_for_file: avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:lumina/features/auth/repository/firebase_storage_repository.dart';
import 'package:lumina/models/user_models.dart';

import '../../../models/cars_model.dart';
import '../../../models/order_model.dart';

class CarsRepository {
  final CollectionReference carsCollection =
      FirebaseFirestore.instance.collection('cars');
  final CollectionReference ordersCollection =
      FirebaseFirestore.instance.collection('orders');

  // mise à jour des détails d'une voiture
  Future<void> updateCar(
      String carId, Map<String, dynamic> updatedCarData) async {
    try {
      // Mettez à jour les détails de la voiture dans la collection 'cars'
      await carsCollection.doc(carId).update(updatedCarData);

      print('Voiture mise à jour avec succès dans la collection "cars".');
    } catch (e) {
      throw 'Erreur lors de la mise à jour de la voiture : $e';
    }
  }

  // récuperer l'un des admins
  Future<UserModel?> getOneAdmin() async {
    try {
      QuerySnapshot adminSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('userType', isEqualTo: 'admin')
          .limit(1)
          .get();
      if (adminSnapshot.docs.isNotEmpty) {
        return UserModel.fromMap(
            adminSnapshot.docs.first.data() as Map<String, dynamic>);
      } else {
        return null;
      }
    } catch (e) {
      print('Erreur lors de la récupération de l\'admin : $e');
      return null;
    }
  }

  // suppression des voiture
  Future<void> deleteCar(String carId, List<String> imageUrls) async {
    try {
      // Supprimer le document de la voiture
      await carsCollection.doc(carId).delete();
      print('Voiture supprimée avec succès de la collection "cars".');

      // Supprimer les images associées
      for (String imageUrl in imageUrls) {
        // Utiliser la méthode de votre FirebaseStorageRepository pour supprimer l'image
        await FirebaseStorageRepository(
                firebaseStorage: FirebaseStorage.instance)
            .deleteFileFromFirebase(imageUrl);
      }

      // Supprimer les éléments correspondants dans la collection "alerts"
      await FirebaseFirestore.instance
          .collection('alerts')
          .where('carId', isEqualTo: carId)
          .get()
          .then((querySnapshot) {
        for (var doc in querySnapshot.docs) {
          doc.reference.delete();
        }
      });

      // Supprimer les éléments correspondants dans la collection "orders"
      await FirebaseFirestore.instance
          .collection('orders')
          .where('carId', isEqualTo: carId)
          .get()
          .then((querySnapshot) {
        for (var doc in querySnapshot.docs) {
          doc.reference.delete();
        }
      });
    } catch (e) {
      throw 'Erreur lors de la suppression de la voiture : $e';
    }
  }

  // récuperer les postes non approuvées
  Future<List<CarsModel>> getUnapprovedCars() async {
    try {
      final QuerySnapshot querySnapshot =
          await carsCollection.where('isOkay', isEqualTo: false).get();

      return querySnapshot.docs
          .map((doc) =>
              CarsModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      print('Erreur lors de la récupération des voitures non approuvées : $e');
      rethrow; // Vous pouvez gérer les erreurs selon vos besoins
    }
  }

  Future<UserModel> getCurrentUser() async {
    try {
      User? firebaseUser = FirebaseAuth.instance.currentUser;

      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(firebaseUser?.uid)
          .get();

      UserModel user =
          UserModel.fromMap(userSnapshot.data() as Map<String, dynamic>);

      return user;
    } catch (e) {
      throw Exception('Erreur lors de la récupération de l\'utilisateur : $e');
    }
  }

  Future<void> saveCarToCollection(CarsModel car) async {
    try {
      final carData = car.toMap();

      if (car.imageUrls.isNotEmpty) {
        await carsCollection.add(carData);

        print('Voiture enregistrée avec succès dans la collection "cars".');
      } else {
        print('Erreur : Les images n\'ont pas été correctement téléchargées. ');
      }
    } catch (e) {
      throw 'Erreur lors de l\'enregistrement de la voiture : $e';
    }
  }

  Future<void> saveOrderCollection(OrderCars order) async {
    try {
      final orderData = order.toMap();
      await ordersCollection.add(orderData);
      print('nouvelle commamnde  dans la collection "cars".');
    } catch (e) {
      throw "Une erreur lors de l'enregistrement  : $e";
    }
  }

  Future<void> deleteOrder(String orderId) async {
    try {
      await ordersCollection.doc(orderId).delete();
      print('Commande supprimée avec succès de la collection "orders".');
    } catch (e) {
      throw 'Erreur lors de la suppression de la commande : $e';
    }
  }
}
