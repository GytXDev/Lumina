// ignore_for_file: file_names, avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lumina/colors/coloors.dart';
import 'package:lumina/features/cars/pages/cars_details.dart';
import 'package:lumina/features/cars/repository/cars_repository.dart';
import 'package:lumina/features/chat/repository/chat_repository.dart';
import 'package:lumina/languages/app_translations.dart';
import 'package:lumina/models/cars_model.dart';
import 'package:lumina/models/user_models.dart';
import 'package:quickalert/quickalert.dart';

import '../../auth/widgets/custom_button.dart';

class IsOkayPage extends StatefulWidget {
  const IsOkayPage({super.key});

  @override
  State<IsOkayPage> createState() => _IsOkayPageState();
}

class _IsOkayPageState extends State<IsOkayPage> {
  final CarsRepository _carsRepository = CarsRepository();

  String formatPrice(double price, Locale locale) {
    final format = NumberFormat("#,###", locale.toString());
    print('$locale');
    return format.format(price);
  }

  void _approveCar(CarsModel car) {
    QuickAlert.show(
      context: context,
      type: QuickAlertType.confirm,
      title: 'Approve Car',
      text: 'Are you sure you want to approve this car?',
      confirmBtnText: 'Yes',
      cancelBtnText: 'No',
      onConfirmBtnTap: () async {
        Navigator.pop(context); // Ferme l'alerte
        try {
          // Mettre à jour la valeur isOkay à true
          await _carsRepository.updateCar(car.carId, {'isOkay': true});

          // Envoyer un message au vendeur
          // ignore: use_build_context_synchronously
          String approvalMessage = AppLocalizations.of(context)
              .translateWithVariables('approvalMessage', {
            'carName': car.carName,
            'carModel': car.brand,
            'carPrice': car.price,
            'currency': car.currency
          });

          User? firebaseUser = FirebaseAuth.instance.currentUser;
          if (firebaseUser != null) {
            FirebaseFirestore.instance
                .collection('users')
                .doc(firebaseUser.uid)
                .get()
                .then((doc) {
              if (doc.exists) {
                UserModel currentUser =
                    UserModel.fromMap(doc.data() as Map<String, dynamic>);

                final ChatRepository chatRepository = ChatRepository(
                  firestore: FirebaseFirestore.instance,
                  auth: FirebaseAuth.instance,
                );

                chatRepository.sendTextMessage(
                  context: context,
                  textMessage: approvalMessage,
                  receiverId: car.userId,
                  senderData: currentUser,
                );
              }
            });
          }

          // Rafraîchir la liste des voitures non approuvées
          setState(() {});
        } catch (e) {
          // Gestion des erreurs
          print('Erreur lors de l\'approbation de la voiture : $e');
        }
      },
    );
  }

  // Faire passer une offre en offre premium
  void _premiumPackage(CarsModel car) {
    QuickAlert.show(
      context: context,
      type: QuickAlertType.confirm,
      title: 'Package premium',
      text: 'Soucrire au package premium?',
      confirmBtnText: 'Oui',
      cancelBtnText: 'Non',
      onConfirmBtnTap: () async {
        Navigator.pop(context); // Ferme l'alerte
        try {
          // Mettre à jour la valeur isOkay à true
          await _carsRepository.updateCar(car.carId, {'isCertified': true});

          // Envoyer un message au vendeur
          // ignore: use_build_context_synchronously
          String premiumPackageMessage =
              "Votre annonce a été passée en offre premium. Cela permettra d'augmenter sa visibilité et d'attirer davantage d'acheteurs potentiels.";

          User? firebaseUser = FirebaseAuth.instance.currentUser;
          if (firebaseUser != null) {
            FirebaseFirestore.instance
                .collection('users')
                .doc(firebaseUser.uid)
                .get()
                .then((doc) {
              if (doc.exists) {
                UserModel currentUser =
                    UserModel.fromMap(doc.data() as Map<String, dynamic>);

                final ChatRepository chatRepository = ChatRepository(
                  firestore: FirebaseFirestore.instance,
                  auth: FirebaseAuth.instance,
                );

                chatRepository.sendTextMessage(
                  context: context,
                  textMessage: premiumPackageMessage,
                  receiverId: car.userId,
                  senderData: currentUser,
                );
              }
            });
          }

          // Rafraîchir la liste des voitures non approuvées
          setState(() {});
        } catch (e) {
          // Gestion des erreurs
          print('Erreur lors de la mise à jour de l\'offre : $e');
        }
      },
    );
  }

  void _rejectCar(CarsModel car) {
    QuickAlert.show(
      context: context,
      type: QuickAlertType.warning,
      title: 'Reject Car',
      text: 'Are you sure you want to reject this car?',
      confirmBtnText: 'Yes',
      cancelBtnText: 'No',
      onConfirmBtnTap: () async {
        Navigator.pop(context); // Ferme l'alerte
        try {
          await _carsRepository.deleteCar(car.carId, car.imageUrls);

          // Message de rejet
          // ignore: use_build_context_synchronously
          String rejectionMessage = AppLocalizations.of(context)
              .translateWithVariables('rejectedMessage', {
            'carName': car.carName,
            'carModel': car.brand,
          });

          User? firebaseUser = FirebaseAuth.instance.currentUser;
          if (firebaseUser != null) {
            FirebaseFirestore.instance
                .collection('users')
                .doc(firebaseUser.uid)
                .get()
                .then((doc) {
              if (doc.exists) {
                UserModel currentUser =
                    UserModel.fromMap(doc.data() as Map<String, dynamic>);

                final ChatRepository chatRepository = ChatRepository(
                  firestore: FirebaseFirestore.instance,
                  auth: FirebaseAuth.instance,
                );

                chatRepository.sendTextMessage(
                  context: context,
                  textMessage: rejectionMessage,
                  receiverId: car.userId,
                  senderData: currentUser,
                );
              }
            });
          }
        } catch (e) {
          print('Erreur lors du rejet de la voiture : $e');
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            Text(AppLocalizations.of(context).translate('unapprovedCarsTitle')),
        elevation: 0,
        backgroundColor: Coolors.backgroundDark,
        foregroundColor: Theme.of(context).primaryColor,
      ),
      body: FutureBuilder<List<CarsModel>>(
        future: _carsRepository.getUnapprovedCars(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Text(
                  AppLocalizations.of(context).translate('noUnapprovedCars')),
            );
          }
          final unapprovedCars = snapshot.data!;
          return ListView.separated(
            itemCount: unapprovedCars.length,
            separatorBuilder: (_, __) => const Divider(),
            itemBuilder: (context, index) {
              final car = unapprovedCars[index];
              return Card(
                elevation: 4,
                margin: const EdgeInsets.all(10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey
                        .withOpacity(0.4), // Ajoutez votre couleur de fond ici
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Column(
                    children: [
                      ListTile(
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            car.imageUrls.isNotEmpty
                                ? car.imageUrls.first
                                : 'assets/default_car_image.png',
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                          ),
                        ),
                        title: Text(car.carName),
                        subtitle: Text(
                          '${car.brand}  \n${formatPrice(car.price, Localizations.localeOf(context))} ${car.currency} \n${car.username}',
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.thumb_up,
                                  color: Coolors.blueDark),
                              onPressed: () => _approveCar(car),
                            ),
                            IconButton(
                              icon: const Icon(Icons.thumb_down,
                                  color: Colors.red),
                              onPressed: () => _rejectCar(car),
                            ),
                          ],
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DetailCars(
                                userId: car.userId,
                                carId: car.carId,
                                carName: car.carName,
                                carModel: car.brand,
                                carImageURLs: car.imageUrls.isNotEmpty
                                    ? car.imageUrls
                                    : ['assets/default_car_image.png'],
                                carDescription: car.description,
                                carPrice: car.price,
                                carCurrency: car.currency,
                              ),
                            ),
                          );
                        },
                      ),
                      if (!car.isCertified)
                        CustomElevatedButton(
                          onPressed: () {
                            _premiumPackage(car);
                          },
                          text: 'Passer en offre premium',
                        ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
