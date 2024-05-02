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
import 'package:lumina/features/cars/pages/multiple_images.dart';
import 'package:lumina/languages/app_translations.dart';

import '../widgets/custom_icon_button.dart';
import '../widgets/short_bar.dart';

class UpdateUserInfo extends ConsumerStatefulWidget {
  const UpdateUserInfo({super.key, this.profileImageUrl, this.username});

  final String? profileImageUrl;
  final String? username;

  @override
  ConsumerState<UpdateUserInfo> createState() => _UpdateUserInfoState();
}

class _UpdateUserInfoState extends ConsumerState<UpdateUserInfo> {
  File? imageCamera;
  List<File> _images = [];
  bool showSelectedImage = false;

  late TextEditingController usernameController;

  saveUserDataToFirebase() {
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

    ref.read(authControllerProvider).saveUserInfoToFirestore(
          username: username,
          profileImage: (imageCamera != null || _images.isNotEmpty)
              ? (_images.isNotEmpty ? _images.first : imageCamera!)
              : (widget.profileImageUrl ?? ''),
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
          iconColor: Coolors.blueDark,
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
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Text(
                AppLocalizations.of(context)
                    .translate('provideNameAndProfilePhoto'),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: context.theme.greyColor,
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
              ],
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: CustomElevatedButton(
        onPressed: saveUserDataToFirebase,
        text: AppLocalizations.of(context).translate('next'),
        buttonWidth: 120,
      ),
    );
  }
}
