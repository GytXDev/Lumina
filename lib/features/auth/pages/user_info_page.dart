// ignore_for_file: void_checks

import 'dart:io';

import 'package:lumina/colors/coloors.dart';
import 'package:lumina/colors/extension/extension_theme.dart';
import 'package:lumina/colors/helper_dialogue.dart';
import 'package:lumina/features/auth/controllers/auth_controller.dart';
import 'package:lumina/features/auth/widgets/custom_button.dart';
import 'package:lumina/features/auth/widgets/custom_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:image_picker/image_picker.dart';
import 'package:lumina/languages/app_translations.dart';

import '../../cars/pages/multiple_images.dart';
import '../widgets/custom_icon_button.dart';
import '../widgets/short_bar.dart';

class UserInfoPage extends ConsumerStatefulWidget {
  const UserInfoPage({super.key, this.profileImageUrl});

  final String? profileImageUrl;

  @override
  ConsumerState<UserInfoPage> createState() => _UserInfoPageState();
}

class _UserInfoPageState extends ConsumerState<UserInfoPage> {
  File? imageCamera;
  List<File> _images = [];
  bool showSelectedImage = false;
  bool showFullContent = false;
  bool isConcessionary = false;

  Widget _truncateText(
      BuildContext context, String text, int maxLength, bool showFullContent) {
    final String showMoreText =
        AppLocalizations.of(context).translate('showMore');

    if (text.length <= maxLength || showFullContent) {
      return Text(
        text,
        textAlign: TextAlign.center,
      );
    }

    final String truncatedText = text.substring(0, maxLength);
    const TextStyle blueTextStyle =
        TextStyle(color: Colors.blue, fontWeight: FontWeight.w500);

    return Row(
      children: [
        Expanded(
          child: Text(truncatedText),
        ),
        GestureDetector(
          onTap: () {
            setState(() {
              showFullContent = !showFullContent;
            });
          },
          child: Padding(
            padding: const EdgeInsets.all(2.0),
            child: Text(
              showMoreText,
              style: blueTextStyle,
            ),
          ),
        ),
      ],
    );
  }

  late TextEditingController usernameController;

  void saveUserDataToFirebase() {
    String username = usernameController.text;

    if (username.isEmpty) {
      return showAlertDialog(
        context: context,
        message:
            AppLocalizations.of(context).translate('pleaseProvideUsername'),
      );
    } else if (username.length < 3 || username.length > 20) {
      return showAlertDialog(
        context: context,
        message: AppLocalizations.of(context).translate('usernameLengthError'),
      );
    }

    // Sauvegarder les données de l'utilisateur dans Firebase
    ref.read(authControllerProvider).saveUserInfoToFirestore(
          username: username,
          profileImage: (imageCamera != null || _images.isNotEmpty)
              ? (_images.isNotEmpty ? _images.first : imageCamera!)
              : (widget.profileImageUrl ?? ''),
          isConcessionary: isConcessionary,
          context: context,
          mounted: mounted,
        );
  }

  imagePickerTypeBottomSheet() {
    return showModalBottomSheet(
      context: context,
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const ShortHBar(),
            Row(
              children: [
                const SizedBox(width: 20),
                Text(
                  AppLocalizations.of(context).translate('profilePhoto'),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                CustomIconButton(
                  onTap: () => Navigator.pop(context),
                  icon: Icons.close,
                ),
                const SizedBox(width: 15),
              ],
            ),
            Divider(
              color: context.theme.greyColor!.withOpacity(.3),
            ),
            const SizedBox(height: 5),
            Row(
              children: [
                const SizedBox(width: 20),
                imagePickerIcon(
                  onTap: pickmageFromCamera,
                  icon: Icons.camera_alt_rounded,
                  text: AppLocalizations.of(context).translate('camera'),
                ),
                const SizedBox(width: 15),
                imagePickerIcon(
                  onTap: pickImagesFromGallery,
                  icon: Icons.photo_camera_back_rounded,
                  text: AppLocalizations.of(context).translate('gallery'),
                ),
              ],
            ),
            const SizedBox(height: 15),
          ],
        );
      },
    );
  }

  pickmageFromCamera() async {
    try {
      Navigator.pop(context);
      final image = await ImagePicker().pickImage(source: ImageSource.camera);
      if (image == null) return;

      setState(() {
        imageCamera = File(image.path);

        showSelectedImage =
            true; // Nouvelle ligne pour montrer l'image sélectionnée.
      });
    } catch (e) {
      // ignore: use_build_context_synchronously
      showAlertDialog(context: context, message: e.toString());
    }
  }

  pickImagesFromGallery() async {
    try {
      Navigator.pop(context);
      final files = await imageHelper.pickImage(multiple: true);
      setState(() {
        _images = files
            .map((e) => File(e?.path ?? ""))
            .where((e) => e.path.isNotEmpty)
            .toList();
      });
    } catch (e) {
      // ignore: avoid_print
      print('Error selecting images: $e');
    }
  }

  imagePickerIcon({
    required VoidCallback onTap,
    required IconData icon,
    required String text,
  }) {
    return Column(
      children: [
        CustomIconButton(
          onTap: onTap,
          icon: icon,
          iconColor: Coolors.greenDark,
          minWidth: 50,
          border: Border.all(
            color: context.theme.greyColor!.withOpacity(.2),
            width: 1,
          ),
        ),
        const SizedBox(
          height: 5,
        ),
        Text(
          text,
          style: TextStyle(
            color: context.theme.greyColor,
          ),
        ),
      ],
    );
  }

  @override
  void initState() {
    usernameController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    usernameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            const SizedBox(
              height: 20,
            ),
            GestureDetector(
              onTap: () {
                setState(() {
                  showFullContent = !showFullContent;
                });
              },
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: _truncateText(
                  context,
                  AppLocalizations.of(context)
                      .translate('provideNameAndProfilePhoto'),
                  49,
                  showFullContent,
                ),
              ),
            ),
            const SizedBox(
              height: 40,
            ),
            GestureDetector(
              onTap: imagePickerTypeBottomSheet,
              child: Container(
                padding: const EdgeInsets.all(26),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: context.theme.photoIconBgColor,
                  border: Border.all(
                    color: imageCamera == null && _images.isEmpty
                        ? Colors.transparent
                        : context.theme.greyColor!.withOpacity(0.4),
                  ),
                  image: (_images.isNotEmpty)
                      ? DecorationImage(
                          fit: BoxFit.cover,
                          image: Image.file(_images.first).image,
                        )
                      : (widget.profileImageUrl != null)
                          ? DecorationImage(
                              fit: BoxFit.cover,
                              image: NetworkImage(widget.profileImageUrl!),
                            )
                          : (imageCamera != null)
                              ? DecorationImage(
                                  fit: BoxFit.cover,
                                  image: Image.file(imageCamera!).image,
                                )
                              : null,
                ),
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 3, right: 1),
                  child: Icon(
                    Icons.add_a_photo_rounded,
                    size: 48,
                    color: imageCamera == null &&
                            _images.isEmpty &&
                            widget.profileImageUrl == null
                        ? context.theme.photoIconColor
                        : Colors.transparent,
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 40,
            ),
            Row(
              children: [
                const SizedBox(
                  width: 20,
                ),
                Expanded(
                  child: CustomTextField(
                    controller: usernameController,
                    hinText: AppLocalizations.of(context)
                        .translate('typeYourNameHere'),
                    textAlign: TextAlign.center,
                    autoFocus: true,
                    hintText: '',
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                const SizedBox(
                  width: 20,
                ),
                const SizedBox(
                  height: 80,
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  Text(
                    'Êtes-vous un concessionnaire ?',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[800],
                    ),
                  ),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            isConcessionary = false;
                          });
                        },
                        child: Container(
                          padding:
                              EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                          decoration: BoxDecoration(
                            color: !isConcessionary
                                ? Coolors.blueDark
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.person,
                                color: !isConcessionary
                                    ? Colors.white
                                    : Coolors.greyDark,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Particulier',
                                style: TextStyle(
                                  color: !isConcessionary
                                      ? Colors.white
                                      : Coolors.greyDark,
                                  fontWeight: !isConcessionary
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            isConcessionary = true;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 8, horizontal: 16),
                          decoration: BoxDecoration(
                            color: isConcessionary
                                ? Coolors.blueDark
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.store,
                                color: isConcessionary
                                    ? Colors.white
                                    : Coolors.greyDark,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Concessionnaire',
                                style: TextStyle(
                                  color: isConcessionary
                                      ? Colors.white
                                      : Coolors.greyDark,
                                  fontWeight: isConcessionary
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: CustomElevatedButton(
        onPressed: saveUserDataToFirebase,
        text: AppLocalizations.of(context).translate('next'),
        buttonWidth: 120,
        backgroundColor: Coolors.blueDark,
      ),
    );
  }
}
