// ignore_for_file: avoid_print

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lumina/colors/coloors.dart';
import 'package:lumina/languages/app_translations.dart';
import 'package:lumina/models/cars_model.dart';
import 'package:lumina/models/sales_model.dart';
import 'package:lumina/models/user_models.dart';
import 'package:lumina/routes/routes_pages.dart';

class CarSales extends StatefulWidget {
  const CarSales({
    super.key,
    required this.carId,
    required this.carImageURLs,
    required this.userId,
    required this.carName,
    required this.carPrice,
    required this.carDescription,
    required this.carCurrency,
  });

  final String carId;
  final List<String> carImageURLs;
  final String userId;
  final double carPrice;
  final String carName;
  final String carDescription;
  final String carCurrency;

  @override
  State<CarSales> createState() => _CarSalesState();
}

class _CarSalesState extends State<CarSales> {
  late final PageController _pageController;
  late final ValueNotifier<int> _pageIndexNotifier;
  List<SalesModel> usersInquired = [];
  late Map<String, UserModel?> userDetailsMap;

  CarsModel? car;

  String formatPrice(double price, Locale locale) {
    final format = NumberFormat("#,###", locale.toString());
    print('$locale');
    return format.format(price);
  }

  Future<void> getUserSaled() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('sales')
          .where('carId', isEqualTo: widget.carId)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        SalesModel user = SalesModel.fromMap(
          querySnapshot.docs.first.data() as Map<String, dynamic>,
          querySnapshot.docs.first.id,
        );

        setState(() {
          usersInquired = [user];
        });

        // Charger les détails de l'utilisateur
        await loadUserDetails();
      }
    } catch (error) {
      print(
          "Erreur lors de la récupération de l'utilisateur qui a acheté la voiture: $error");
    }
  }

  Future<void> loadUserDetails() async {
    if (usersInquired.isNotEmpty) {
      SalesModel user = usersInquired.first;
      UserModel? userDetails = await getUserDetails(user.requesterId);
      setState(() {
        userDetailsMap[user.requesterId] = userDetails;
      });
    }
  }

  Future<UserModel?> getUserDetails(String userId) async {
    try {
      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (userSnapshot.exists) {
        return UserModel.fromMap(userSnapshot.data() as Map<String, dynamic>);
      } else {
        return null;
      }
    } catch (error) {
      print(
          "Erreur lors de la récupération des détails de l'utilisateur: $error");
      return null;
    }
  }

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _pageIndexNotifier = ValueNotifier<int>(0);
    userDetailsMap = {}; // Initialisation de userDetailsMap
    // Appeler la fonction pour récupérer les informations de vente
    getUserSaled();
  }

  @override
  void dispose() {
    super.dispose();
    _pageController.dispose();
    _pageIndexNotifier.dispose();
  }

  // Widget de pagination
  Widget _buildImageIndicator() {
    return Positioned(
      left: 16,
      bottom: 16,
      child: ValueListenableBuilder<int>(
        valueListenable: _pageIndexNotifier,
        builder: (_, value, __) {
          return Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 4,
            ),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          AppLocalizations.of(context).translate('carSaledTitle'),
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20.0,
            fontFamily: 'Playfair Display',
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
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
          Text(
            widget.carName,
            style: const TextStyle(
                color: Coolors.greyDark,
                fontSize: 18.0,
                fontWeight: FontWeight.bold),
          ),

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
                  Text(
                    widget.carDescription,
                    style: const TextStyle(fontSize: 16.0),
                  ),
                  const SizedBox(height: 16.0),
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
                ],
              ),
            ),
          ),

          // Ajouter un autre Card ou un widget pour les informations de vente
          Card(
            margin: const EdgeInsets.symmetric(vertical: 16.0),
            elevation: 4.0,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.of(context).translate('buyerDetails'),
                    style: const TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  if (userDetailsMap.isNotEmpty)
                    ListTile(
                      //tileColor: Colors.grey.withOpacity(0.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      contentPadding: const EdgeInsets.all(8.0),
                      onTap: () {
                        UserModel? userDetails = userDetailsMap.values
                            .first; // Obtenir le premier (et unique) utilisateur
                        if (userDetails != null) {
                          Navigator.pushNamed(
                            context,
                            Routes.chat,
                            arguments: userDetails,
                          );
                        }
                      },
                      title: userDetailsMap.values.first != null
                          ? Text(userDetailsMap.values.first!.username)
                          : Text(AppLocalizations.of(context)
                              .translate('noBuyerDetails')),
                      leading: userDetailsMap.values.first?.profileImageUrl !=
                                  null &&
                              userDetailsMap
                                  .values.first!.profileImageUrl.isNotEmpty
                          ? CircleAvatar(
                              radius: 24,
                              backgroundImage: CachedNetworkImageProvider(
                                userDetailsMap.values.first!.profileImageUrl,
                              ),
                            )
                          : const CircleAvatar(
                              radius: 24,
                              backgroundColor: Coolors.greyDark,
                              child: Icon(Icons.person, color: Colors.white),
                            ),
                      
                    ),

                  const SizedBox(height: 16.0),
                  // Affichez les détails de la vente ici
                  Text(
                    AppLocalizations.of(context).translate('saleDetails'),
                    style: const TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  if (usersInquired.isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppLocalizations.of(context)
                              .translateWithVariables('recordedAsSold', {
                            "saleDate": DateFormat(
                                    'dd MMMM yyyy',
                                    Localizations.localeOf(context)
                                        .languageCode)
                                .format(usersInquired.first.saleTime)
                          }),
                        ),
                      ],
                    )
                  else
                    const Text('No sale details available'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
