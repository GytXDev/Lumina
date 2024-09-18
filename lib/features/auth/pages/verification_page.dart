import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lumina/colors/coloors.dart';
import 'package:lumina/colors/extension/extension_theme.dart';
import 'package:lumina/features/auth/pages/login_page.dart';
import 'package:lumina/features/auth/repository/auth_repository.dart';
import 'package:lumina/features/auth/widgets/custom_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lumina/languages/app_translations.dart';

import '../controllers/auth_controller.dart';

class VerificationPage extends ConsumerStatefulWidget {
  const VerificationPage({
    super.key,
    required this.smsCodeId,
    required this.phoneNumber,
  });

  final String smsCodeId;
  final String phoneNumber;

  @override
  // ignore: library_private_types_in_public_api
  _VerificationPageState createState() => _VerificationPageState();
}

class _VerificationPageState extends ConsumerState<VerificationPage> {
  int resendDelay = 30;
  late Timer _timer;
  late TapGestureRecognizer _tapGestureRecognizer;

  @override
  void initState() {
    super.initState();
    startResendDelay();
    _tapGestureRecognizer = TapGestureRecognizer()..onTap = _handleTap;
  }

  @override
  void dispose() {
    _timer.cancel();
    _tapGestureRecognizer.dispose();
    super.dispose();
  }

  void _handleTap() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }

  void verifySmsCode(String smsCode) {
    ref.read(authControllerProvider).verifySmsCode(
          context: context,
          smsCodeId: widget.smsCodeId,
          smsCode: smsCode,
          mounted: true,
        );
    _timer.cancel();
  }

  void _showInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
              AppLocalizations.of(context).translate('updateComingSoonTitle')),
          content: Text(AppLocalizations.of(context)
              .translate('updateComingSoonContent')),
          actions: [
            TextButton(
              child: Text(AppLocalizations.of(context).translate('ok')),
              onPressed: () {
                Navigator.of(context).pop();
              },
            )
          ],
        );
      },
    );
  }

  void startResendDelay() {
    setState(() {
      resendDelay = 30;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (resendDelay > 0) {
        setState(() {
          resendDelay--;
        });
      } else {
        timer.cancel();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {});
    return Scaffold(
      appBar: AppBar(
        // ignore: deprecated_member_use
        backgroundColor: Theme.of(context).colorScheme.background,
        elevation: 0,
        title: Text(
          AppLocalizations.of(context).translate('verifyNumberTitle'),
          style: const TextStyle(
            color: Coolors.greyDark,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: TextStyle(
                    color: context.theme.greyColor,
                    height: 1.5,
                  ),
                  children: [
                    TextSpan(
                      text: AppLocalizations.of(context).translateWithVariables(
                        'registrationAttemptText',
                        {'phoneNumber': widget.phoneNumber},
                      ),
                    ),
                    TextSpan(
                      text: AppLocalizations.of(context)
                          .translate('wrongNumberText'),
                      style: TextStyle(
                        color: context.theme.blueColor,
                      ),
                      recognizer: _tapGestureRecognizer,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 80),
              child: CustomTextField(
                hinText: '_ _ _ _ _ _',
                fontSize: 30,
                autoFocus: true,
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  if (value.length == 6) {
                    verifySmsCode(value);
                  }
                },
                hintText: '',
              ),
            ),
            const SizedBox(
              height: 50,
            ),
            Text(
              AppLocalizations.of(context).translate('enterSixDigitCodeText'),
              style: TextStyle(
                color: context.theme.greyColor,
              ),
            ),
            const SizedBox(
              height: 30,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(
                      FontAwesomeIcons.message,
                      color: Coolors.blueDark,
                    ),
                    const SizedBox(
                      width: 8,
                    ),
                    InkWell(
                      onTap: resendDelay > 0
                          ? null
                          : () {
                              ref.read(authRepositoryProvider).sendSmsCode(
                                    context: context,
                                    phoneNumber: widget.phoneNumber,
                                  );
                              setState(() {
                                resendDelay = 30;
                              });
                              startResendDelay();
                            },
                      child: Text(
                        resendDelay > 0
                            ? AppLocalizations.of(context)
                                .translateWithVariables('resendInText',
                                    {'resendDelay': resendDelay})
                            : AppLocalizations.of(context)
                                .translate('resendSMSText'),
                        style: TextStyle(
                          color: context.theme.greyColor,
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    const Icon(
                      Icons.phone,
                      color: Coolors.blueDark,
                    ),
                    const SizedBox(
                      width: 8,
                    ),
                    InkWell(
                      onTap: () => _showInfoDialog(context),
                      child: Text(
                        AppLocalizations.of(context).translate('callMeText'),
                        style: TextStyle(
                          color: context.theme.greyColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(
              height: 20,
            ),
            Divider(
              color: context.theme.blueColor!.withOpacity(0.2),
            ),
          ],
        ),
      ),
    );
  }
}
