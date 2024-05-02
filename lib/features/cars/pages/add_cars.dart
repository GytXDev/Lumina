// ignore_for_file: constant_identifier_names, avoid_print

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:lumina/colors/coloors.dart';
import 'package:lumina/colors/extension/extension_theme.dart';
import 'package:lumina/colors/helpers/show_loading_dialog.dart';
import 'package:lumina/features/auth/repository/firebase_storage_repository.dart';
import 'package:lumina/features/auth/widgets/custom_button.dart';
import 'package:lumina/features/cars/repository/cars_repository.dart';
import 'package:flutter/material.dart';
import 'package:lumina/home_section/services/currency.dart';
import 'package:lumina/languages/app_translations.dart';

import '../../../models/cars_model.dart';
import '../../../models/user_models.dart';
import 'multiple_images.dart';

class Range {
  final double start;
  final double end;

  Range(this.start, this.end);

  bool contains(double value) => value >= start && value <= end;
}

class AddCarsPage extends StatefulWidget {
  const AddCarsPage({super.key});

  @override
  State<AddCarsPage> createState() => _AddCarsPageState();
}

class _AddCarsPageState extends State<AddCarsPage> {
  final _carsRepository = CarsRepository();
  late final UserModel user;

  //Fonction pour valider les champs
  String? validateInputs() {
    if (carName.isEmpty) {
      return AppLocalizations.of(context).translate('carNameRequired');
    } else if (brand.isEmpty) {
      return AppLocalizations.of(context).translate('brandRequired');
    } else if (_images.length < 2) {
      // Vérification pour au moins 2 images
      return AppLocalizations.of(context).translate('atLeastTwoImages');
    } else if (description.isEmpty) {
      return AppLocalizations.of(context).translate('descriptionRequired');
    } else if (condition == CarType.old && duration.isEmpty) {
      return AppLocalizations.of(context).translate('durationRequired');
    } else if (price <= 0.0) {
      return AppLocalizations.of(context).translate('validPriceRequired');
    }

    return null;
  }

  String carName = '';
  String duration = '';
  String brand = '';
  CarType condition = CarType.news;
  List<String> selectedImages = [];
  String description = '';
  double price = 0.0;
  List<File> _images = [];

  @override
  void initState() {
    super.initState();
    _getCurrentUser();
  }

  Future<void> _getCurrentUser() async {
    try {
      UserModel currentUser = await _carsRepository.getCurrentUser();
      setState(() {
        user = currentUser;
      });
    } catch (e) {
      print('Erreur lors de la récupération de l\'utilisateur : $e');
    }
  }

  Currency determineCurrency(double latitude, double longitude) {
    // Régions pour les devises existantes
    final euroLatRange = Range(35.0, 72.0);
    final euroLongRange = Range(-32.0, 42.0);

    final usdLatRange = Range(24.396308, 49.384358);
    final usdLongRange = Range(-125.000000, -66.934570);

    final cfaLatRange = Range(-37.0, 15.0);
    final cfaLongRange = Range(-20.0, 56.0);

    final randLatRange = Range(-35.0, -22.0);
    final randLongRange = Range(16.0, 33.0);

    final nairaLatRange = Range(4.0, 14.0);
    final nairaLongRange = Range(3.0, 15.0);

    final dirhamLatRange = Range(21.0, 35.0);
    final dirhamLongRange = Range(-18.0, -5.0);

    final shillingLatRange = Range(-11.0, 6.0);
    final shillingLongRange = Range(33.0, 47.0);

    final kwachaLatRange = Range(-18.0, -8.0);
    final kwachaLongRange = Range(24.0, 36.0);

    final birrLatRange = Range(3.0, 15.0);
    final birrLongRange = Range(33.0, 48.0);

    final dinarLatRange = Range(20.0, 37.0);
    final dinarLongRange = Range(-13.0, 12.0);

    // Vérifications pour les différentes devises
    if (euroLatRange.contains(latitude) && euroLongRange.contains(longitude)) {
      return Currency.Euro; // Europe
    } else if (usdLatRange.contains(latitude) &&
        usdLongRange.contains(longitude)) {
      return Currency.USD; // États-Unis
    } else if (cfaLatRange.contains(latitude) &&
        cfaLongRange.contains(longitude)) {
      return Currency.XAF; // Afrique de l'Ouest et Centrale
    } else if (randLatRange.contains(latitude) &&
        randLongRange.contains(longitude)) {
      return Currency.Rand; // Afrique du Sud
    } else if (nairaLatRange.contains(latitude) &&
        nairaLongRange.contains(longitude)) {
      return Currency.Naira; // Nigeria
    } else if (dirhamLatRange.contains(latitude) &&
        dirhamLongRange.contains(longitude)) {
      return Currency.Dirham; // Maroc
    } else if (shillingLatRange.contains(latitude) &&
        shillingLongRange.contains(longitude)) {
      return Currency.Shilling; // Kenya, Ouganda
    } else if (kwachaLatRange.contains(latitude) &&
        kwachaLongRange.contains(longitude)) {
      return Currency.Kwacha; // Zambie, Malawi
    } else if (birrLatRange.contains(latitude) &&
        birrLongRange.contains(longitude)) {
      return Currency.Birr; // Éthiopie
    } else if (dinarLatRange.contains(latitude) &&
        dinarLongRange.contains(longitude)) {
      return Currency.Dinar; // Algérie, Tunisie
    } else {
      return Currency.USD; // Par défaut, retourne USD
    }
  }

  void saveCarToCollection() async {
    final carId = FirebaseFirestore.instance.collection('cars').doc().id;

    List<String> imageUrls = [];

    // Valider les champs avant de procéder
    String? validationError = validateInputs();

    if (validationError != null) {
      // Afficher un message d'erreur avec le nom du champ vide
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          validationError,
          style: TextStyle(color: context.theme.textAppBar),
        ),
      ));
      return; // Arrêter le processus d'enregistrement
    }
    // Déterminez la devise
    Currency currency = determineCurrency(user.latitude, user.longitude);

    // Utilisez la devise comme nécessaire, par exemple :
    print('Devise détectée pour la voiture : $currency');

    try {
      showLoadingDialog(
        context: context,
        message: AppLocalizations.of(context).translate('savingPostMessage'),
        barrierDismissible: false,
      );
      for (File imageFile in _images) {
        String extension = imageFile.path.split('.').last;
        String imageName =
            'car_images/$carId/${DateTime.now().millisecondsSinceEpoch}.$extension';

        // Utilisez la méthode de votre FirebaseStorageRepository pour stocker l'image
        String imageUrl = await FirebaseStorageRepository(
                firebaseStorage: FirebaseStorage.instance)
            .storeFileToFirebase(imageName, imageFile);

        // Ajoutez l'URL uniquement si l'enregistrement dans Firebase Storage a réussi
        imageUrls.add(imageUrl);
      }

      final carModel = CarsModel(
        carId: carId,
        carName: carName,
        brand: brand,
        yearOrNew: condition,
        duration: condition == CarType.old ? duration : null,
        imageUrls: imageUrls,
        description: description,
        price: price,
        userId: user.uid,
        totalLike: 0,
        username: user.username,
        userImage: user.profileImageUrl,
        latitude: user.latitude,
        longitude: user.longitude,
        currency: currency.toString().split('.')[1],
      );

      await _carsRepository.saveCarToCollection(carModel);

      // Fermer la boîte de dialogue de chargement
      // ignore: use_build_context_synchronously
      Navigator.pop(context);

      // Fermer la page après l'enregistrement
      setState(() {
        Navigator.pop(context);
      });
    } catch (e) {
      print('Erreur lors de l\'enregistrement de la voiture : $e');
      // Ajoutez une logique de gestion d'erreur ici si nécessaire.
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context).translate('newPost'),
          style: const TextStyle(
            fontSize: 20.0,
            //fontFamily: 'Playfair Display',
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text(
              AppLocalizations.of(context).translate('cancel'),
              style: const TextStyle(color: Coolors.greyDark),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              decoration: InputDecoration(
                labelText:
                    AppLocalizations.of(context).translate('carNameLabel'),
                fillColor: Coolors.greyDark,
              ),
              onChanged: (value) {
                setState(() {
                  carName = value;
                });
              },
            ),
            const SizedBox(height: 16.0),
            TextFormField(
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context).translate('brandLabel'),
                fillColor: Coolors.greyDark,
              ),
              onChanged: (value) {
                setState(() {
                  brand = value;
                });
              },
            ),
            DropdownButtonFormField<CarType>(
              value: condition,
              items: CarType.values.map((condition) {
                return DropdownMenuItem(
                  value: condition,
                  child: Text(
                    condition == CarType.news
                        ? AppLocalizations.of(context).translate('newCar')
                        : AppLocalizations.of(context).translate('occasion'),
                    style: const TextStyle(color: Coolors.greyDark),
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  condition = value!;
                });
              },
            ),
            // Ajoutez le champ de durée ici
            if (condition == CarType.old)
              TextFormField(
                decoration: InputDecoration(
                  labelText:
                      AppLocalizations.of(context).translate('labelTextOld'),
                  fillColor: Coolors.greyDark,
                ),
                onChanged: (value) {
                  setState(() {
                    duration = value;
                  });
                },
              ),
            const SizedBox(height: 16.0),

            const SizedBox(height: 8.0),

            MultipleImages(onImagesSelected: (images) {
              setState(() {
                _images = images;
              });
            }),

            const SizedBox(height: 16.0),
            TextFormField(
              decoration: InputDecoration(
                labelText:
                    AppLocalizations.of(context).translate('descriptionLabel'),
                labelStyle: const TextStyle(
                  fontSize: 16.0,
                ),
                fillColor: Coolors
                    .greyDark, // Assurez-vous que `Coolors.greyDark` est la bonne couleur.
                border: OutlineInputBorder(
                  // Ajoute une bordure autour du champ de texte
                  borderRadius: BorderRadius.circular(5.0),
                ),
              ),
              keyboardType: TextInputType
                  .multiline, // Active le clavier pour le texte multiligne
              maxLines:
                  null, // Permet au champ de texte de s'agrandir verticalement
              minLines:
                  2, // Définit un nombre minimum de lignes pour le champ de texte
              onChanged: (value) {
                setState(() {
                  description = value;
                });
              },
            ),
            const SizedBox(height: 6.0),
            TextFormField(
              decoration: InputDecoration(
                labelText:
                    '${AppLocalizations.of(context).translate('priceLabel')} (${determineCurrency(user.latitude, user.longitude).toString().split('.').last})',
                fillColor: Coolors
                    .greyDark, // Assurez-vous que `Coolors.greyDark` est défini correctement.
                suffixText:
                    ' ${determineCurrency(user.latitude, user.longitude).toString().split('.').last}',
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                setState(() {
                  price = double.tryParse(value) ?? 0.0;
                });
              },
            ),

            Padding(
              padding: const EdgeInsets.symmetric(vertical: 18.0),
              child: Center(
                child: CustomElevatedButton(
                  onPressed: saveCarToCollection,
                  text: AppLocalizations.of(context).translate('next'),
                  buttonWidth: 110,
                  backgroundColor: Coolors.blueDark,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
