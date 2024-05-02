// ignore_for_file: avoid_print, use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:lumina/colors/extension/extension_theme.dart';
import 'package:lumina/colors/helpers/show_loading_dialog.dart';
import 'package:lumina/features/auth/widgets/custom_button.dart';
import 'package:lumina/features/chat/repository/chat_repository.dart';
import 'package:lumina/languages/app_translations.dart';
import 'package:lumina/models/user_models.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import '../../../colors/coloors.dart';
import '../../../models/cars_model.dart';
import '../../../models/order_model.dart';
import '../repository/cars_repository.dart';
import '../widgets/fade_transition.dart';
import 'package:geocoding/geocoding.dart';

class DetailCars extends StatefulWidget {
  final String carId;
  final String carName;
  final String carModel;
  final List<String> carImageURLs;
  final String carDescription;
  final double carPrice;
  final String userId;
  final String carCurrency;
  final String carUsername;
  final String? carDuration;
  final CarType? carType;

  const DetailCars({
    super.key,
    required this.carId,
    required this.carName,
    required this.carModel,
    required this.carImageURLs,
    required this.carDescription,
    required this.carPrice,
    required this.userId,
    required this.carCurrency,
    this.carDuration,
    this.carUsername = "",
    this.carType,
  });

  @override
  State<DetailCars> createState() => _DetailCarsState();
}

class _DetailCarsState extends State<DetailCars> {
  final CarsRepository _carsRepository = CarsRepository();
  CarsModel? car;
  // Instance de CarsRepository
  String formatLikes(int number) {
    if (number >= 1000000) return '${(number / 1000000).toStringAsFixed(1)}M';
    if (number >= 1000) return '${(number / 1000).toStringAsFixed(1)}K';
    return number.toString();
  }

  // Ajout d'un controlleur pour PageView et le ValueNotifier pour l'index de l'image
  late final PageController _pageController;
  late final ValueNotifier<int> _pageIndexNotifier;

  bool carOrderStatus = false;
  String placeName = "Lieu inconnu";

  void showAnimatedToast(BuildContext context, String message) {
    OverlayEntry overlayEntry = OverlayEntry(
      builder: (context) => AnimatedToast(message: message),
    );

    Overlay.of(context).insert(overlayEntry);

    Future.delayed(const Duration(seconds: 3), () {
      overlayEntry.remove();
    });
  }

  String formatPrice(double price, Locale locale) {
    final format = NumberFormat("#,###", locale.toString());
    print('$locale');
    return format.format(price);
  }

  Future<bool> hasUserOrderedCarFromFirestore(
      String carId, String userId) async {
    final ordersRef = FirebaseFirestore.instance.collection('orders');
    QuerySnapshot querySnapshot = await ordersRef
        .where('carId', isEqualTo: carId)
        .where('requesterId', isEqualTo: userId)
        .get();
    return querySnapshot.docs.isNotEmpty;
  }

  Future<Map<String, dynamic>?> getShareLink() async {
    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection('shareLink').limit(1).get();
    if (querySnapshot.docs.isNotEmpty) {
      return querySnapshot.docs.first.data() as Map<String, dynamic>;
    } else {
      return null;
    }
  }

  // Obtenir ma position
  Future<String> getPlaceName(double latitude, double longitude) async {
    try {
      List<Placemark> placemarks =
          await placemarkFromCoordinates(latitude, longitude);
      if (placemarks.isNotEmpty) {
        Placemark placemark = placemarks.first;
        String placeName = "${placemark.locality}, ${placemark.country}";
        return placeName;
      }
    } catch (e) {
      print("Erreur lors de la récupération du lieu : $e");
    }
    return AppLocalizations.of(context).translate('unknownLocation');
  }

  Future<User?> getCurrentUser() async {
    return FirebaseAuth.instance.currentUser;
  }

  @override
  void initState() {
    super.initState();
    _fetchCarsDetails();
    _updateOrderStatus();
    _pageController = PageController();
    _pageIndexNotifier = ValueNotifier<int>(0);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _pageIndexNotifier.dispose();
    super.dispose();
  }

  //widget de pagination
  Widget _buildImageIndicator() {
    return Positioned(
      left: 16,
      bottom: 16,
      child: ValueListenableBuilder<int>(
        valueListenable: _pageIndexNotifier,
        builder: (_, value, __) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.6),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${value + 1}/${widget.carImageURLs.length}',
              style: const TextStyle(color: Colors.white),
            ),
          );
        },
      ),
    );
  }

  //mettre à jour la présence de l'utilisateur
  Future<void> _updateOrderStatus() async {
    final user = await getCurrentUser();
    if (user != null) {
      bool ordered =
          await hasUserOrderedCarFromFirestore(widget.carId, user.uid);
      setState(() {
        carOrderStatus = ordered;
      });
    }
  }

  Future<void> _fetchCarsDetails() async {
    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('cars')
          .doc(widget.carId)
          .get();

      CarsModel tempCar =
          CarsModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);

      // Récupérer le nom du lieu à partir des coordonnées
      String tempPlaceName =
          await getPlaceName(tempCar.latitude, tempCar.longitude);

      setState(() {
        car = tempCar;
        placeName = tempPlaceName;
      });
      print(car);
    } catch (error) {
      print("Erreur lors de la récupération des détails de la voiture: $error");
      // Gérer l'erreur comme bon vous semble
    }
  }

  // Fonction pour la suppression

  Future<void> showDeleteConfirmationDialog(
      BuildContext context, String carId, List<String> imageUrls) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Text(AppLocalizations.of(context)
              .translate('confirmDeleteCarMessage')),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(AppLocalizations.of(context).translate('cancel')),
            ),
            TextButton(
              onPressed: () async {
                showLoadingDialog(
                  context: context,
                  message: "Deleting post ... ",
                  barrierDismissible: false,
                );

                // Suppression du véhicule
                await _carsRepository.deleteCar(carId, imageUrls);

                // Retour à la page précédente
                Navigator.pop(context);

                // Retour à la page précédente
                Navigator.pop(context);
                setState(() {
                  Navigator.pop(context);
                });
              },
              child: Text(AppLocalizations.of(context).translate('delete')),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (car == null) {
      return const Center(
        child: CircularProgressIndicator(
          color: Coolors.blueDark,
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context).translate('carDetailsTitle'),
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20.0,
            fontFamily: 'Playfair Display',
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          // Partager la publication
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {},
          ),
          // Bouton de suppression

          // Bouton de suppression
          FutureBuilder<User?>(
            future: getCurrentUser(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SizedBox.shrink();
              }

              if (snapshot.hasData && snapshot.data!.uid == widget.userId) {
                return IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () {
                    // fonction pour afficher la boîte de dialogue de confirmation
                    showDeleteConfirmationDialog(
                        context, widget.carId, widget.carImageURLs);
                  },
                );
              } else {
                return const SizedBox.shrink();
              }
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 8.0),
            ],
          ),

          SizedBox(
            height: MediaQuery.of(context).size.height * 0.4,
            child: Stack(
              children: [
                PageView.builder(
                  controller: _pageController,
                  itemCount: widget.carImageURLs.length,
                  itemBuilder: (context, index) {
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 8.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5.0),
                        image: DecorationImage(
                          image: NetworkImage(widget.carImageURLs[index]),
                          fit: BoxFit.cover,
                        ),
                      ),
                    );
                  },
                  onPageChanged: (index) {
                    _pageIndexNotifier.value = index;
                  },
                ),
                _buildImageIndicator(),
              ],
            ),
          ),

          // Nom et modèle de la voiture
          const SizedBox(height: 16.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.carName,
                style: const TextStyle(
                    color: Coolors.greyDark,
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold),
              ),
              Row(
                children: [
                  const Icon(Icons.location_on,
                      size: 18.0, color: Coolors.greenDark),
                  const SizedBox(width: 8.0),
                  Text(
                    placeName,
                    style: const TextStyle(fontSize: 16.0),
                  ),
                ],
              ),
            ],
          ),

          /*Text(
            widget.carModel,
            style: const TextStyle(color: Coolors.greyDark, fontSize: 18.0),
          ),*/

          // Description et prix dans un Card
          const SizedBox(height: 16.0),

          Card(
            margin: const EdgeInsets.symmetric(vertical: 16.0),
            elevation: 4.0,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text(
                            ' ${formatPrice(widget.carPrice, Localizations.localeOf(context))} ${widget.carCurrency}',
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  Text(
                    widget.carDescription,
                    style: const TextStyle(fontSize: 16.0),
                  ),
                ],
              ),
            ),
          ),

          // Bouton d'achat
          const SizedBox(height: 16.0),
          FutureBuilder<User?>(
            future: getCurrentUser(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SizedBox
                    .shrink(); // ou CircularProgressIndicator si vous voulez montrer un loader.
              }

              if (snapshot.hasData && snapshot.data!.uid != widget.userId) {
                return GestureDetector(
                  onTap: () async {
                    // Check if the car is for sale before processing the order
                    if (car != null && car!.isSale) {
                      // Afficher un message ou effectuer une action pour les voitures qui ne sont pas à vendre
                      QuickAlert.show(
                        context: context,
                        type: QuickAlertType.error,
                        title: "Désolé",
                        text: "Cette voiture n'est plus à vendre.",
                      );

                      print("Cette voiture n'est plus à vendre");
                      return;
                    }

                    // Si l'utilisateur a déjà commandé la voiture, affichez une notification et arrêtez le processus.
                    if (carOrderStatus) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text(
                        AppLocalizations.of(context)
                            .translate('alreadyOrdered'),
                        style: TextStyle(color: context.theme.textAppBar),
                      )));
                      return;
                    }
                    try {
                      QuickAlert.show(
                          context: context,
                          type: QuickAlertType.confirm,
                          title: AppLocalizations.of(context)
                              .translate('markAsPaidConfirmationTitle'),
                          text: AppLocalizations.of(context)
                              .translate('confirmPurchaseRequestMessage'),
                          confirmBtnText: AppLocalizations.of(context)
                              .translate('markAsPaidConfirmationYes'),
                          cancelBtnText: AppLocalizations.of(context)
                              .translate('markAsPaidConfirmationNo'),
                          confirmBtnColor: Coolors.blueDark,
                          onCancelBtnTap: () => Navigator.of(context)
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
                            // récupérer l'utilisateur actuellement connecté
                            User? currentUser = snapshot.data;

                            if (currentUser == null) return;

                            final userRef = FirebaseFirestore.instance
                                .collection('users')
                                .doc(currentUser.uid);
                            final userDoc = await userRef.get();
                            final UserModel user = UserModel.fromMap(
                                userDoc.data() as Map<String, dynamic>);

                            final orderId = FirebaseFirestore.instance
                                .collection('orders')
                                .doc()
                                .id;

                            final order = OrderCars(
                              orderId: orderId,
                              orderTime: DateTime.now(),
                              carId: widget.carId,
                              carName: widget.carName,
                              carImages: widget.carImageURLs,
                              username: widget
                                  .carName, // Il serait préférable d'utiliser un champ dédié pour le nom d'utilisateur
                              price: widget.carPrice,
                              brand: widget.carModel,
                              userId: widget.userId,
                              requesterName: user.username,
                              requesterPhone: user.phoneNumber,
                              requesterId: user.uid,
                              orderDescription: widget.carDescription,
                              orderCurrency: widget.carCurrency,
                            );

                            // Ajouter le nouvel enregistrement à la collection "orders"
                            await _carsRepository.saveOrderCollection(order);

                            final ChatRepository chatRepository =
                                ChatRepository(
                              firestore: FirebaseFirestore.instance,
                              auth: FirebaseAuth.instance,
                            );

                            //Envoie du message
                            Future.microtask(() {
                              String message;

                              if (widget.carType == CarType.news) {
                                message = AppLocalizations.of(context)
                                    .translateWithVariables(
                                  'interestMessageNewCar',
                                  {
                                    "carName": widget.carName,
                                    "brand": widget.carModel,
                                    "price": widget.carPrice.toString(),
                                    "currency": widget.carCurrency,
                                  },
                                );
                              } else {
                                message = AppLocalizations.of(context)
                                    .translateWithVariables(
                                  'interestMessageUsedCar',
                                  {
                                    "carName": widget.carName,
                                    "brand": widget.carModel,
                                    "price": widget.carPrice.toString(),
                                    "currency": widget.carCurrency,
                                  },
                                );
                              }
                              chatRepository.sendTextMessage(
                                context: context,
                                textMessage: message,
                                receiverId: widget.userId, // ID du vendeur
                                senderData:
                                    user, // Données de l'utilisateur qui passe la commande
                              );
                            });

                            // Mettre à jour le document de la voiture dans la collection "cars"
                            // Après avoir enregistré la commande dans la collection 'orders'
                            final carRef = FirebaseFirestore.instance
                                .collection('cars')
                                .doc(widget.carId);
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
                            // Mettre à jour l'état du bouton en fonction de la commande

                            // Mettez à jour le feedback de l'utilisateur

                            // Mettre à jour l'état du bouton en fonction de la commande
                            setState(() {
                              carOrderStatus = true;
                              Navigator.pop(context);
                              if (widget.carType == CarType.news) {
                                QuickAlert.show(
                                  context: context,
                                  type: QuickAlertType.success,
                                  title: AppLocalizations.of(context).translate(
                                      'askingSuccessfullyRecordedTitle'),
                                  text: AppLocalizations.of(context)
                                      .translateWithVariables(
                                          'askingSuccessfullyRecordedText', {
                                    "brand": widget.carModel,
                                    "carName": widget.carName,
                                    'price': widget.carPrice.toStringAsFixed(2),
                                    'username': widget.carUsername,
                                  }),
                                );
                              } else {
                                QuickAlert.show(
                                  context: context,
                                  type: QuickAlertType.success,
                                  title: AppLocalizations.of(context).translate(
                                      'askingSuccessfullyRecordedTitle'),
                                  text: AppLocalizations.of(context)
                                      .translateWithVariables(
                                          'askingSuccessfullyRecordedText2', {
                                    "brand": widget.carModel,
                                    "carName": widget.carName,
                                    'price': widget.carPrice.toStringAsFixed(2),
                                    'username': widget.carUsername,
                                    'duration': widget.carDuration
                                  }),
                                );
                              }
                            });
                          });
                    } catch (error) {
                      print("Erreur lors de la commande: $error");
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text(
                          AppLocalizations.of(context)
                              .translate('orderErrorSnackbar'),
                          style: const TextStyle(color: Coolors.blueDark),
                        )),
                      );
                    }
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12.0),
                      color: Coolors.blueDark,
                    ),
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.lock,
                          color: Coolors.blueDark,
                        ),
                        const SizedBox(width: 8.0),
                        Text(
                          carOrderStatus
                              ? AppLocalizations.of(context)
                                  .translate('carOrderStatusTrue')
                              : AppLocalizations.of(context)
                                  .translate('carOrderStatusFalse'),
                          style: const TextStyle(
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                );
              } else {
                // Si la voiture appartient à l'utilisateur actuel, nous retournons simplement un widget vide
                return const SizedBox.shrink();
              }
            },
          ),

          FutureBuilder<User?>(
            future: getCurrentUser(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SizedBox
                    .shrink(); // ou un widget de chargement si vous préférez
              }

              if (snapshot.hasData && snapshot.data!.uid == widget.userId) {
                return CustomElevatedButton(
                  onPressed: () {
                    QuickAlert.show(
                      context: context,
                      type: QuickAlertType.info,
                      title: AppLocalizations.of(context)
                          .translate('featureComingSoonTitle'),
                      text: AppLocalizations.of(context)
                          .translate('featureComingSoonMessage'),
                      confirmBtnText:
                          AppLocalizations.of(context).translate('ok'),
                      onConfirmBtnTap: () {
                        Navigator.pop(context);
                      },
                    );
                  },
                  text: AppLocalizations.of(context).translate('editCar'),
                );
              } else {
                return const SizedBox.shrink();
              }
            },
          ),
        ],
      ),
    );
  }
}
