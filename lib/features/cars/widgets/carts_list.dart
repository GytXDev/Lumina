// ignore_for_file: avoid_print, use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lumina/colors/coloors.dart';
import 'package:lumina/colors/extension/extension_theme.dart';
import 'package:flutter/material.dart';
import 'package:lumina/colors/helpers/show_loading_dialog.dart';
import 'package:lumina/features/cars/widgets/isOkay.dart';
import 'package:lumina/features/chat/repository/chat_repository.dart';
import 'package:lumina/languages/app_translations.dart';
import 'package:lumina/models/user_models.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import '../../../models/order_model.dart';
import '../../../models/sales_model.dart';
import '../pages/cars_details.dart';
import '../repository/cars_repository.dart';
import 'custom_order_item.dart';

class CartsList extends StatefulWidget {
  final String userId; // Ajoutez l'uid de l'utilisateur

  const CartsList({super.key, required this.userId});

  @override
  State<CartsList> createState() => _CartsListState();
}

Future<String> getCurrentUserType(String userId) async {
  try {
    final userDoc =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();

    if (userDoc.exists && userDoc.data() != null) {
      return userDoc.data()?['userType'] ?? 'user';
    } else {
      print('User document does not exist or data is null.');
      return 'user'; // default to 'user' if not found
    }
  } catch (e) {
    print('Error fetching user type: $e');
    return 'user'; // default to 'user' in case of an error
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

Future<void> markOrderAsSold(OrderCars order, BuildContext context) async {
  final salesRef = FirebaseFirestore.instance.collection('sales');
  final ordersRef = FirebaseFirestore.instance.collection('orders');
  final carsRef = FirebaseFirestore.instance.collection('cars');

  try {
    // Convertir la commande en vente
    final sale = SalesModel(
      saleId: order.orderId,
      carId: order.carId,
      brand: order.brand,
      carImages: order.carImages,
      requesterId: order.requesterId,
      requesterPhone: order.requesterPhone,
      requesterName: order.requesterName,
      saleDescription: order.orderDescription,
      saleTime: DateTime.now(),
      userId: order.userId,
      price: order.price,
      username: order.username,
    );

    // Ajouter à la collection 'sales'
    await salesRef.doc(sale.saleId).set(sale.toMap());

    String alertMessage =
        AppLocalizations.of(context).translateWithVariables('SaledMessage', {
      'carName': order.carName,
      'requesterName': order.requesterName,
    });

    // Récupérer un admin
    UserModel? adminUser = await getOneAdmin();

    if (adminUser != null) {
      // Envoyer un message de bienvenue
      final ChatRepository chatRepository = ChatRepository(
        firestore: FirebaseFirestore.instance,
        auth: FirebaseAuth.instance,
      );

      Future.microtask(() {
        chatRepository.sendTextMessage(
          context: context,
          textMessage: alertMessage,
          receiverId: order.userId,
          senderData: adminUser,
        );
      });
    }

    // Supprimer de la collection 'orders'
    await ordersRef.doc(order.orderId).delete();

    // Mettre à jour le document de voiture
    final carDoc = await carsRef.doc(order.carId).get();
    if (carDoc.exists) {
      await carsRef.doc(order.carId).update({
        'isSale': true,
        'isAsk': false,
        'orderCount': 0,
      });
    }

    // Afficher le quickAlert après l'opération réussie
    QuickAlert.show(
      context: context,
      type: QuickAlertType.success,
      title: AppLocalizations.of(context).translate('success'),
      text: AppLocalizations.of(context).translate('saleMarkedSuccess'),
    );
  } catch (e) {
    print('error $e');
  }
}

class _CartsListState extends State<CartsList> {
  CarsRepository carsRepository = CarsRepository();
  String userType = 'user';

  void onReportOrderPressed(OrderCars order, BuildContext context) async {
    try {
      await carsRepository.reportOrder(order, context);

      // Ferme le dialogue actuel (si ouvert) avant de montrer un nouveau QuickAlert
      Navigator.pop(context); // Ajoutez cette ligne si nécessaire

      QuickAlert.show(
        context: context,
        type: QuickAlertType.success,
        title: AppLocalizations.of(context).translate('succes'),
        text: AppLocalizations.of(context).translate('orderReportedSuccess'),
      );
    } catch (e) {
      // Ferme le dialogue actuel (si ouvert) avant de montrer un nouveau QuickAlert
      Navigator.pop(context); // Ajoutez cette ligne si nécessaire

      QuickAlert.show(
        context: context,
        type: QuickAlertType.error,
        title: AppLocalizations.of(context).translate('error'),
        text: AppLocalizations.of(context).translate('orderReportError'),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _initUserType();
  }

  Future<void> _initUserType() async {
    String type = await getCurrentUserType(widget.userId);
    print(
        "User ID: ${widget.userId}, User Type: $type"); // Ajoutez cette ligne pour déboguer
    setState(() {
      userType = type;
    });
  }

  @override
  Widget build(BuildContext context) {
    late Stream<QuerySnapshot> orderStream;

    if (userType == "admin") {
      orderStream = carsRepository.ordersCollection
          .snapshots(); // pour un admin, afficher toutes les commandes
    } else {
      orderStream = carsRepository.ordersCollection
          .where('requesterId', isEqualTo: widget.userId)
          .snapshots(); // pour un utilisateur normal, afficher seulement ses commandes
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).translate('requestsList')),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          if (userType == "admin")
            IconButton(
              icon: const Icon(
                  Icons.admin_panel_settings), // Utilisez l'icône souhaité
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const IsOkayPage(),
                  ),
                );
              },
            ),
          // Ajoutez d'autres éléments d'app bar selon vos besoins
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: orderStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: Coolors.blueDark,
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text(
                AppLocalizations.of(context).translate('noRequestsAvailable'),
                style: const TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            );
          }

          final orders = snapshot.data!.docs
              .map((doc) =>
                  OrderCars.fromMap(doc.data() as Map<String, dynamic>, doc.id))
              .toList();

          return ListView.builder(
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];

              return CustomOrderItem(
                order: order,
                onMarkAsSoldPressed: userType == "admin"
                    ? () {
                        QuickAlert.show(
                          context: context,
                          type: QuickAlertType.confirm,
                          title: AppLocalizations.of(context)
                              .translate('markAsPaidConfirmationTitle'),
                          text: AppLocalizations.of(context)
                              .translate('confirmMarkAsSoldMessage'),
                          confirmBtnText: AppLocalizations.of(context)
                              .translate('markAsPaidConfirmationYes'),
                          cancelBtnText: AppLocalizations.of(context)
                              .translate('markAsPaidConfirmationNo'),
                          // Si l'utilisateur confirme
                          onConfirmBtnTap: () {
                            // Exécutez la fonction pour marquer la commande comme vendue
                            markOrderAsSold(order, context);
                            Navigator.of(context).pop(); // Ferme le QuickAlert
                          },
                          onCancelBtnTap: () => Navigator.of(context)
                              .pop(), // Action si l'utilisateur annule
                        );
                      }
                    : null,
                onReportOrderPressed:
                    userType != "admin" && order.isAlert == false
                        ? () {
                            onReportOrderPressed(order, context);
                          }
                        : null,
                onDeletePressed: () async {
                  if (order.isAlert) {
                    QuickAlert.show(
                      context: context,
                      type: QuickAlertType.warning,
                      title: AppLocalizations.of(context).translate('error'),
                      text: AppLocalizations.of(context)
                          .translate('cannotDeleteReportedOrder'),
                    );
                  } else {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          content: Text(
                            AppLocalizations.of(context)
                                .translate('confirmDeleteOrder'),
                            style: const TextStyle(color: Coolors.greyDark),
                          ),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop(false);
                              },
                              child: Text(
                                AppLocalizations.of(context)
                                    .translate('cancel'),
                                style: const TextStyle(color: Coolors.greyDark),
                              ),
                            ),
                            TextButton(
                              onPressed: () async {
                                showLoadingDialog(
                                  context: context,
                                  message: AppLocalizations.of(context)
                                      .translate('deletingRequest'),
                                  barrierDismissible: false,
                                );

                                // Supprimez la commande de la collection 'orders'
                                await carsRepository.deleteOrder(order.orderId);

                                // Mettez à jour le champ 'orderCount' du document de voiture correspondant dans la collection 'cars'
                                final carRef = FirebaseFirestore.instance
                                    .collection('cars')
                                    .doc(order.carId);
                                final carDoc = await carRef.get();
                                if (carDoc.exists) {
                                  int orderCount =
                                      carDoc.data()?['orderCount'] ?? 0;
                                  orderCount =
                                      orderCount > 0 ? orderCount - 1 : 0;
                                  bool isAsk = orderCount > 0;
                                  await carRef.update({
                                    'orderCount': orderCount,
                                    'isAsk': isAsk,
                                  });

                                  // Fermer la boîte de dialogue après la suppression
                                  Navigator.of(context).pop(true);
                                  setState(() {
                                    Navigator.pop(context);
                                  });
                                }
                              },
                              child: Text(
                                AppLocalizations.of(context)
                                    .translate('delete'),
                                style: TextStyle(color: context.theme.redColor),
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  }
                },
                onDetailPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DetailCars(
                        userId: order.userId,
                        carId: order.carId,
                        carName: order
                            .brand, // Utilisez les informations de la commande sélectionnée
                        carModel: order.brand,
                        carImageURLs: order.carImages.isNotEmpty
                            ? order.carImages
                            : ['assets/default_car_image.png'],
                        // Image par défaut si aucune image n'est disponible
                        carDescription: order
                            .orderDescription, // Remplacez par la description de la commande si disponible
                        carPrice: order.price,
                        carCurrency: order.orderCurrency,
                      ),
                    ),
                  );
                },
                showBellIcon: userType == "admin" &&
                    order.isAlert, // Si une commande est signalée
              );
            },
          );
        },
      ),
    );
  }
}
