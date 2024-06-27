import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lumina/colors/extension/extension_theme.dart';

import '../../../languages/app_translations.dart';

class ShowDateCard extends StatelessWidget {
  const ShowDateCard({super.key, required this.date});

  final DateTime date;

  String _getMessageTimeString(BuildContext context) {
    DateTime now = DateTime.now();
    DateTime today = DateTime(now.year, now.month, now.day);
    DateTime yesterday = today.subtract(const Duration(days: 1));
    DateTime aWeekAgo = today.subtract(const Duration(days: 7));
    String locale = Localizations.localeOf(context).languageCode;

    if (date.isAfter(today)) {
      return AppLocalizations.of(context).translate('today');
    } else if (date.isAfter(yesterday)) {
      // Si la date est hier, retourne 'Hier'.
      return AppLocalizations.of(context).translate('yesterday');
    } else if (date.isAfter(aWeekAgo)) {
      // Si la date est au cours des 7 derniers jours, retourne le jour de la semaine.
      return DateFormat('EEEE', locale).format(date);
    } else {
      // Pour les dates plus anciennes, retourne la date complète.
      return DateFormat('dd/MM/yyyy', locale).format(date);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: 5,
        horizontal: 10,
      ),
      margin: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: context.theme.receiverChatCardBg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        _getMessageTimeString(context),
        style: const TextStyle(color: Colors.white),
      ),
    );
  }
}
