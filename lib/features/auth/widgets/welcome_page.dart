// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:lumina/colors/coloors.dart';
import 'package:lumina/features/auth/widgets/custom_button.dart';
import 'package:lumina/features/auth/widgets/languague.dart';
import 'package:lumina/features/auth/widgets/privacy_and_terms.dart';
import 'package:lumina/languages/app_translations.dart';
import 'package:lumina/routes/routes_pages.dart';
import 'package:url_launcher/url_launcher.dart';

class WelcomePage extends StatefulWidget {
  // ignore: use_key_in_widget_constructors
  const WelcomePage({Key? key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  void navigateToLoginPage(BuildContext context) {
    if (!_policyAccepted || !_termsAccepted) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title:
                Text(AppLocalizations.of(context).translate('confirmAccept')),
            content: Text(
                AppLocalizations.of(context).translate('confirmAcceptContent')),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    } else {
      // Si les conditions sont acceptées, naviguer vers la page de connexion
      Navigator.of(context).pushNamedAndRemoveUntil(
        Routes.login,
        (route) => false,
      );
    }
  }

  bool _policyAccepted = false;
  bool _termsAccepted = false;

  void _launchURL(BuildContext context, String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Impossible d\'ouvrir le lien'),
        ),
      );
    }
  }

  void _onPolicyAccepted(bool? value) {
    setState(() {
      _policyAccepted = value ?? false;
      Navigator.of(context).pop();
    });
  }

  void _onTermsAccepted(bool? value) {
    setState(() {
      _termsAccepted = value ?? false;
      Navigator.of(context).pop();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const SizedBox(
            height: 220,
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Text(
                    AppLocalizations.of(context).translate('welcomeMessage'),
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Playfair Display',
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Text(
                    AppLocalizations.of(context).translate('slogan'),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 14.0,
                      fontFamily: 'Playfair Display',
                    ),
                  ),
                  PrivacyAndTerms(
                    policyAccepted: _policyAccepted,
                    termsAccepted: _termsAccepted,
                    onPolicyAccepted: _onPolicyAccepted,
                    onTermsAccepted: _onTermsAccepted,
                  ),
                  TextButton(
                    onPressed: () => _launchURL(
                      context,
                      'https://lumina-auto-privacy-policy.centicresento.com/',
                    ),
                    child: Text(
                      AppLocalizations.of(context)
                          .translate('privacyPolicyLink'),
                      style: const TextStyle(
                        fontSize: 14.0,
                        color: Colors.blue, // Couleur du lien
                        decoration: TextDecoration.underline,
                        decorationThickness:
                            1, // Ajuste l'épaisseur du soulignement
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  CustomElevatedButton(
                    onPressed: () => navigateToLoginPage(context),
                    text: AppLocalizations.of(context)
                        .translate('agreeAndContinue'),
                    backgroundColor: Coolors.blueDark,
                    textColor: Colors.white,
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  const LanguageButton(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
