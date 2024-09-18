import 'package:country_picker/country_picker.dart';
import 'package:lumina/colors/extension/extension_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lumina/languages/app_translations.dart';

import '../../../../colors/coloors.dart';
import '../../../../colors/helper_dialogue.dart';
import '../controllers/auth_controller.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_field.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  late TextEditingController countryNameController;
  late TextEditingController countryCodeController;
  late TextEditingController phoneNumberController;

  sendCodeToPhone() {
    final phoneNumber = phoneNumberController.text;
    final countryName = countryNameController.text;
    final countryCode = countryCodeController.text;

    if (phoneNumber.isEmpty) {
      return showAlertDialog(
        context: context,
        message: AppLocalizations.of(context).translate('enterPhoneNumber'),
      );
    } else if (phoneNumber.length < 9) {
      return showAlertDialog(
        context: context,
        message: AppLocalizations.of(context).translateWithVariables(
            'phoneNumberTooShort', {"countryName": countryName}),
      );
    } else if (phoneNumber.length > 10) {
      return showAlertDialog(
        context: context,
        message: AppLocalizations.of(context).translateWithVariables(
          "phone_number_too_long",
          {"countryName": countryName},
        ),
      );
    }

    // request a verification code
    ref.read(authControllerProvider).sendSmsCode(
          context: context,
          phoneNumber: '+$countryCode$phoneNumber',
        );
  }

  showCoutryCodePicker() {
    showCountryPicker(
      context: context,
      showPhoneCode: true,
      favorite: ['GA'],
      countryListTheme: CountryListThemeData(
        bottomSheetHeight: 600,
        // ignore: deprecated_member_use
        backgroundColor: Theme.of(context).colorScheme.background,
        flagSize: 22,
        borderRadius: BorderRadius.circular(20),
        textStyle: TextStyle(
          color: context.theme.greyColor,
        ),
        inputDecoration: InputDecoration(
          labelStyle: TextStyle(
            color: context.theme.greyColor,
          ),
          prefixIcon: const Icon(
            Icons.language,
            color: Coolors.blueDark,
          ),
          hintText:
              AppLocalizations.of(context).translate('searchCountryCodeOrName'),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(
              color: context.theme.greyColor!.withOpacity(0.2),
            ),
          ),
          focusedBorder: const UnderlineInputBorder(
            borderSide: BorderSide(
              color: Coolors.blueDark,
            ),
          ),
        ),
      ),
      onSelect: (country) {
        countryNameController.text = country.name;
        countryCodeController.text = country.phoneCode;
      },
    );
  }

  @override
  void initState() {
    countryNameController = TextEditingController(text: 'Gabon');
    countryCodeController = TextEditingController(text: '241');
    phoneNumberController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    countryCodeController.dispose();
    countryNameController.dispose();
    phoneNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        title: Text(
          AppLocalizations.of(context).translate('enterPhoneNumber'),
          style: const TextStyle(
            color: Coolors.greyDark,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 10,
            ),
            child: RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                text: AppLocalizations.of(context).translate('verificationSMS'),
                style: TextStyle(
                  color: context.theme.greyColor,
                  height: 1.5,
                ),
                /*children: [
                  TextSpan(
                    text:
                        AppLocalizations.of(context).translate('whatsMyNumber'),
                    style: TextStyle(
                      color: context.theme.blueColor,
                    ),
                  ),
                ],*/
              ),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 50,
            ),
            child: CustomTextField(
              onTap: showCoutryCodePicker,
              controller: countryNameController,
              readOnly: true,
              suffixIcon: Icon(
                Icons.arrow_drop_down,
                color: context.theme.blackText,
              ),
              hintText: '',
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 50,
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 70,
                  child: CustomTextField(
                    onTap: showCoutryCodePicker,
                    controller: countryCodeController,
                    prefixText: '+',
                    readOnly: true,
                    hintText: '',
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                Expanded(
                  child: CustomTextField(
                    controller: phoneNumberController,
                    hinText:
                        AppLocalizations.of(context).translate('phoneNumber'),
                    textAlign: TextAlign.left,
                    keyboardType: TextInputType.number,
                    hintText: '',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          Text(
            AppLocalizations.of(context).translate('carrierChargesApply'),
            style: TextStyle(
              color: context.theme.greyColor,
            ),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: CustomElevatedButton(
        onPressed: sendCodeToPhone,
        text: AppLocalizations.of(context).translate('next'),
        buttonWidth: 120,
        backgroundColor: Coolors.blueDark,
      ),
    );
  }
}
