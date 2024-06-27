// ignore_for_file: avoid_print, deprecated_member_use, unused_local_variable, use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:lumina/colors/helpers/show_loading_dialog.dart';
import 'package:lumina/features/chat/repository/chat_repository.dart';
import 'package:lumina/home_section/page/cars_page.dart';
import 'package:lumina/home_section/widgets/shimmer_effect.dart';
import 'package:lumina/languages/app_translations.dart';
import 'package:lumina/models/cars_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../colors/coloors.dart';
import '../../features/cars/pages/cars_details.dart';
import '../../features/cars/repository/cars_repository.dart';
import '../../models/order_model.dart';
import '../../models/user_models.dart';
import '../services/currency.dart';
import '../services/exchange_rate.dart';
import 'likes_post.dart';
import 'package:quickalert/quickalert.dart';

class CarPost extends StatefulWidget {
  final String searchQuery;
  final String? selectedLabel;
  final UserModel currentUser;
  const CarPost({
    required this.searchQuery,
    required this.selectedLabel,
    super.key,
    required this.currentUser,
  });

  @override
  State<CarPost> createState() => _CarPostState();
}

String formatPrice(double price, Locale locale) {
  final format = NumberFormat("#,###", locale.toString());
  print('$locale');
  return format.format(price);
}

//verifie si une commande similaire existe déjà
Future<bool> hasUserOrderedCarFromFirestore(String carId, String userId) async {
  final ordersRef = FirebaseFirestore.instance.collection('orders');
  QuerySnapshot querySnapshot = await ordersRef
      .where('carId', isEqualTo: carId)
      .where('requesterId', isEqualTo: userId)
      .get();
  return querySnapshot.docs.isNotEmpty;
}

Future<UserModel> getUserData(String uid) async {
  DocumentSnapshot<Map<String, dynamic>> userDoc =
      await FirebaseFirestore.instance.collection('users').doc(uid).get();
  return UserModel.fromMap(userDoc.data()!);
}

Future<UserModel?> getCurrentUser() async {
  try {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      return getUserData(user.uid);
    }
    return null;
  } catch (e) {
    print("Error retrieving current user : $e");
    return null;
  }
}

Future<OrderCars?> getExistingOrder({
  required String carId,
  required String userId,
}) async {
  try {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('orders')
        .where('carId', isEqualTo: carId)
        .where('requesterId', isEqualTo: userId) // Utilise userId ici
        .limit(1)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      // Si une commande correspondante est trouvée, retourne la première commande trouvée
      return OrderCars.fromMap(
          querySnapshot.docs.first.data(), querySnapshot.docs.first.id);
    } else {
      // Aucune commande similaire trouvée
      return null;
    }
  } catch (e) {
    print("Error getting existing order: $e");
    return null;
  }
}

class _CarPostState extends State<CarPost> {
  final CarsRepository _carsRepository = CarsRepository();
  bool isMounted = false;

  @override
  void initState() {
    super.initState();
    isMounted = true;
    _updateCarOrderStatus().then((_) {
      if (isMounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    isMounted = false;
    super.dispose();
  }

  Future<void> _updateCarOrderStatus() async {
    final user = await getCurrentUser();
    if (user != null) {
      List<Future<void>> tasks = cars.map((car) async {
        bool ordered =
            await hasUserOrderedCarFromFirestore(car.carId, user.uid);
        if (isMounted) {
          setState(() {
            carOrderStatus[car.carId] = ordered;
          });
        }
      }).toList();

      await Future.wait(tasks);
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

  // Instance de CarsRepository
  String formatLikes(int number) {
    if (number >= 1000000) return '${(number / 1000000).toStringAsFixed(1)}M';
    if (number >= 1000) return '${(number / 1000).toStringAsFixed(1)}K';
    return number.toString();
  }

  Map<String, bool> carOrderStatus = {};
  List<CarsModel> cars = [];

  // énumération Currency

  double convertCarPriceToUSD(CarsModel car) {
    return ExchangeRate.convertToUSD(
        car.price, Currency.values.byName(car.currency));
  }

  @override
  Widget build(BuildContext context) {
    late Stream<QuerySnapshot> stream;

    final carsRef = FirebaseFirestore.instance.collection('cars');

    if (widget.searchQuery.isNotEmpty) {
      stream = carsRef
          .where('carName', isEqualTo: widget.searchQuery)
          .where('isSale', isEqualTo: false)
          .snapshots();
    } else if (widget.selectedLabel == null ||
        widget.selectedLabel == FilterKeys.all) {
      stream = carsRef.where('isSale', isEqualTo: false).snapshots();
    } else if (widget.selectedLabel == FilterKeys.mostLoved) {
      stream = carsRef
          .where('isSale', isEqualTo: false)
          .orderBy('totalLike', descending: true)
          .snapshots();
    } else if (widget.selectedLabel == FilterKeys.bestsellers) {
      stream = carsRef.where('isSale', isEqualTo: true).snapshots();
    } else if (widget.selectedLabel == FilterKeys.occasion) {
      stream = carsRef
          .where('yearOrNew', isEqualTo: 'old')
          .where('isSale', isEqualTo: false)
          .snapshots();
    } else if (widget.selectedLabel == FilterKeys.newCars) {
      stream = carsRef
          .where('yearOrNew', isEqualTo: 'new')
          .where('isSale', isEqualTo: false)
          .snapshots();
    } else {
      // Fallback en cas de label inconnu
      stream = carsRef.snapshots();
    }

    return StreamBuilder<QuerySnapshot>(
      stream: stream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Afficher le Shimmer pendant le chargement des données
          return const ShimmerLoadingWidget();
        } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          // Afficher un message si aucune donnée n'est disponible
          return Center(
            child: Text(
              AppLocalizations.of(context).translate('noResultsFoundText'),
            ),
          );
        } else {
          // Convertir les documents snapshot en liste de CarsModel
          List<CarsModel> cars = snapshot.data!.docs
              .map((doc) =>
                  CarsModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
              .toList();

          // Filtrer les voitures approuvées uniquement
          cars = cars.where((car) => car.isOkay).toList();

          // Filtrer par la requête de recherche si nécessaire
          if (widget.searchQuery.isNotEmpty) {
            final queryLower = widget.searchQuery.toLowerCase();
            print(
                'Search Query: $queryLower'); // Affiche la requête de recherche

            cars = cars.where((car) {
              // Recherche flexible sur plusieurs champs
              return car.carName.toLowerCase().contains(queryLower) ||
                  car.brand.toLowerCase().contains(queryLower) ||
                  ("${car.brand} ${car.carName}"
                      .toLowerCase()
                      .contains(queryLower)) ||
                  car.price.toString().contains(queryLower);
            }).toList();

            // Afficher les voitures filtrées
            print('Filtered Cars: ${cars.map((e) => e.carName).join(', ')}');
          }

          // Appliquer le tri basé sur le label sélectionné après avoir converti les prix en USD
          if (widget.selectedLabel == FilterKeys.mostExpensive ||
              widget.selectedLabel == FilterKeys.theCheapest) {
            List<CarsModel> filteredCars =
                cars.where((car) => !car.isSale).toList();

            filteredCars.sort((CarsModel a, CarsModel b) {
              double priceA = convertCarPriceToUSD(a);
              double priceB = convertCarPriceToUSD(b);
              return widget.selectedLabel == FilterKeys.mostExpensive
                  ? priceB.compareTo(priceA)
                  : priceA.compareTo(priceB);
            });

            cars = filteredCars; // Utilisez `filteredCars` pour l'affichage
          }
          // Mettre les voitures certifiées en avant
          List<CarsModel> certifiedCars =
              cars.where((car) => car.isCertified).toList();
          List<CarsModel> nonCertifiedCars =
              cars.where((car) => !car.isCertified).toList();

          // Si l'utilisateur est standard, limiter l'affichage des voitures certifiées
          /*if (widget.currentUser.subscriptionType == 'standard' &&
              certifiedCars.isNotEmpty) {
            certifiedCars = [certifiedCars.first];
          }*/

          // Combiner les voitures certifiées et non certifiées
          List<CarsModel> finalCarsList = certifiedCars + nonCertifiedCars;

          return ListView.builder(
            itemCount: finalCarsList.length,
            itemBuilder: (context, index) {
              final car = finalCarsList[index];

              return Container(
                margin: const EdgeInsets.symmetric(vertical: 16.0),
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const SizedBox(width: 8.0),
                            Row(
                              children: [
                                const SizedBox(
                                    width:
                                        4.0), // Espacement entre le nom et l'image de certification
                                if (car
                                    .isCertified) // Condition pour afficher l'image de certification
                                  Image.asset(
                                    'assets/icons/certified.png',
                                    width: 18.0, // Taille de l'image
                                    height: 18.0, // Taille de l'image
                                  ),
                              ],
                            ),
                          ],
                        ),
                        Text(
                          car.brand,
                          style: const TextStyle(
                            color: Coolors.blueDark,
                            fontWeight: FontWeight.w600,
                            fontSize: 16.0,
                            fontFamily: 'Playfair Display',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8.0),
                    // Afficher les images de la voiture à partir de carData['imageUrls']
                    // ...
                    SizedBox(
                      height: 200.0,
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              // Récupération des données du véhicule
                              builder: (context) => DetailCars(
                                userId: car.userId,
                                carId: car.carId,
                                carName: car.carName,
                                carModel: car.brand,
                                carImageURLs: car.imageUrls,
                                carDescription: car.description,
                                carPrice: car.price,
                                carCurrency: car.currency,
                              ),
                            ),
                          );
                        },
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: car.imageUrls
                              .length, // Use car.imageUrls instead of carData['imageUrls']
                          itemBuilder: (context, index) {
                            return Container(
                              width: 200.0,
                              margin: const EdgeInsets.only(right: 8.0),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8.0),
                                image: DecorationImage(
                                  image: NetworkImage(car.imageUrls[
                                      index]), // Use car.imageUrls instead of carData['imageUrls']
                                  fit: BoxFit.cover,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 8.0,
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8.0, vertical: 4.0),
                      decoration: BoxDecoration(
                        color: car.yearOrNew == CarType.news
                            ? Coolors.blueDark
                            : Coolors.greyDark,
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize
                            .min, // Pour éviter que le Row prenne toute la largeur disponible
                        children: [
                          Icon(
                            car.yearOrNew == CarType.news
                                ? Icons.star
                                : Icons.hourglass_empty,
                            color: Colors.white,
                            size: 16.0,
                          ),
                          const SizedBox(width: 4.0),
                          Text(
                            car.yearOrNew == CarType.news
                                ? AppLocalizations.of(context)
                                    .translate('newCar')
                                : AppLocalizations.of(context)
                                    .translateWithVariables(
                                    'occasionCar',
                                    {'duration': car.duration ?? 'N/A'},
                                  ),
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10.0, vertical: 10.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.5),
                                  spreadRadius: 2,
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Text(
                              '${formatPrice(car.price, Localizations.localeOf(context))} ${car.currency}',
                              style: const TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(
                              width:
                                  8.0), // Ajoutez un espace entre le prix et le nom du modèle
                          Text(
                            car.carName,
                            style: const TextStyle(
                              //color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 8.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment
                          .spaceBetween, // Pour les garder ensemble sans espace supplémentaire
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            LikeButton(car: car),
                            const SizedBox(
                              width: 8,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  formatLikes(car.totalLike),
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w200),
                                ),
                                const SizedBox(
                                  width: 4.0,
                                ),
                                const Text(
                                  'Appreciate',
                                  style: TextStyle(fontWeight: FontWeight.w200),
                                )
                              ],
                            ),
                          ],
                        ),
                        car.isSale == false
                            ? ElevatedButton(
                                onPressed: () async {
                                  final UserModel currentUser =
                                      await getCurrentUser() as UserModel;
                                  if (currentUser.uid == car.userId) {
                                    // Affiche une alerte rapide indiquant que l'utilisateur ne peut pas acheter son propre véhicule
                                    QuickAlert.show(
                                      context: context,
                                      type: QuickAlertType.warning,
                                      title: AppLocalizations.of(context)
                                          .translate('warningTitle'),
                                      text: AppLocalizations.of(context)
                                          .translate('ownVehicleWarning'),
                                    );
                                    return;
                                  }
                                  if (carOrderStatus[car.carId] ?? false) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          AppLocalizations.of(context)
                                              .translate('alreadyOrdered'),
                                          style: const TextStyle(
                                              color: Coolors.blueDark),
                                        ),
                                      ),
                                    );
                                    return;
                                  }

                                  // Vérifie si une commande similaire existe déjà
                                  final existingOrder = await getExistingOrder(
                                    carId: car.carId,
                                    userId: currentUser.uid,
                                  );

                                  if (existingOrder != null) {
                                    QuickAlert.show(
                                      context: context,
                                      type: QuickAlertType.error,
                                      title: AppLocalizations.of(context)
                                          .translate('error'),
                                      text: AppLocalizations.of(context)
                                          .translate('alreadyOrdered2'),
                                    );

                                    print("La commande existe déjà !");
                                  } else {
                                    QuickAlert.show(
                                      context: context,
                                      type: QuickAlertType.confirm,
                                      title: AppLocalizations.of(context)
                                          .translate(
                                              'markAsPaidConfirmationTitle'),
                                      text: AppLocalizations.of(context)
                                          .translate(
                                              'confirmPurchaseRequestMessage'),
                                      confirmBtnText:
                                          AppLocalizations.of(context)
                                              .translate(
                                                  'markAsPaidConfirmationYes'),
                                      cancelBtnText:
                                          AppLocalizations.of(context)
                                              .translate(
                                                  'markAsPaidConfirmationNo'),
                                      confirmBtnColor: Coolors.blueDark,
                                      onCancelBtnTap: () => Navigator.of(
                                              context)
                                          .pop(), // Ferme la boîte de dialogue
                                      onConfirmBtnTap: () async {
                                        Navigator.of(context)
                                            .pop(); // Ferme la boîte de dialogue de confirmation

                                        showLoadingDialog(
                                          context: context,
                                          message: AppLocalizations.of(context)
                                              .translate('orderingPost'),
                                          barrierDismissible: false,
                                        );

                                        //recuperer l'utilisateur actuellement connecté
                                        final UserModel user =
                                            (await getCurrentUser())
                                                as UserModel;

                                        final orderId = FirebaseFirestore
                                            .instance
                                            .collection('orders')
                                            .doc()
                                            .id;

                                        final order = OrderCars(
                                          orderId: orderId,
                                          orderTime: DateTime.now(),
                                          carId: car.carId,
                                          carName: car.carName,
                                          carImages: car.imageUrls,
                                          username: car.username,
                                          price: car.price,
                                          brand: car.brand,
                                          userId: car.userId,
                                          requesterName: user.username,
                                          requesterPhone: user.phoneNumber,
                                          requesterId: user.uid,
                                          orderDescription: car.description,
                                          orderCurrency: car.currency,
                                        );
                                        // Récupérer un admin
                                        UserModel? adminUser =
                                            await getOneAdmin();

                                        if (adminUser != null) {
                                          final ChatRepository chatRepository =
                                              ChatRepository(
                                            firestore:
                                                FirebaseFirestore.instance,
                                            auth: FirebaseAuth.instance,
                                          );
                                          //Envoie du message
                                          Future.microtask(() {
                                            String message;

                                            if (car.yearOrNew == CarType.news) {
                                              message =
                                                  AppLocalizations.of(context)
                                                      .translateWithVariables(
                                                'interestMessageNewCar',
                                                {
                                                  "carName": car.carName,
                                                  "brand": car.brand,
                                                  "price": car.price.toString(),
                                                  "currency": car.currency,
                                                },
                                              );
                                            } else {
                                              message =
                                                  AppLocalizations.of(context)
                                                      .translateWithVariables(
                                                'interestMessageUsedCar',
                                                {
                                                  "carName": car.carName,
                                                  "brand": car.brand,
                                                  "price": car.price.toString(),
                                                  "currency": car.currency,
                                                },
                                              );
                                            }
                                            chatRepository.sendTextMessage(
                                              context: context,
                                              textMessage: message,
                                              receiverId: adminUser
                                                  .uid, // ID du vendeur
                                              senderData:
                                                  user, // Données de l'utilisateur qui passe la commande
                                            );
                                          });
                                        }

                                        // Si la commande n'existe pas, tu peux l'ajouter à la collection "orders"
                                        await _carsRepository
                                            .saveOrderCollection(order);

                                        // Mettre à jour le document de la voiture dans la collection "cars"
                                        // Après avoir enregistré la commande dans la collection 'orders'
                                        final carRef = FirebaseFirestore
                                            .instance
                                            .collection('cars')
                                            .doc(car.carId);
                                        final carDoc = await carRef.get();
                                        if (carDoc.exists) {
                                          int orderCount =
                                              carDoc.data()?['orderCount'] ?? 0;
                                          orderCount += 1;
                                          bool isAsk = orderCount > 0;
                                          await carRef.update({
                                            'orderCount': orderCount,
                                            'isAsk': isAsk,
                                          });
                                        }

                                        // Mettre à jour l'état du bouton en fonction du contenu du panier
                                        setState(() {
                                          carOrderStatus[car.carId] = true;
                                          Navigator.pop(context);
                                          if (car.yearOrNew == CarType.news) {
                                            QuickAlert.show(
                                              context: context,
                                              type: QuickAlertType.success,
                                              title: AppLocalizations.of(
                                                      context)
                                                  .translate(
                                                      'askingSuccessfullyRecordedTitle'),
                                              text: AppLocalizations.of(context)
                                                  .translateWithVariables(
                                                      'askingSuccessfullyRecordedText',
                                                      {
                                                    "brand": car.brand,
                                                    "carName": car.carName,
                                                    'price': car.price
                                                        .toStringAsFixed(2),
                                                    'username': car.username,
                                                    'currency': car.currency,
                                                  }),
                                            );
                                          } else {
                                            QuickAlert.show(
                                              context: context,
                                              type: QuickAlertType.success,
                                              title: AppLocalizations.of(
                                                      context)
                                                  .translate(
                                                      'askingSuccessfullyRecordedTitle'),
                                              text: AppLocalizations.of(context)
                                                  .translateWithVariables(
                                                      'askingSuccessfullyRecordedText2',
                                                      {
                                                    "brand": car.brand,
                                                    "carName": car.carName,
                                                    "duration": car.duration,
                                                    'price': car.price
                                                        .toStringAsFixed(2),
                                                    'username': car.username,
                                                    'currency': car.currency,
                                                  }),
                                            );
                                          }
                                        });
                                      },
                                    );
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                    foregroundColor:
                                        carOrderStatus[car.carId] ?? false
                                            ? Colors.white
                                            : Colors.white,
                                    backgroundColor: Coolors
                                        .greyDark // Cette ligne change la couleur du texte
                                    ),
                                child: Text(carOrderStatus[car.carId] ?? false
                                    ? AppLocalizations.of(context)
                                        .translate('carOrderStatusTrue')
                                    : AppLocalizations.of(context)
                                        .translate('carOrderStatusFalse')),
                              )
                            : const Text('Vendu'),
                      ],
                    ),
                    const SizedBox(
                      height: 8.0,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            car.description,
                            style: const TextStyle(color: Coolors.greyDark),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                // Récupération des données du véhicule
                                builder: (context) => DetailCars(
                                  userId: car.userId,
                                  carId: car.carId,
                                  carName: car.carName,
                                  carModel: car.brand,
                                  carImageURLs: car.imageUrls,
                                  carDescription: car.description,
                                  carPrice: car.price,
                                  carCurrency: car.currency,
                                  carUsername: car.username,
                                  carDuration: car.duration,
                                  carType: car.yearOrNew,
                                ),
                              ),
                            );
                          },
                          // Gérer l'action "Details..."
                          child: Text(
                            AppLocalizations.of(context)
                                .translate('carDetailsPlaceholder'),
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        }
      },
    );
  }
}
