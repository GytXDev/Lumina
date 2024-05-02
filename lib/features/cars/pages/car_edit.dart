// ignore_for_file: avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lumina/colors/coloors.dart';
import 'package:lumina/colors/helpers/show_loading_dialog.dart';
import 'package:lumina/features/auth/widgets/custom_button.dart';
import 'package:lumina/features/cars/pages/image_helper.dart';
import 'package:lumina/features/cars/repository/cars_repository.dart';
import 'package:lumina/languages/app_translations.dart';
import 'package:lumina/models/cars_model.dart';

class CarEditPage extends StatefulWidget {
  final String carId;

  const CarEditPage({
    super.key,
    required this.carId,
  });

  @override
  State<CarEditPage> createState() => _CarEditPageState();
}

class _CarEditPageState extends State<CarEditPage> {
  final CarsRepository _carsRepository = CarsRepository();
  final ImageHelper _imageHelper = ImageHelper();
  CarsModel? _carDetails;

  @override
  void initState() {
    super.initState();
    _loadCarDetails();
  }

  Future<CarsModel?> getCarDetails(String carId) async {
    try {
      DocumentSnapshot carSnapshot =
          await FirebaseFirestore.instance.collection('cars').doc(carId).get();

      if (carSnapshot.exists) {
        CarsModel carModel = CarsModel.fromMap(
            carSnapshot.data() as Map<String, dynamic>, carId);
        return carModel;
      } else {
        return null;
      }
    } catch (error) {
      print("Erreur lors de la récupération du véhicule : $error");
      return null;
    }
  }

  Future<void> _loadCarDetails() async {
    try {
      CarsModel? carDetails = await getCarDetails(widget.carId);

      setState(() {
        _carDetails = carDetails;
      });

      // Ajoutez des prints pour chaque information ici
      print("Car Name: ${_carDetails?.carName}");
      print("Brand: ${_carDetails?.brand}");
      print("Year or New: ${_carDetails?.yearOrNew}");
      print("Duration: ${_carDetails?.duration}");
      print("Description: ${_carDetails?.description}");
      print("Price: ${_carDetails?.price}");
    } catch (error) {
      print("Erreur lors de la récupération du véhicule : $error");
      // Gérer l'erreur ici, par exemple afficher un message à l'utilisateur
    }
  }

  Future<void> _updateCar() async {
    try {
      showLoadingDialog(
        context: context,
        message: AppLocalizations.of(context).translate('savingPostMessage'),
        barrierDismissible: false,
      );
      CarsModel updatedCar = CarsModel(
        carId: widget.carId,
        carName: _carDetails!.carName,
        brand: _carDetails!.brand,
        yearOrNew: _carDetails!.yearOrNew,
        duration: _carDetails!.duration ?? '',
        imageUrls: _carDetails!.imageUrls,
        description: _carDetails!.description,
        price: _carDetails!.price,
        userId: _carDetails!.userId,
        username: _carDetails!.username,
        userImage: _carDetails!.userImage,
        totalLike: _carDetails!.totalLike,
      );

      await _carsRepository.updateCar(widget.carId, updatedCar.toMap());
      print("Voiture mise à jour avec succès!");
    } catch (error) {
      print("Erreur lors de la mise à jour de la voiture : $error");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context).translate('editTitle'),
          style: const TextStyle(
            fontSize: 20.0,
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
            _buildTextFormField(
              label: AppLocalizations.of(context).translate('carNameLabel'),
              initialValue: "${_carDetails?.carName}",
              onChanged: (value) {
                setState(() {
                  _carDetails?.carName = value;
                });
              },
            ),
            const SizedBox(height: 16.0),
            _buildTextFormField(
              label: AppLocalizations.of(context).translate('brandLabel'),
              initialValue: _carDetails?.brand ?? '',
              onChanged: (value) {
                setState(() {
                  _carDetails?.brand = value;
                });
              },
            ),
            _buildCarTypeDropdown(),
            if (_carDetails?.yearOrNew == CarType.old)
              _buildTextFormField(
                label: AppLocalizations.of(context).translate('labelTextOld'),
                initialValue: _carDetails?.duration ?? '',
                onChanged: (value) {
                  setState(() {
                    _carDetails?.duration = value;
                  });
                },
              ),
            const SizedBox(height: 16.0),
            _buildMultipleImages(),
            const SizedBox(height: 16.0),
            _buildTextFormField(
              label: AppLocalizations.of(context).translate('descriptionLabel'),
              initialValue: _carDetails?.description ?? '',
              onChanged: (value) {
                setState(() {
                  _carDetails?.description = value;
                });
              },
            ),
            _buildTextFormField(
              label: AppLocalizations.of(context).translate('priceLabel'),
              initialValue: _carDetails?.price.toString() ?? '',
              keyboardType: TextInputType.number,
              onChanged: (value) {
                setState(() {
                  _carDetails?.price = double.tryParse(value) ?? 0.0;
                });
              },
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 18.0),
              child: Center(
                child: CustomElevatedButton(
                  onPressed: _updateCar,
                  text: AppLocalizations.of(context).translate('next'),
                  buttonWidth: 110,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextFormField({
    required String label,
    required String initialValue,
    TextInputType? keyboardType,
    required Function(String) onChanged,
  }) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: label,
        fillColor: Coolors.greyDark,
      ),
      initialValue: initialValue,
      keyboardType: keyboardType,
      onChanged: onChanged,
    );
  }

  Widget _buildCarTypeDropdown() {
    return DropdownButtonFormField<CarType>(
      value: _carDetails?.yearOrNew,
      items: CarType.values.map((condition) {
        return DropdownMenuItem(
          value: condition,
          child: Text(
            condition == CarType.news
                ? AppLocalizations.of(context).translate('newCar')
                : AppLocalizations.of(context).translate('occasionCar'),
            style: const TextStyle(color: Coolors.greyDark),
          ),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _carDetails?.yearOrNew = value!;
        });
      },
    );
  }

  Widget _buildMultipleImages() {
    return Column(
      children: [
        Wrap(
          spacing: 4,
          runSpacing: 4,
          children: (_carDetails?.imageUrls ?? []).asMap().entries.map(
            (entry) {
              final index = entry.key;
              final imageUrl = entry.value;
              return Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: Image.network(
                      imageUrl,
                      height: 100,
                      width: 100,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    top: 4,
                    right: 4,
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _carDetails?.imageUrls.removeAt(index);
                        });
                      },
                      child: const CircleAvatar(
                        backgroundColor: Colors.red,
                        radius: 12,
                        child: Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ).toList(),
        ),
        const SizedBox(
          height: 5,
        ),
        (_carDetails?.imageUrls.isEmpty ?? true)
            ? ElevatedButton(
                onPressed: () async {
                  List<XFile?> newImages =
                      await _imageHelper.pickImage(multiple: true);
                  if (newImages.isNotEmpty) {
                    setState(() {
                      _carDetails?.imageUrls.addAll(
                          newImages.map((image) => image!.path).toList());
                    });
                  }
                },
                child: Text(AppLocalizations.of(context)
                    .translate('selectMultiplePictures')),
              )
            : GestureDetector(
                onTap: () async {
                  List<XFile?> newImages =
                      await _imageHelper.pickImage(multiple: true);
                  if (newImages.isNotEmpty) {
                    setState(() {
                      _carDetails?.imageUrls.addAll(
                          newImages.map((image) => image!.path).toList());
                    });
                  }
                },
                child: const Center(
                  child: Positioned(
                    child: CircleAvatar(
                      backgroundColor: Coolors.greyDark,
                      radius: 24,
                      child: Icon(
                        Icons.add,
                        color: Colors.black,
                        size: 16,
                      ),
                    ),
                  ),
                ),
              ),
      ],
    );
  }
}
