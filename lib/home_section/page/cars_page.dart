import 'package:flutter/material.dart';
import 'package:lumina/colors/extension/extension_theme.dart';
import 'package:lumina/languages/app_translations.dart';

import '../../colors/coloors.dart';
import '../widgets/cars_post.dart';

class CarsPage extends StatefulWidget {
  const CarsPage({super.key});

  @override
  State<CarsPage> createState() => _CarsPageState();
}

class _CarsPageState extends State<CarsPage> {
  String searchQuery = '';
  final searchController = TextEditingController();
  String? selectedLabel; // Nouvel état pour stocker le label sélectionné.

  @override
  void initState() {
    super.initState();
    searchController.addListener(() {
      setState(() {
        searchQuery = searchController.text;
      });
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.background,
        title: const Text(
          'Lumina',
          style: TextStyle(
            color: Coolors.blueDark,
            fontWeight: FontWeight.bold,
            fontSize: 26,
            fontFamily: 'Playfair Display',
            //fontWeight: FontWeight.bold,
          ),
        ),
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
            child:
                CarPost(searchQuery: searchQuery, selectedLabel: selectedLabel),
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
