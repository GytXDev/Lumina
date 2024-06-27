// ignore_for_file: avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lumina/colors/coloors.dart';
import 'package:lumina/colors/helpers/show_loading_dialog.dart';
import 'package:lumina/features/auth/widgets/custom_button.dart';
import 'package:lumina/features/cars/pages/image_helper.dart';
import 'package:lumina/languages/app_translations.dart';
import 'package:lumina/models/cars_model.dart';

class CarEditPage extends StatefulWidget {
  final String carId;
  final String carName;
  final String brand;
  final CarType yearOrNew;
  final String? duration; // Déclarez-le comme un String facultatif
  final List<String> imageUrls;
  final String description;
  final double price;
  final String userId;

  const CarEditPage({
    super.key, // Ajoutez la clé facultative
    required this.carId,
    required this.carName,
    required this.brand,
    required this.yearOrNew,
    this.duration, // Rendre le String facultatif
    required this.imageUrls,
    required this.description,
    required this.price,
    required this.userId,
  }); // Assurez-vous de passer la clé à la super-classe

  @override
  State<CarEditPage> createState() => _CarEditPageState();
}

class _CarEditPageState extends State<CarEditPage> {
  final ImageHelper _imageHelper = ImageHelper();

  String carName = '';
  String duration = '';
  String brand = '';
  CarType condition = CarType.news;
  List<String> selectedImages = [];
  String description = '';
  double price = 0.0;

  Future<void> _updateCar() async {
    try {
      showLoadingDialog(
        context: context,
        message: AppLocalizations.of(context).translate('savingPostMessage'),
        barrierDismissible: false,
      );

      Map<String, dynamic> updatedData = {};

      if (carName != widget.carName) updatedData['carName'] = carName;
      if (brand != widget.brand) updatedData['brand'] = brand;
      if (condition != widget.yearOrNew) updatedData['yearOrNew'] = condition;
      if (duration != widget.duration) updatedData['duration'] = duration;
      if (selectedImages.isNotEmpty && selectedImages != widget.imageUrls) {
        updatedData['imageUrls'] = selectedImages;
      }
      if (description != widget.description) {
        updatedData['description'] = description;
      }
      if (price != widget.price) updatedData['price'] = price;

      if (updatedData.isNotEmpty) {
        try {
          await FirebaseFirestore.instance
              .collection('cars')
              .doc(widget.carId)
              .update(updatedData);

          print('Information mis à jour');
        } catch (e) {
          print('Erreur lors de la mise à jour : $e');
        }

        print("Voiture mise à jour avec succès!");
      } else {
        print("Aucune modification détectée");
      }
    } catch (error) {
      print("Erreur lors de la mise à jour de la voiture : $error");
    } finally {
      // ignore: use_build_context_synchronously
      Navigator.pop(context); // Ferme le dialogue de chargement
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
              initialValue: widget.carName,
              onChanged: (value) {
                setState(() {
                  carName = value;
                });
              },
            ),
            const SizedBox(height: 16.0),
            _buildTextFormField(
              label: AppLocalizations.of(context).translate('brandLabel'),
              initialValue: widget.brand,
              onChanged: (value) {
                setState(() {
                  brand = value;
                });
              },
            ),
            _buildCarTypeDropdown(),
            if (widget.yearOrNew == CarType.old)
              _buildTextFormField(
                label: AppLocalizations.of(context).translate('labelTextOld'),
                initialValue: widget.duration ?? '',
                onChanged: (value) {
                  setState(() {
                    duration = value;
                  });
                },
              ),
            const SizedBox(height: 16.0),
            _buildMultipleImages(),
            const SizedBox(height: 16.0),
            _buildTextFormField(
              label: AppLocalizations.of(context).translate('descriptionLabel'),
              initialValue: widget.description,
              onChanged: (value) {
                setState(() {
                  description = value;
                });
              },
            ),
            _buildTextFormField(
              label: AppLocalizations.of(context).translate('priceLabel'),
              initialValue: widget.price.toString(),
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
      value: widget.yearOrNew,
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
          condition = value!;
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
          children: (widget.imageUrls).asMap().entries.map(
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
                          widget.imageUrls.removeAt(index);
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
        (widget.imageUrls.isEmpty)
            ? ElevatedButton(
                onPressed: () async {
                  List<XFile?> newImages =
                      await _imageHelper.pickImage(multiple: true);
                  if (newImages.isNotEmpty) {
                    setState(() {
                      widget.imageUrls.addAll(
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
                      widget.imageUrls.addAll(
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
