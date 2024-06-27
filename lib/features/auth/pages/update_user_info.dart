// ignore_for_file: void_checks

import 'package:lumina/colors/helper_dialogue.dart';
import 'package:lumina/features/auth/widgets/custom_button.dart';
import 'package:lumina/features/auth/widgets/custom_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:lumina/languages/app_translations.dart';


class UpdateUserInfo extends ConsumerStatefulWidget {
  const UpdateUserInfo({super.key, this.profileImageUrl, this.username});

  final String? profileImageUrl;
  final String? username;

  @override
  ConsumerState<UpdateUserInfo> createState() => _UpdateUserInfoState();
}

class _UpdateUserInfoState extends ConsumerState<UpdateUserInfo> {
  bool showSelectedImage = false;
  bool isConcessionary = false;

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
