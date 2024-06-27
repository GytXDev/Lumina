import 'dart:io';

import 'package:flutter/material.dart';
import 'package:lumina/colors/coloors.dart';
import 'package:lumina/features/cars/pages/image_helper.dart';
import 'package:lumina/languages/app_translations.dart';

class MultipleImages extends StatefulWidget {
  const MultipleImages({super.key, required this.onImagesSelected});
  final void Function(List<File>) onImagesSelected;

  @override
  State<MultipleImages> createState() => _MultipleImagesState();
}

final ImageHelper imageHelper = ImageHelper();

class _MultipleImagesState extends State<MultipleImages> {
  final List<File> _images = [];
  List<String> selectedImages = [];

  void _addImages(List<File> newImages) {
    final imageFiles = newImages.where((file) => isImageFile(file)).toList();

    setState(() {
      _images.addAll(imageFiles);
      selectedImages = _images.map((e) => e.path).toList();
    });
    widget.onImagesSelected(_images);
  }

  bool isImageFile(File file) {
    // Une simple vérification basée sur l'extension du fichier
    return ['jpg', 'jpeg', 'png', 'gif'].any(file.path.endsWith);
  }

  void _removeImage(int index) {
    setState(() {
      _images.removeAt(index);
      selectedImages = _images.map((e) => e.path).toList();
    });
    widget.onImagesSelected(_images);
  }

  void _selectMultiplePhotos() async {
    try {
      final files = await imageHelper.pickImage(multiple: true);
      if (files.isNotEmpty) {
        _addImages(files
            .map((e) => File(e?.path ?? ""))
            .where((e) => e.path.isNotEmpty)
            .toList());
      }
    } catch (e) {
      // ignore: avoid_print
      print('Error selecting images: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (_images.isNotEmpty)
          SizedBox(
            height: 120, // Hauteur fixe pour le conteneur des images
            child: SingleChildScrollView(
              scrollDirection:
                  Axis.horizontal, // Permet de défiler horizontalement
              child: Wrap(
                spacing: 4,
                runSpacing: 4,
                children: _images.asMap().entries.map(
                  (entry) {
                    final index = entry.key;
                    final image = entry.value;
                    return Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: Image.file(
                            image,
                            height: 100,
                            width: 100,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          top: 4,
                          right: 4,
                          child: GestureDetector(
                            onTap: () => _removeImage(index),
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
            ),
          ),
        const SizedBox(height: 5),
        // Bouton pour sélectionner des images quand aucune image n'est présente
        if (_images.isEmpty)
          ElevatedButton(
            onPressed: _selectMultiplePhotos,
            style: ElevatedButton.styleFrom(
              backgroundColor: Coolors.blueDark, // Couleur de fond du bouton
            ),
            child: Text(
              AppLocalizations.of(context).translate('selectMultiplePictures'),
            ),
          ),

        // Bouton pour ajouter des images lorsque la liste n'est pas vide
        if (_images.isNotEmpty)
          GestureDetector(
            onTap: _selectMultiplePhotos,
            child: Container(
              height: 48, // Hauteur fixe pour le bouton d'ajout
              width: 48, // Largeur fixe pour le bouton d'ajout
              decoration: const BoxDecoration(
                color: Coolors.greyDark, // Utilisez votre couleur
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.add,
                color: Colors.black,
                size: 24,
              ),
            ),
          ),
      ],
    );
  }
}
