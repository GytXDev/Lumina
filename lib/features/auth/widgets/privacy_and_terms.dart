// ignore_for_file: deprecated_member_use, unused_element

import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:lumina/colors/coloors.dart';
import 'package:lumina/colors/extension/extension_theme.dart';
import 'package:lumina/languages/app_translations.dart';
import 'package:url_launcher/url_launcher.dart';

class PrivacyAndTerms extends StatelessWidget {
  final bool policyAccepted;
  final bool termsAccepted;
  final ValueChanged<bool> onPolicyAccepted;
  final ValueChanged<bool> onTermsAccepted;

  const PrivacyAndTerms({
    required this.policyAccepted,
    required this.termsAccepted,
    required this.onPolicyAccepted,
    required this.onTermsAccepted,
    super.key,
  });

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

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 30),
      child: SingleChildScrollView(
        child: RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            text: AppLocalizations.of(context).translate('readOur'),
            style: const TextStyle(
              color: Coolors.greyDark,
              height: 1.5,
            ),
            children: [
              TextSpan(
                text: AppLocalizations.of(context).translate('privacyPolicy'),
                style: TextStyle(
                  color: context.theme.blueColor,
                  fontWeight: FontWeight.w600,
                ),
                recognizer: TapGestureRecognizer()
                  ..onTap = () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return StatefulBuilder(
                          builder: (context, setState) {
                            return AlertDialog(
                              title: Text(
                                AppLocalizations.of(context)
                                    .translate('privacyPolicy'),
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Coolors.blueDark,
                                ),
                              ),
                              content: SingleChildScrollView(
                                child: Column(
                                  children: [
                                    RichText(
                                      text: TextSpan(
                                        style:
                                            DefaultTextStyle.of(context).style,
                                        children: <TextSpan>[
                                          TextSpan(
                                            text:
                                                '\n\n${AppLocalizations.of(context).translate('introductionSection')}\n',
                                            style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600),
                                          ),
                                          TextSpan(
                                            text:
                                                '\n${AppLocalizations.of(context).translate('privacyPolicyContent')}',
                                          ),
                                          TextSpan(
                                            text:
                                                '\n${AppLocalizations.of(context).translate('lastUpdated')} ',
                                          ),
                                          TextSpan(
                                            text:
                                                '\n\n${AppLocalizations.of(context).translate('informationCollectionSection')}\n',
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          TextSpan(
                                            text:
                                                '\n${AppLocalizations.of(context).translate('informationCollectionDescription')}\n',
                                          ),
                                          TextSpan(
                                            text:
                                                '\n\n${AppLocalizations.of(context).translate('informationUsageDescription')}\n',
                                          ),
                                          TextSpan(
                                            text:
                                                '\n${AppLocalizations.of(context).translate('informationUsageProvideService')}\n',
                                          ),
                                          TextSpan(
                                            text:
                                                '\n${AppLocalizations.of(context).translate('informationUsageProcessTransactions')}\n',
                                          ),
                                          TextSpan(
                                            text:
                                                '\n${AppLocalizations.of(context).translate('informationUsageNotifyChanges')}\n',
                                          ),
                                          TextSpan(
                                            text:
                                                '\n${AppLocalizations.of(context).translate('informationUsageCustomerSupport')}\n',
                                          ),
                                          TextSpan(
                                            text:
                                                '\n${AppLocalizations.of(context).translate('informationUsageTrackUsage')}\n',
                                          ),
                                          TextSpan(
                                            text:
                                                '\n${AppLocalizations.of(context).translate('informationUsageDetectIssues')}\n',
                                          ),
                                          TextSpan(
                                            text:
                                                '\n\n${AppLocalizations.of(context).translate('imageCollectionAndUsagePurpose')}\n',
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          TextSpan(
                                            text:
                                                '\n${AppLocalizations.of(context).translate('imageCollectionAndUsagePurposeDescription')}\n',
                                          ),
                                          TextSpan(
                                            text:
                                                '\n\n${AppLocalizations.of(context).translate('sensitiveDataProtection')}\n',
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          TextSpan(
                                            text:
                                                '\n${AppLocalizations.of(context).translate('sensitiveDataDescription')}\n',
                                          ),
                                          TextSpan(
                                            text:
                                                '\n\n${AppLocalizations.of(context).translate('applicationPermissions')}\n',
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          TextSpan(
                                            text:
                                                '\n${AppLocalizations.of(context).translate('cameraAccess')}\n',
                                          ),
                                          TextSpan(
                                            text:
                                                '\n${AppLocalizations.of(context).translate('cameraAccessDescription')}\n',
                                          ),
                                          TextSpan(
                                            text:
                                                '\n${AppLocalizations.of(context).translate('locationAccess')}\n',
                                          ),
                                          TextSpan(
                                            text:
                                                '\n${AppLocalizations.of(context).translate('locationAccessDescription')}\n',
                                          ),
                                          TextSpan(
                                            text:
                                                '\n${AppLocalizations.of(context).translate('storageAccess')}\n',
                                          ),
                                          TextSpan(
                                            text:
                                                '\n${AppLocalizations.of(context).translate('storageAccessDescription')}\n',
                                          ),
                                          TextSpan(
                                            text:
                                                '\n\n${AppLocalizations.of(context).translate('thirdPartyAccess')}\n',
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          TextSpan(
                                            text:
                                                '\n${AppLocalizations.of(context).translate('thirdPartyDescription')}\n',
                                          ),
                                          TextSpan(
                                            text:
                                                '\n\n${AppLocalizations.of(context).translate('optOutRights')}\n',
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          TextSpan(
                                            text:
                                                '\n${AppLocalizations.of(context).translate('optOutDescription')}\n',
                                          ),
                                          TextSpan(
                                            text:
                                                '\n\n${AppLocalizations.of(context).translate('useOfCookies')}\n',
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          TextSpan(
                                            text:
                                                '\n${AppLocalizations.of(context).translate('cookiesDescription')}\n',
                                          ),
                                          TextSpan(
                                            text:
                                                '\n\n${AppLocalizations.of(context).translate('dataRetentionPolicy')}\n',
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          TextSpan(
                                            text:
                                                '\n${AppLocalizations.of(context).translate('dataRetentionDescription')}\n',
                                          ),
                                          TextSpan(
                                            text:
                                                '\n\n${AppLocalizations.of(context).translate('children')}\n',
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          TextSpan(
                                            text:
                                                '\n${AppLocalizations.of(context).translate('childrenDescription')}\n',
                                          ),
                                          TextSpan(
                                            text:
                                                '\n\n${AppLocalizations.of(context).translate('security')}\n',
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          TextSpan(
                                            text:
                                                '\n${AppLocalizations.of(context).translate('securityDescription')}\n',
                                          ),
                                          TextSpan(
                                            text:
                                                '\n\n${AppLocalizations.of(context).translate('yourConsent')}\n',
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          TextSpan(
                                            text:
                                                '\n${AppLocalizations.of(context).translate('consentDescription')}\n',
                                          ),
                                          TextSpan(
                                            text:
                                                '\n\n${AppLocalizations.of(context).translate('contactUs')}\n',
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          TextSpan(
                                            text:
                                                '\n${AppLocalizations.of(context).translate('contactDescription')}\n',
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              actions: [
                                Column(
                                  children: [
                                    Row(
                                      children: [
                                        Checkbox(
                                          value: policyAccepted,
                                          onChanged: (value) {
                                            onPolicyAccepted(value ?? false);
                                          },
                                        ),
                                        Expanded(
                                          child: Text(
                                            AppLocalizations.of(context)
                                                .translate(
                                                    'acceptPrivacyPolicy'),
                                            style:
                                                const TextStyle(fontSize: 16.0),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                )
                              ],
                            );
                          },
                        );
                      },
                    );
                  },
              ),
              TextSpan(
                text: AppLocalizations.of(context).translate('tapToAccept'),
              ),
              TextSpan(
                text: AppLocalizations.of(context).translate('termsOfServices'),
                style: TextStyle(
                  color: context.theme.blueColor,
                  fontWeight: FontWeight.w600,
                ),
                recognizer: TapGestureRecognizer()
                  ..onTap = () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return StatefulBuilder(
                          builder: (context, setState) {
                            return AlertDialog(
                              title: Text(
                                AppLocalizations.of(context)
                                    .translate('termsOfServices'),
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Coolors.blueDark,
                                ),
                              ),
                              content: SingleChildScrollView(
                                child: Column(
                                  children: [
                                    RichText(
                                      text: TextSpan(
                                        style:
                                            DefaultTextStyle.of(context).style,
                                        children: <TextSpan>[
                                          TextSpan(
                                            text:
                                                '\n\n ${AppLocalizations.of(context).translate('conditionsAcceptanceSection')}\n',
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          TextSpan(
                                            text:
                                                '\n${AppLocalizations.of(context).translate('accessApplicationAgreement')}',
                                          ),
                                          TextSpan(
                                            text:
                                                '\n\n ${AppLocalizations.of(context).translate('vehicleSalesSection')}\n',
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          TextSpan(
                                            text:
                                                '\n${AppLocalizations.of(context).translate('sellVehicleAgreement')}',
                                          ),
                                          TextSpan(
                                            text:
                                                '\n\n ${AppLocalizations.of(context).translate('restrictionsSection')}\n',
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          TextSpan(
                                            text:
                                                '\n${AppLocalizations.of(context).translate('vehicleSaleRestrictions')}',
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              actions: [
                                Column(
                                  children: [
                                    Row(
                                      children: [
                                        Checkbox(
                                          value: termsAccepted,
                                          onChanged: (value) {
                                            onTermsAccepted(value ?? false);
                                          },
                                        ),
                                        Expanded(
                                          child: Text(
                                            AppLocalizations.of(context)
                                                .translate('acceptTerms'),
                                            style:
                                                const TextStyle(fontSize: 16),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                )
                              ],
                            );
                          },
                        );
                      },
                    );
                  },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
