// fin d'appel
import 'package:flutter/material.dart';
import 'package:lumina/colors/coloors.dart';

import '../../../languages/app_translations.dart';

class CallTimeoutPage extends StatelessWidget {
  const CallTimeoutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Coolors.backgroundDark,
      body: Center(
        child: Text(
          AppLocalizations.of(context).translate('callTimeOut'),
          style: const TextStyle(fontSize: 24, color: Coolors.greyDark),
        ),
      ),
    );
  }
}
