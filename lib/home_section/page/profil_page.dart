// ignore_for_file: deprecated_member_use

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lumina/colors/coloors.dart';
import 'package:lumina/colors/extension/extension_theme.dart';
import 'package:lumina/features/auth/widgets/welcome_page.dart';
import 'package:lumina/features/cars/pages/cars_ask.dart';
import 'package:lumina/features/cars/pages/cars_sales.dart';
import 'package:lumina/features/cars/widgets/carts_list.dart';
//import 'package:lumina/home_section/widgets/payment.dart';
import 'package:lumina/home_section/widgets/settings_page.dart';
import 'package:lumina/languages/app_translations.dart';
import 'package:lumina/models/cars_model.dart';
import 'package:lumina/models/user_models.dart';
import 'package:flutter/material.dart';
import 'package:lumina/features/cars/pages/cars_details.dart';
import 'package:url_launcher/url_launcher.dart';

class UserProfiles extends StatefulWidget {
  final UserModel user;

  const UserProfiles({super.key, required this.user});

  @override
  State<UserProfiles> createState() => _UserProfilesState();
}

//ce code est mis pour le profile utilisateur
class _UserProfilesState extends State<UserProfiles>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int postCount = 0;
  int askCount = 0;
  int saleCount = 0;

  void _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      // ignore: avoid_print
      print('Impossible d\'ouvrir le lien');
    }
  }

  // Fonction de déconnexion
  // ignore: unused_element
  void _signOut() async {
    await FirebaseAuth.instance.signOut();
    // ignore: use_build_context_synchronously
    Navigator.pushReplacement(
      // ignore: use_build_context_synchronously
      context,
      MaterialPageRoute(
        builder: (context) => const WelcomePage(),
      ),
    );
  }

  Future<List<CarsModel>> fetchUserCars(String userId,
      {required bool isSale, required bool isAsk}) async {
    Query query = FirebaseFirestore.instance
        .collection('cars')
        .where('userId', isEqualTo: userId);
    if (isSale) query = query.where('isSale', isEqualTo: true);
    if (isAsk) query = query.where('isAsk', isEqualTo: true);

    final querySnapshot = await query.get();
    final carsList = querySnapshot.docs
        .map((doc) =>
            CarsModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
        .toList();

    return carsList;
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    countPosts();
  }

  Future<void> countPosts() async {
    // Récupérer la collection 'cars' depuis Firestore
    final carsCollection = FirebaseFirestore.instance.collection('cars');

    // Récupérer le nombre de post
    final postQuery =
        await carsCollection.where('userId', isEqualTo: widget.user.uid).get();
    postCount = postQuery.docs.length;

    // Récupérer le nombre de demandes de vente
    final askQuery = await carsCollection
        .where('userId', isEqualTo: widget.user.uid)
        .where('isAsk', isEqualTo: true)
        .get();
    askCount = askQuery.docs.length;

    // Récupérer le nombre de ventes
    final saleQuery = await carsCollection
        .where('userId', isEqualTo: widget.user.uid)
        .where('isSale', isEqualTo: true)
        .get();
    saleCount = saleQuery.docs.length;

    // Mettre à jour l'état pour reconstruire l'interface utilisateur
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).backgroundColor,
        title: Text(
          widget.user.username,
          style: TextStyle(
            fontSize: 20,
            //fontWeight: FontWeight.bold,
            color: context.theme.blackText, fontFamily: 'Playfair Display',
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.shopping_cart,
              color: context.theme.blackText,
            ),
            onPressed: () {
              // ignore: avoid_print
              print(
                  'User ID: ${widget.user.uid}'); // Ajoutez ce print pour afficher l'ID de l'utilisateur
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CartsList(
                    userId: widget.user
                        .uid, // Utilisez l'ID de l'utilisateur à partir du UserModel
                  ),
                ),
              );
              // Inutile de forcer la reconstruction du widget parent ici
              setState(() {});
            },
          ),
          // Bouton de déconnexion
          IconButton(
            icon: const Icon(Icons.dehaze),
            color: context.theme.blackText,
            onPressed: () {
              // Afficher le bottom sheet au clic
              showModalBottomSheet(
                context: context,
                builder: (BuildContext context) {
                  return SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ListTile(
                          leading: const Icon(Icons.settings),
                          title: Text(AppLocalizations.of(context)
                              .translate('settingTitle')),
                          onTap: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SettingsPage(
                                  username: widget.user.username,
                                  profileImageUrl: widget.user.profileImageUrl,
                                ),
                              ),
                            );
                          },
                        ),
                        ListTile(
                          leading: const Icon(
                            Icons.privacy_tip,
                          ),
                          title: Text(
                            AppLocalizations.of(context)
                                .translate('privacyPolicyTitle'),
                          ),
                          onTap: () {
                            _launchURL(
                                'lumina-auto-privacy-policy.centicresento.com/');
                          },
                        ),
                        // Ajoutez d'autres options si nécessaire
                      ],
                    ),
                  );
                },
              );
            },
          )
        ],
      ),
      body: Column(
        children: [
          const SizedBox(
            height: 40,
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 60.0,
                  backgroundColor: Coolors.greyDark,
                  backgroundImage: widget.user.profileImageUrl.isNotEmpty
                      ? NetworkImage(widget.user.profileImageUrl)
                      : null,
                  child: widget.user.profileImageUrl.isEmpty
                      ? const Icon(
                          Icons.person,
                          size: 60.0,
                          color: Colors.white,
                        )
                      : null,
                ),

                const SizedBox(
                    height:
                        8.0), // Espace entre l'image de profil et les compteurs
                Row(
                  mainAxisAlignment: MainAxisAlignment
                      .spaceEvenly, // Espacer les éléments uniformément
                  children: [
                    _buildProfileStat(
                        AppLocalizations.of(context).translate('posts'),
                        postCount
                            .toString()), // Utilise une fonction pour éviter la redondance
                    _buildProfileStat(
                        AppLocalizations.of(context).translate('requests'),
                        askCount.toString()),
                    _buildProfileStat(
                        AppLocalizations.of(context).translate('sales'),
                        saleCount.toString()),
                  ],
                ),
              ],
            ),
          ),

          // TabBar pour les collections et les ventes
          TabBar(
            controller: _tabController,
            indicatorColor:
                Coolors.blueDark, // pour changer la couleur de l'indicateur
            labelColor: context.theme
                .blackText, // pour changer la couleur du texte du tab sélectionné
            unselectedLabelColor: Coolors.greyDark,
            tabs: [
              Tab(
                  icon: const Icon(
                    Icons.photo_album,
                    color: Coolors.blueDark,
                  ),
                  text: AppLocalizations.of(context).translate('collections')),
              Tab(
                  icon: const Icon(
                    Icons.shopping_bag,
                    color: Coolors.blueDark,
                  ),
                  text: AppLocalizations.of(context)
                      .translate('requests')), // Icône pour "Demandes "
              Tab(
                  icon: const Icon(
                    Icons.assignment_turned_in,
                    color: Coolors.blueDark,
                  ),
                  text: AppLocalizations.of(context)
                      .translate('sales')), // Icône pour "Ventes"
            ],
          ),
          // Contenu des onglets
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                buildFutureBuilderForTab(widget.user.uid,
                    isSale: false,
                    isAsk: false), // Tous les postes de l'utilisateur
                // Postes où isSale est true
                buildFutureBuilderForTab(widget.user.uid,
                    isSale: false, isAsk: true),
                buildFutureBuilderForTab(widget.user.uid,
                    isSale: true, isAsk: false), // Postes où isAsk est true
              ],
            ),
          ),
        ],
      ),
    );
  }

  FutureBuilder<List<CarsModel>> buildFutureBuilderForTab(String userId,
      {required bool isSale, required bool isAsk}) {
    return FutureBuilder<List<CarsModel>>(
      future: fetchUserCars(userId, isSale: isSale, isAsk: isAsk),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(
              color: Coolors.blueDark,
            ),
          );
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
              child: Text(
            AppLocalizations.of(context).translate('noDataAvailable'),
          ));
        }
        final cars = snapshot.data!;
        return GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount:
                3, // Changez ce nombre pour ajuster le nombre d'éléments par ligne
          ),
          itemCount: cars.length,
          itemBuilder: (context, index) {
            final car = cars[index];
            return GestureDetector(
              onTap: () {
                if (isAsk) {
                  // Si c'est dans la section des demandes, naviguez vers CarsAsk
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CarsAsk(
                        carId: car.carId,
                        carImageURLs: car.imageUrls,
                        userId: car.userId,
                        carName: car.carName,
                        carPrice: car.price,
                        carCurrency: car.currency,
                      ),
                    ),
                  );
                }
                if (isSale) {
                  // si c'est dans la section des ventes, naviguer vers carsSale
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CarSales(
                          carId: car.carId,
                          carImageURLs: car.imageUrls,
                          userId: userId,
                          carName: car.carName,
                          carPrice: car.price,
                          carDescription: car.description,
                          carCurrency: car.currency,
                        ),
                      ));
                } else {
                  // Sinon, naviguez vers DetailCars pour les ventes ou les posts
                  Navigator.push(
                    context,
                    MaterialPageRoute(
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
                }
              },
              child: Padding(
                padding:
                    const EdgeInsets.all(8.0), // marge autour de chaque carte
                child: Card(
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(car.imageUrls[0], fit: BoxFit.cover),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  // Fonction pour construire chaque statistique de profil
  Widget _buildProfileStat(String label, String count) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.2),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            '$count $label',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }
}
