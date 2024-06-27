// ignore_for_file: void_checks, prefer_final_fields

import 'dart:io';

import 'package:lumina/colors/coloors.dart';
import 'package:lumina/colors/extension/extension_theme.dart';
import 'package:lumina/colors/helper_dialogue.dart';
import 'package:lumina/features/auth/controllers/auth_controller.dart';
import 'package:lumina/features/auth/widgets/custom_button.dart';
import 'package:lumina/features/auth/widgets/custom_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:lumina/languages/app_translations.dart';

import '../widgets/custom_icon_button.dart';

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
            const SizedBox(
              height: 40,
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
                    AppLocalizations.of(context).translate('profilDescription'),
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 10),
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
                          padding: const EdgeInsets.symmetric(
                              vertical: 8, horizontal: 16),
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
                              const SizedBox(width: 8),
                              Text(
                                AppLocalizations.of(context)
                                    .translate('particular'),
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
                                AppLocalizations.of(context)
                                    .translate('concessionary'),
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
