// ignore_for_file: avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lumina/colors/extension/extension_theme.dart';
import 'package:lumina/languages/app_translations.dart';

import '../../colors/coloors.dart';
import '../../models/user_models.dart';
import '../widgets/cars_post.dart';

class CarsPage extends StatefulWidget {
  const CarsPage({super.key});

  @override
  State<CarsPage> createState() => _CarsPageState();
}

class _CarsPageState extends State<CarsPage> {
  String searchQuery = '';
  final searchController = TextEditingController();
  String? selectedLabel;
  UserModel? currentUser;

  Future<UserModel> getUserData(String uid) async {
    DocumentSnapshot<Map<String, dynamic>> userDoc =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();
    return UserModel.fromMap(userDoc.data()!);
  }

  Future<void> checkSubscriptionStatus() async {
    UserModel? user = await getCurrentUser();
    if (user != null && user.subscriptionEndDate != null) {
      final currentDateTime = DateTime.now();
      if (user.subscriptionEndDate!.isBefore(currentDateTime)) {
        // Si la date d'expiration est dépassée, remettre l'abonnement à "standard"
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({
          'subscriptionType': 'standard',
          'subscriptionEndDate': null,
        });

        setState(() {
          currentUser = currentUser!.copyWith(
            subscriptionType: 'standard',
            subscriptionEndDate: null,
          );
        });
        print('Abonnement expiré, basculé à standard');
        print(currentDateTime);
      } else {
        print('Abonnement valide jusqu\'à ${user.subscriptionEndDate}');
        print(currentDateTime);
      }
    }
  }

  Future<UserModel?> getCurrentUser() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        return getUserData(user.uid);
      }
      return null;
    } catch (e) {
      print("Error retrieving current user: $e");
      return null;
    }
  }

  @override
  void initState() {
    super.initState();
    _initializeCurrentUser();
    checkSubscriptionStatus();
    searchController.addListener(() {
      setState(() {
        searchQuery = searchController.text;
      });
    });
  }

  void _initializeCurrentUser() async {
    currentUser = await getCurrentUser();
    // Mettre à jour l'état de la page après l'initialisation de currentUser
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  // ignore: unused_element
  void _subscribeToPlan(String plan) async {
    if (currentUser != null && currentUser!.subscriptionType == 'standard') {
      final currentDateTime = DateTime.now();
      final subscriptionEndDate = currentDateTime.add(const Duration(days: 15));
      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser!.uid)
            .update({
          'subscriptionType': 'premium',
          'subscriptionEndDate': subscriptionEndDate.toIso8601String(),
        });

        setState(() {
          currentUser = currentUser!.copyWith(
            subscriptionType: 'premium',
            subscriptionEndDate: subscriptionEndDate,
          );
        });
        print(
            'Souscription à l\'abonnement premium jusqu\'à $subscriptionEndDate');
      } catch (e) {
        print('Erreur lors de la mise à jour de l\'abonnement: $e');
      }
    } else {
      print('Souscription non autorisée');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: Row(
          children: [
            const Text(
              'Lumina',
              style: TextStyle(
                color: Coolors.blueDark,
                fontWeight: FontWeight.bold,
                fontSize: 26,
                fontFamily: 'Playfair Display',
              ),
            ),
            if (currentUser?.subscriptionType == 'premium')
              const Icon(
                Icons.star,
                color: Colors.red,
                size: 24.0, // Icône premium
              ),
          ],
        ),
        actions: const [
          /* if (currentUser?.subscriptionType == 'standard')
            const SizedBox(
              height: 18.0,
            ),
          ElevatedButton(
            onPressed: () => _subscribeToPlan,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDC7633), // Couleur du texte
              padding: const EdgeInsets.symmetric(
                  horizontal: 11, vertical: 10), // Padding réduit
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0), // Bordure arrondie
              ),
            ),
            child: const Text(
              'Passer au forfait premium',
              style: TextStyle(
                fontSize: 15, // Taille de police réduite
              ),
            ),
          ),
          const SizedBox(
            width: 18.0,
          )*/
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Barre de recherche transparente avec une marge
          Container(
            margin:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
            decoration: BoxDecoration(
              color: context.theme.searchBar,
              borderRadius: BorderRadius.circular(30.0), // Coins très arrondis
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  spreadRadius: 0,
                  blurRadius: 10,
                  offset: const Offset(0, 4), // Ombre douce
                ),
              ],
            ),
            child: TextFormField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: AppLocalizations.of(context).translate('search'),
                hintStyle: const TextStyle(
                    color: Coolors.greyDark), // Style du texte indicatif
                border: InputBorder.none, // Suppression de la bordure
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20.0, vertical: 15.0), // Padding interne
                prefixIcon: const Icon(Icons.search,
                    color: Coolors.blueDark), // Icône de recherche
                suffixIcon: searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Coolors.blueDark),
                        onPressed: () {
                          searchController.clear();
                          // Mise à jour de l'UI après la suppression du texte
                          setState(() {});
                        },
                      )
                    : null,
                filled: true,
                fillColor:
                    Colors.transparent, // Fond de remplissage transparent
              ),
            ),
          ),

          // Liste de sélection horizontale
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildListButton(FilterKeys.all),
                _buildListButton(FilterKeys.newCars),
                _buildListButton(FilterKeys.occasion),
                _buildListButton(FilterKeys.mostLoved),
                _buildListButton(FilterKeys.bestsellers),
                _buildListButton(FilterKeys.mostExpensive),
                _buildListButton(FilterKeys.theCheapest),
              ],
            ),
          ),
          Expanded(
            child: currentUser == null
                ? const Center(child: CircularProgressIndicator())
                : CarPost(
                    searchQuery: searchQuery,
                    selectedLabel: selectedLabel,
                    currentUser: currentUser!,
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildListButton(String filterKey) {
    String label = AppLocalizations.of(context).translate(filterKey);
    return Container(
      margin: const EdgeInsets.all(8.0),
      child: TextButton(
        onPressed: () {
          setState(() {
            selectedLabel = filterKey;
          });
        },
        style: TextButton.styleFrom(
          backgroundColor: Coolors.blueDark,
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25.0),
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}

//Classe avec pour les filtrages
class FilterKeys {
  static const all = 'all';
  static const newCars = 'new';
  static const occasion = 'occasion';
  static const mostLoved = 'mostLoved';
  static const bestsellers = 'bestsellers';
  static const mostExpensive = 'mostExpensive';
  static const theCheapest = 'theCheapest';
}
