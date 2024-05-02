// ignore_for_file: unnecessary_null_comparison, avoid_print

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lumina/colors/coloors.dart';
import 'package:lumina/languages/app_translations.dart';
import 'package:lumina/models/order_model.dart';
import 'package:lumina/models/user_models.dart';
import 'package:lumina/routes/routes_pages.dart';

class CarsAsk extends StatefulWidget {
  const CarsAsk({
    super.key,
    required this.carId,
    required this.carImageURLs,
    required this.userId,
    required this.carName,
    required this.carPrice,
    required this.carCurrency,
  });

  final String carId;
  final List<String> carImageURLs;
  final String userId;
  final double carPrice;
  final String carName;
  final String carCurrency;

  @override
  State<CarsAsk> createState() => _CarsAskState();
}

class _CarsAskState extends State<CarsAsk> {
  late final PageController _pageController;
  late final ValueNotifier<int> _pageIndexNotifier;
  List<OrderCars> usersInquired = [];
  Map<String, UserModel?> userDetailsMap = {};

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _pageIndexNotifier = ValueNotifier<int>(0);
    getUserAsked();
  }

  String formatPrice(double price, Locale locale) {
    final format = NumberFormat("#,###", locale.toString());
    print('$locale');
    return format.format(price);
  }

  Future<void> getUserAsked() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('orders')
          .where('carId', isEqualTo: widget.carId)
          .get();

      List<OrderCars> users = querySnapshot.docs
          .map((doc) =>
              OrderCars.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();

      setState(() {
        usersInquired = users;
      });

      // Charger les détails des utilisateurs
      await loadUserDetails();
    } catch (error) {
      print(
          "Erreur lors de la récupération des utilisateurs demandant la voiture: $error");
    }
  }

  Future<void> loadUserDetails() async {
    for (OrderCars user in usersInquired) {
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
        title: Text(
          AppLocalizations.of(context).translate('carAskedTitle'),
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
          const SizedBox(height: 16.0),
          Text(
            widget.carName,
            style: const TextStyle(
                color: Coolors.greyDark,
                fontSize: 18.0,
                fontWeight: FontWeight.bold),
          ),
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
                            '${formatPrice(widget.carPrice, Localizations.localeOf(context))} ${widget.carCurrency}',
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
          ListView.builder(
            shrinkWrap: true,
            itemCount: usersInquired.length,
            itemBuilder: (context, index) {
              final user = usersInquired[index];
              UserModel? userDetails = userDetailsMap[user.requesterId];

              if (userDetails != null &&
                  userDetails.profileImageUrl.isNotEmpty) {
                return ListTile(
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      Routes.chat,
                      arguments: userDetails,
                    );
                  },
                  title: Text(userDetails.username),
                  subtitle: Text(
                    AppLocalizations.of(context).translateWithVariables(
                      'orderedOn',
                      {
                        "orderDate": userDetails != null
                            ? DateFormat(
                                    'dd MMMM yyyy',
                                    Localizations.localeOf(context)
                                        .languageCode)
                                .format(user.orderTime)
                            : 'Unknown',
                      },
                    ),
                  ),
                  leading: CircleAvatar(
                    backgroundColor: Coolors.greyDark,
                    radius: 24,
                    backgroundImage: userDetails.profileImageUrl != null &&
                            userDetails.profileImageUrl.isNotEmpty
                        ? CachedNetworkImageProvider(
                            userDetails.profileImageUrl)
                        : null,
                    child: userDetails.profileImageUrl == null ||
                            userDetails.profileImageUrl.isEmpty
                        ? const Icon(Icons.person, color: Colors.white)
                        : null,
                  ),
                );
              } else {
                // Gérer le cas où userDetails ou profileImageUrl est null ou une chaîne vide
                return Container(); // Ou tout autre widget de remplacement
              }
            },
          ),
        ],
      ),
    );
  }
}
