import 'package:lumina/colors/extension/extension_theme.dart';
import 'package:flutter/material.dart';
import 'package:lumina/languages/app_translations.dart';

class InfoCard extends StatelessWidget {
  const InfoCard({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(
        vertical: 10,
        horizontal: 30,
      ),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: context.theme.infoCardBgColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        AppLocalizations.of(context).translate('welcomeChat'),
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 13,
          color: context.theme.infoCardTextColor,
        ),
      ),
    );
  }
}
