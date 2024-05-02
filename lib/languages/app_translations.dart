import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppLocalizations extends ChangeNotifier {
  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  late Map<String, String> _localizedStrings;

  Future<void> load(Locale locale) async {
    // ignore: avoid_print
    print("Loading translations for locale: ${locale.languageCode}");
    String jsonString =
        await rootBundle.loadString('assets/i18n/${locale.languageCode}.json');
    Map<String, dynamic> decodedStrings = json.decode(jsonString);
    // Convertissez les valeurs du Map en String
    _localizedStrings = Map<String, String>.from(decodedStrings);
  }

  VoidCallback addChangeLocaleListener(VoidCallback callback) {
    return () {
      notifyListeners();
      callback();
    };
  }

  Future<void> changeLocale(Locale newLocale) async {
    // Charger les nouvelles traductions
    // ignore: avoid_print
    print("Loading translations for locale: ${newLocale.languageCode}");
    String jsonString = await rootBundle
        .loadString('assets/i18n/${newLocale.languageCode}.json');
    Map<String, dynamic> decodedStrings = json.decode(jsonString);
    // Convertissez les valeurs du Map en String
    _localizedStrings = Map<String, String>.from(decodedStrings);

    // Sauvegarder la nouvelle langue dans SharedPreferences
    final sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setString('locale', newLocale.languageCode);

    // Afficher en console le changement de la langue
    // ignore: avoid_print
    print("Language changed to: ${newLocale.languageCode}");
  }

  //méthode pour accéder aux clés
  String translate(String key) {
    return _localizedStrings[key] ?? '';
  }

  //Traduction avec variable
  String translateWithVariables(String key, Map<String, dynamic> variables) {
    String translation = _localizedStrings[key] ?? '';

    // Remplacez les variables dans la traduction
    variables.forEach((variableKey, variableValue) {
      translation =
          translation.replaceAll("{{$variableKey}}", variableValue.toString());
    });

    return translation;
  }

  // Implémentez la méthode 'of' pour obtenir l'instance de AppLocalizations à partir du contexte
  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) =>
      ['en', 'fr', 'zh', 'ar', 'ja', 'es', 'de'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async {
    Locale adjustedLocale;

    // Vérifiez si la locale complète est prise en charge
    if (isSupported(locale)) {
      adjustedLocale = locale;
    } else {
      // Utilisez "fr" au lieu de "fr_FR" si la locale complète n'est pas prise en charge
      adjustedLocale = const Locale('fr');
    }

    AppLocalizations localizations = AppLocalizations();
    await localizations.load(adjustedLocale);
    return localizations;
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
