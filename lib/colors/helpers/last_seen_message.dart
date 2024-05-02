import 'package:flutter/material.dart';
import 'package:lumina/languages/app_translations.dart';

String lastSeenMessage(lastSeen, BuildContext context) {
  DateTime now = DateTime.now();
  Duration differenceDuration = now.difference(
    DateTime.fromMillisecondsSinceEpoch(lastSeen),
  );

  String finalMessage = differenceDuration.inSeconds > 59
      ? differenceDuration.inMinutes > 59
          ? differenceDuration.inHours > 23
              ? "${differenceDuration.inDays} ${differenceDuration.inDays == 1 ? AppLocalizations.of(context).translate('day') : AppLocalizations.of(context).translate('days')}"
              : "${differenceDuration.inHours} ${differenceDuration.inHours == 1 ? AppLocalizations.of(context).translate('hour') : AppLocalizations.of(context).translate('hours')}"
          : "${differenceDuration.inMinutes} ${differenceDuration.inMinutes == 1 ? AppLocalizations.of(context).translate('minute') : AppLocalizations.of(context).translate('minutes')}"
      : AppLocalizations.of(context).translate('fewMoments');

  return finalMessage;
}
