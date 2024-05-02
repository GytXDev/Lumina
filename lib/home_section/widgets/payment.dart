// ignore_for_file: avoid_print, deprecated_member_use

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ionicons/ionicons.dart';
import 'package:lumina/colors/coloors.dart';
import 'package:lumina/colors/extension/extension_theme.dart';
import 'package:lumina/features/cars/repository/cars_repository.dart';
import 'package:lumina/features/chat/repository/chat_repository.dart';
import 'package:lumina/languages/app_translations.dart';
import 'package:lumina/models/cars_model.dart';
import 'package:lumina/models/sale_report_model.dart';
import 'package:lumina/models/sales_model.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';

class PaymentsCard extends StatefulWidget {
  const PaymentsCard({super.key, required this.uid});
  final String uid;

  @override
  State<PaymentsCard> createState() => _PaymentsCardState();
}

final CollectionReference carsCollection =
    FirebaseFirestore.instance.collection('cars');

// Récupérer les voitures de l'utilisateur connecté avec isSale à true
Future<List<CarsModel>> getUserCars(String uid) async {
  try {
    final QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection(('cars'))
        .where('userId', isEqualTo: uid)
        .where('isSale', isEqualTo: true)
        .get();

    return querySnapshot.docs
        .map((doc) =>
            CarsModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
        .toList();
  } catch (e) {
    print('Erreur lors de la récupération des voitures de l\'utilisateur : $e');
    // Gérer l'erreur de manière appropriée
    return [];
  }
}

Future<CarsModel> getUserCar(String carId) async {
  try {
    DocumentSnapshot documentSnapshot = await carsCollection.doc(carId).get();
    return CarsModel.fromMap(
        documentSnapshot.data() as Map<String, dynamic>, carId);
  } catch (e) {
    print('Erreur lors de la récupération de la voiture : $e');
    // Gérer l'erreur de manière appropriée
    // ignore: use_rethrow_when_possible
    throw e;
  }
}

class _PaymentsCardState extends State<PaymentsCard> {
  final CarsRepository _carsRepository = CarsRepository();
  List<CarsModel> userCars = [];
  final ChatRepository _chatRepository = ChatRepository(
    firestore: FirebaseFirestore.instance,
    auth: FirebaseAuth.instance,
  );

  String formatPrice(double price, Locale locale) {
    final format = NumberFormat("#,###", locale.toString());
    print('$locale');
    return format.format(price);
  }

  String formatPercentage(double percentage, Locale locale) {
    return NumberFormat("#,###.##").format(percentage);
  }

  @override
  void initState() {
    super.initState();
    loadUserCars(widget.uid); // Passez l'ID de l'utilisateur à la fonction
  }

  Future<void> loadUserCars(String userId) async {
    try {
      List<CarsModel> cars = await getUserCars(userId);
      setState(() {
        userCars = cars;
      });
      print('ceci est le $userId');
    } catch (e) {
      print("Erreur lors du chargement des voitures de l'utilisateur : $e");
      // Gérer l'erreur de manière appropriée
    }
  }

  // Fonction pour calculer debitPrice
  double calculateDebitPrice(double price, CarType yearOrNew) {
    // Utilisez directement l'énumération pour la comparaison
    final double percentage = yearOrNew == CarType.news ? 0.8 : 1.2;
    return price * (percentage / 100);
  }

  Future<void> saveSalesReport(SalesReportModel salesReport) async {
    try {
      final salesReportData = salesReport.toMap();

      // Ajouter le rapport de vente à la collection 'salesReport'
      await FirebaseFirestore.instance
          .collection('salesReport')
          .add(salesReportData);

      print(
          'Rapport de vente enregistré avec succès dans la collection "salesReport".');
    } catch (e) {
      throw 'Erreur lors de l\'enregistrement du rapport de vente : $e';
    }
  }

  Future<String?> getRequesterName(String carId) async {
    try {
      final QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('sales')
          .where('carId', isEqualTo: carId)
          .limit(
              1) // On prend seulement un résultat, car il devrait y avoir au plus un résultat
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        // Si le document existe, retournez le requesterName
        return SalesModel.fromMap(
          querySnapshot.docs.first.data() as Map<String, dynamic>,
          querySnapshot.docs.first.id,
        ).requesterName;
      } else {
        // Sinon, retournez null ou une valeur par défaut selon votre logique
        return null;
      }
    } catch (e) {
      print('Erreur lors de la récupération du requesterName : $e');
      // Gérer l'erreur de manière appropriée
      return null;
    }
  }

  // Permettre à l'utilisateur de signalement le don 1,2% sur sa vente
  Future<void> markCarAsPaid(String carId) async {
    try {
      await carsCollection.doc(carId).update({
        'isPayed': true,
      });

      // Obtenez les détails de la voiture
      CarsModel carDetails = await getUserCar(carId);

      // Calculez le montant du don 1,2%/0,8%
      double debitPrice =
          calculateDebitPrice(carDetails.price, carDetails.yearOrNew);

      // Obtenez le requesterName en utilisant la fonction getRequesterName
      String? buyerName = await getRequesterName(carId);

      // Assurez-vous d'avoir un nom d'acheteur valide avant de l'assigner
      buyerName ??= 'Acheteur Inconnu';

      // Créez un objet SalesReportModel
      SalesReportModel salesReport = SalesReportModel(
        userId: carDetails.userId,
        date: DateTime.now(),
        carPrice: carDetails.price,
        debitPrice: debitPrice,
        carImageUrl:
            carDetails.imageUrls.isNotEmpty ? carDetails.imageUrls.first : '',
        buyerName: buyerName,
        sellerName: carDetails
            .username, // Assurez-vous d'avoir cette information dans vos détails de voiture
      );

      // Enregistrez le rapport de vente
      await saveSalesReport(salesReport);

      _sendAdminMessage(carDetails, debitPrice);
      // Générez le PDF et imprimez-le

      print(
          'Le statut isPayed de la voiture a été mis à jour avec succès et le rapport de vente a été enregistré.');
    } catch (e) {
      throw 'Erreur lors de la mise à jour du statut isPayed de la voiture : $e';
    }
  }

  // Fonction pour envoyer un message par l'administrateur

  Future<void> _sendAdminMessage(
      CarsModel carDetails, double debitPrice) async {
    try {
      final adminDetails = await _carsRepository.getOneAdmin();

      if (adminDetails != null) {
        String carName = carDetails.carName;
        String carModel = carDetails.brand;
        double salePrice = carDetails.price;
        String currency = carDetails.currency;
        double commissionRate = carDetails.yearOrNew == CarType.news
            ? 0.8
            : 1.2; // Le taux de commission
        double commissionAmount =
            debitPrice; // Le montant de la commission calculé

        // Préparation du message avec les variables dynamiques
        String textMessage =
            // ignore: use_build_context_synchronously
            AppLocalizations.of(context).translateWithVariables('paidMessage', {
          'carName': carName,
          'carModel': carModel,
          'salePrice': salePrice.toStringAsFixed(2),
          'commissionAmount': commissionAmount.toStringAsFixed(2),
          'currency': currency,
          'commissionRate': commissionRate.toString(),
        });

        Future.microtask(() {
          _chatRepository.sendTextMessage(
            context: context,
            textMessage: textMessage,
            receiverId: widget.uid,
            senderData: adminDetails,
          );
        });
      } else {
        print('Détails de l\'admin non disponibles');
      }
    } catch (e) {
      print('Erreur lors de l\'envoi du message admin : $e');
    }
  }

  // Fonction pour récupérer les informations de la collection 'airtelMoney'
  Future<Map<String, dynamic>?> getAirtelMoneyInfo() async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('airtelMoney')
        .limit(1)
        .get();
    if (querySnapshot.docs.isNotEmpty) {
      return querySnapshot.docs.first.data() as Map<String, dynamic>;
    } else {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).backgroundColor,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Ionicons.chevron_back_outline,
              color: context.theme.blackText),
        ),
        leadingWidth: 60,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            FutureBuilder<Map<String, dynamic>?>(
                future: getAirtelMoneyInfo(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    // Il est également utile d'imprimer l'erreur pour le débogage
                    print(
                        "Erreur de chargement des données: ${snapshot.error}");
                    return Text('Erreur: ${snapshot.error}');
                  }
                  // Si les données sont chargées
                  if (snapshot.hasData) {
                    var airtelMoneyData = snapshot.data!;
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 10),
                        padding: const EdgeInsets.all(20),
                        height: 250,
                        width: 400,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.grey.withOpacity(0.8),
                              Colors.black.withOpacity(0.9)
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    Text(
                                      AppLocalizations.of(context)
                                          .translate('airtelMoneyUsername'),
                                      style: const TextStyle(
                                        fontSize:
                                            13, // Personnalisez la taille de la police
                                        fontWeight: FontWeight.bold,
                                        color: Color(
                                            0xff1C2833), // Couleur du texte
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    Text(
                                      airtelMoneyData['username'] ??
                                          'Nom Inconnu',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontFamily: 'PlayFair Display',
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white60,
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Image.asset(
                                          'assets/images/ecc.png',
                                          width: 50,
                                          height: 50,
                                        ),
                                      ],
                                    ),
                                    const SizedBox(
                                        width: 30), // Ajoutez cet espacement
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          airtelMoneyData['phoneNumber'] ??
                                              'Aucun',
                                          style: const TextStyle(
                                            fontSize: 17,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white38,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                SizedBox(
                                  width: 105,
                                  height: 105,
                                  child: Image.asset(
                                      'assets/images/airtel_money.png'),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    );
                  }
                  return const Center(child: Text("Aucune donnée disponible"));
                }),
            const SizedBox(height: 40),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.of(context).translate('salesReports'),
                    style: TextStyle(
                      fontSize: 20,
                      color: Coolors.blueDark, // Couleur du texte
                      shadows: [
                        Shadow(
                          color:
                              Colors.grey.withOpacity(0.5), // Ombre grise douce
                          blurRadius: 2, // Flou de l'ombre
                          offset: const Offset(1, 1), // Décalage de l'ombre
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8), // Ajout d'un espace vertical
                  Divider(
                    color: Colors.grey.withOpacity(0.5), // Couleur du divider
                    thickness: 1.5, // Épaisseur du divider
                  ),
                ],
              ),
            ),
            userCars.isEmpty
                ? Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Center(
                      child: Text(
                        AppLocalizations.of(context).translate('noSalesYet'),
                      ),
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: userCars.length,
                    itemBuilder: (context, index) {
                      return Card(
                        elevation: 3,
                        margin: const EdgeInsets.symmetric(
                            vertical: 8, horizontal: 16),
                        child: InkWell(
                          onTap: () {
                            // Traitement lorsque l'utilisateur clique sur la carte
                          },
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(16),
                            title: Row(
                              children: [
                                Image.network(
                                  userCars[index].imageUrls.isNotEmpty
                                      ? userCars[index].imageUrls.first
                                      : "",
                                  width: 75,
                                  height: 75,
                                  fit: BoxFit.cover,
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "${userCars[index].carName} - ${formatPrice(userCars[index].price, Localizations.localeOf(context))} ${userCars[index].currency}",
                                        style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        AppLocalizations.of(context)
                                            .translateWithVariables(
                                          userCars[index].yearOrNew ==
                                                  CarType
                                                      .news // Utilisez la valeur énumérée directement
                                              ? "debitPercentageTextNew"
                                              : "debitPercentageTextOld",
                                          {
                                            "debitPercentage": formatPercentage(
                                              calculateDebitPrice(
                                                userCars[index].price,
                                                userCars[index]
                                                    .yearOrNew, // Pas besoin de conversion
                                              ),
                                              Localizations.localeOf(context),
                                            ),
                                            "currency":
                                                userCars[index].currency,
                                          },
                                        ),
                                        style: const TextStyle(
                                            fontSize: 16, color: Colors.grey),
                                      )
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 18),
                                userCars[index].isPayed
                                    ? Text(AppLocalizations.of(context)
                                        .translate('alreadyPaid'))
                                    : ElevatedButton(
                                        onPressed: () {
                                          QuickAlert.show(
                                            onCancelBtnTap: () {
                                              Navigator.pop(context);
                                            },
                                            context: context,
                                            type: QuickAlertType.confirm,
                                            title: AppLocalizations.of(context)
                                                .translate(
                                                    'markAsPaidConfirmationTitle'),
                                            text: AppLocalizations.of(context)
                                                .translate(
                                                    'markAsPaidConfirmationText'),
                                            textAlignment: TextAlign.center,
                                            confirmBtnText: AppLocalizations.of(
                                                    context)
                                                .translate(
                                                    'markAsPaidConfirmationYes'),
                                            cancelBtnText: AppLocalizations.of(
                                                    context)
                                                .translate(
                                                    'markAsPaidConfirmationNo'),
                                            confirmBtnColor: Coolors.greenDark,
                                            onConfirmBtnTap: () {
                                              markCarAsPaid(
                                                  userCars[index].carId);
                                              loadUserCars(widget.uid);
                                              Navigator.pop(context);
                                            },
                                          );
                                        },
                                        child: Text(AppLocalizations.of(context)
                                            .translate('markAsPaidButtonText')),
                                      ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ],
        ),
      ),
    );
  }
}
