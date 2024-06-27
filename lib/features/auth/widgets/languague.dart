import 'package:flutter/material.dart';
import 'package:lumina/colors/coloors.dart';
import 'package:lumina/colors/extension/extension_theme.dart';
import 'package:lumina/features/auth/widgets/custom_icon_button.dart';
import 'package:lumina/features/auth/widgets/welcome_page.dart';
import 'package:lumina/languages/app_translations.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageButton extends StatefulWidget {
  const LanguageButton({super.key});

  @override
  State<LanguageButton> createState() => _LanguageButtonState();
}

class _LanguageButtonState extends State<LanguageButton> {
  @override
  void initState() {
    super.initState();

    // Récupérer la langue actuelle depuis SharedPreferences
    SharedPreferences.getInstance().then((sharedPreferences) {
      setState(() {
        currentLanguageCode = sharedPreferences.getString('locale') ?? 'fr';

        // Mettre à jour les booléens en fonction de la langue actuelle
        isFrench = currentLanguageCode == 'fr';
        isEnglish = currentLanguageCode == 'en';
        isChinese = currentLanguageCode == 'zh';
        isSpanish = currentLanguageCode == 'es';
        isGerman = currentLanguageCode == 'de';
        isJapanese = currentLanguageCode == 'ja';
        isArabic = currentLanguageCode == 'ar';
      });
    });
  }

  bool isFrench = true;
  bool isEnglish = false;
  bool isChinese = false;
  bool isSpanish = false;
  bool isGerman = false;
  bool isJapanese = false;
  bool isArabic = false;

  late String currentLanguageCode = 'fr';

  void showBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  height: 4,
                  width: 30,
                  decoration: BoxDecoration(
                    color: context.theme.greyColor!.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                Row(
                  children: [
                    const SizedBox(
                      width: 20,
                    ),
                    CustomIconButton(
                      onTap: () => Navigator.of(context).pop(),
                      icon: Icons.close_outlined,
                      iconColor: context.theme.blackText,
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    const Text(
                      'Lumina Language',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                RadioListTile(
                  value: 'french',
                  groupValue: isFrench ? 'french' : null,
                  onChanged: (value) {
                    setState(() {
                      isFrench = true;
                      isEnglish = false;
                      isSpanish = false;
                      isChinese = false;
                      isGerman = false;
                      isJapanese = false;
                      isArabic = false;
                    });
                    AppLocalizations.of(context)
                        .changeLocale(const Locale('fr', 'FR'));
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const WelcomePage(),
                      ),
                    );
                    // Mettre à jour l'interface utilisateur
                    setState(() {});
                  },
                  activeColor: Coolors.blueDark,
                  title: Text(AppLocalizations.of(context).translate('french')),
                  subtitle: Text(
                    AppLocalizations.of(context).translate('frenchSubtitle'),
                    style: TextStyle(
                      color: context.theme.greyColor,
                    ),
                  ),
                ),
                RadioListTile(
                  value: 'english',
                  groupValue: isEnglish ? 'english' : null,
                  onChanged: (value) {
                    setState(() {
                      isFrench = false;
                      isEnglish = true;
                      isSpanish = false;
                      isChinese = false;
                      isGerman = false;
                      isJapanese = false;
                      isArabic = false;
                    });
                    AppLocalizations.of(context)
                        .changeLocale(const Locale('en', 'US'));
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const WelcomePage(),
                      ),
                    );
                    // Mettre à jour l'interface utilisateur
                    setState(() {});
                  },
                  activeColor: Coolors.blueDark,
                  title:
                      Text(AppLocalizations.of(context).translate('english')),
                  subtitle: Text(
                    AppLocalizations.of(context).translate('englishSubtitle'),
                    style: TextStyle(
                      color: context.theme.greyColor,
                    ),
                  ),
                ),
                RadioListTile(
                  value: 'chinese',
                  groupValue: isChinese ? 'chinese' : null,
                  onChanged: (value) {
                    setState(() {
                      isFrench = false;
                      isEnglish = false;
                      isSpanish = false;
                      isChinese = true;
                      isGerman = false;
                      isJapanese = false;
                      isArabic = false;
                    });
                    AppLocalizations.of(context)
                        .changeLocale(const Locale('zh', 'CN'));
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const WelcomePage(),
                      ),
                    );
                    // Mettre à jour l'interface utilisateur
                    setState(() {});
                  },
                  activeColor: Coolors.blueDark,
                  title:
                      Text(AppLocalizations.of(context).translate('chinese')),
                  subtitle: Text(
                    AppLocalizations.of(context).translate('chineseSubtitle'),
                    style: TextStyle(
                      color: context.theme.greyColor,
                    ),
                  ),
                ),
                RadioListTile(
                  value: 'spanish',
                  groupValue: isSpanish ? 'spanish' : null,
                  onChanged: (value) {
                    setState(() {
                      isFrench = false;
                      isEnglish = false;
                      isSpanish = true;
                      isChinese = false;
                      isGerman = false;
                      isJapanese = false;
                      isArabic = false;
                    });
                    AppLocalizations.of(context)
                        .changeLocale(const Locale('es', 'ES'));
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const WelcomePage(),
                      ),
                    );
                    // Mettre à jour l'interface utilisateur
                    setState(() {});
                  },
                  activeColor: Coolors.blueDark,
                  title:
                      Text(AppLocalizations.of(context).translate('spanish')),
                  subtitle: Text(
                    AppLocalizations.of(context).translate('spanishSubtitle'),
                    style: TextStyle(
                      color: context.theme.greyColor,
                    ),
                  ),
                ),
                RadioListTile(
                  value: 'german',
                  groupValue: isGerman ? 'german' : null,
                  onChanged: (value) {
                    setState(() {
                      isFrench = false;
                      isEnglish = false;
                      isGerman = true;
                      isFrench = false;
                      isSpanish = false;
                      isChinese = false;
                      isArabic = false;
                    });
                    AppLocalizations.of(context)
                        .changeLocale(const Locale('de', 'DE'));
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const WelcomePage(),
                      ),
                    );
                    // Mettre à jour l'interface utilisateur
                    setState(() {});
                  },
                  activeColor: Coolors.blueDark,
                  title: Text(AppLocalizations.of(context).translate('german')),
                  subtitle: Text(
                    AppLocalizations.of(context).translate('germanSubtitle'),
                    style: TextStyle(
                      color: context.theme.greyColor,
                    ),
                  ),
                ),
                RadioListTile(
                  value: 'japanese',
                  groupValue: isJapanese ? 'japanese' : null,
                  onChanged: (value) {
                    setState(() {
                      isFrench = false;
                      isEnglish = false;
                      isJapanese = true;
                      isSpanish = false;
                      isChinese = false;
                      isGerman = false;
                      isArabic = false;
                    });
                    AppLocalizations.of(context).changeLocale(
                      const Locale('ja', 'JP'),
                    );
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const WelcomePage(),
                      ),
                    );
                    // Mettre à jour l'interface utilisateur
                    setState(() {});
                  },
                  activeColor: Coolors.blueDark,
                  title:
                      Text(AppLocalizations.of(context).translate('japanese')),
                  subtitle: Text(
                    AppLocalizations.of(context).translate('japaneseSubtitle'),
                    style: TextStyle(
                      color: context.theme.greyColor,
                    ),
                  ),
                ),
                RadioListTile(
                  value: 'arabic',
                  groupValue: isArabic ? 'arabic' : null,
                  onChanged: (value) {
                    setState(() {
                      isArabic = true;
                      isFrench = false;
                      isEnglish = false;
                      isJapanese = false;
                      isSpanish = false;
                      isChinese = false;
                      isGerman = false;
                    });
                    AppLocalizations.of(context)
                        .changeLocale(const Locale('ar', 'AR'));
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const WelcomePage(),
                      ),
                    );
                    // Mettre à jour l'interface utilisateur
                    setState(() {});
                  },
                  activeColor: Coolors.blueDark,
                  title: Text(AppLocalizations.of(context).translate('arabe')),
                  subtitle: Text(
                    AppLocalizations.of(context).translate('arabeSubtitle'),
                    style: TextStyle(color: context.theme.greyColor),
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.theme.langBtnBgColor,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: () {
          showBottomSheet(context);
        },
        borderRadius: BorderRadius.circular(20),
        splashFactory: NoSplash.splashFactory,
        highlightColor: context.theme.langBtnHighLightColor,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 15,
            vertical: 10,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.language,
                color: Coolors.blueDark,
              ),
              const SizedBox(
                width: 10,
              ),
              Text(
                isFrench
                    ? AppLocalizations.of(context).translate('french')
                    : (isEnglish
                        ? AppLocalizations.of(context).translate('english')
                        : (isChinese
                            ? AppLocalizations.of(context).translate('chinese')
                            : (isSpanish
                                ? AppLocalizations.of(context)
                                    .translate('spanish')
                                : (isGerman
                                    ? AppLocalizations.of(context)
                                        .translate('german')
                                    : AppLocalizations.of(context)
                                        .translate('japanese'))))),
                style: const TextStyle(
                  color: Coolors.greyDark,
                ),
              ),
              const SizedBox(
                width: 10,
              ),
              const Icon(
                Icons.keyboard_arrow_down,
                color: Coolors.blueDark,
              )
            ],
          ),
        ),
      ),
    );
  }
}
