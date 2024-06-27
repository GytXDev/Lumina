import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ionicons/ionicons.dart';
import 'package:lumina/colors/coloors.dart';
import 'package:lumina/colors/extension/extension_theme.dart';
import 'package:lumina/features/auth/pages/update_user_info.dart';
import 'package:lumina/features/auth/widgets/custom_icon_button.dart';

import 'package:lumina/features/auth/widgets/welcome_page.dart';

import 'package:lumina/home_section/widgets/widgets/about_us.dart';
import 'package:lumina/home_section/widgets/widgets/forward_button.dart';
import 'package:lumina/home_section/widgets/widgets/settings_widget.dart';
import 'package:lumina/languages/app_translations.dart';
import 'package:lumina/main.dart';
import 'package:quickalert/quickalert.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({
    super.key,
    required this.username,
    required this.profileImageUrl,
  });

  final String username;
  final String profileImageUrl;

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  // Fonction de déconnexion
  void _signOut() async {
    await FirebaseAuth.instance.signOut();
    // ignore: use_build_context_synchronously
    Navigator.pushReplacement(
      // ignore: use_build_context_synchronously
      context,
      MaterialPageRoute(
        builder: (context) => const WelcomePage(),
      ),
    );
  }

  late String currentLanguageCode = 'fr';

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

  void _setThemeMode(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    String modeString = '';
    switch (mode) {
      case ThemeMode.light:
        modeString = 'light';
        break;
      case ThemeMode.dark:
        modeString = 'dark';
        break;
      case ThemeMode.system:
        modeString = 'system';
        break;
    }
    await prefs.setString('themeMode', modeString);
    ref.read(themeModeProvider.notifier).state = mode;
  }

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
                    Navigator.of(context).pop();
                    // Mettre à jour l'interface utilisateur après le changement de langue
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
                    Navigator.of(context).pop();
                    // Mettre à jour l'interface utilisateur après le changement de langue
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
                    Navigator.of(context).pop();
                    // Mettre à jour l'interface utilisateur après le changement de langue
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
                    Navigator.of(context).pop();
                    // Mettre à jour l'interface utilisateur après le changement de langue
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
                    Navigator.of(context).pop();
                    // Mettre à jour l'interface utilisateur après le changement de langue
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
                    Navigator.of(context).pop();
                    // Mettre à jour l'interface utilisateur après le changement de langue
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
                    Navigator.pop(context);
                    // Mettre à jour l'interface utilisateur après le changement de langue
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
    return Scaffold(
      appBar: AppBar(
        // ignore: deprecated_member_use
        backgroundColor: Theme.of(context).backgroundColor,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Ionicons.chevron_back_outline,
              color: context.theme.blackText),
        ),
        leadingWidth: 80,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppLocalizations.of(context).translate('settingTitle'),
                style: const TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 40),
              Text(
                AppLocalizations.of(context).translate('accountTitle'),
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 60.0,
                      backgroundColor: Coolors.greyDark,
                      backgroundImage: widget.profileImageUrl.isNotEmpty
                          ? NetworkImage(widget.profileImageUrl)
                          : null,
                      child: widget.profileImageUrl.isEmpty
                          ? const Icon(
                              Icons.person,
                              size: 60.0,
                              color: Colors.white,
                            )
                          : null,
                    ),
                    const SizedBox(width: 20),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.username,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          AppLocalizations.of(context).translate('luminaUser'),
                          style: const TextStyle(
                            fontSize: 14,
                            color: Coolors.greyDark,
                          ),
                        )
                      ],
                    ),
                    const Spacer(),
                    ForwardButton(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => UpdateUserInfo(
                              profileImageUrl: widget.profileImageUrl,
                            ),
                          ),
                        );
                      },
                    )
                  ],
                ),
              ),
              const SizedBox(height: 40),
              Text(
                AppLocalizations.of(context).translate('settingTitle'),
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 20),
              SettingItem(
                title: AppLocalizations.of(context).translate('languageText'),
                icon: Ionicons.language,
                bgColor: Coolors.blueDark,
                iconColor: Colors.white,
                value: isFrench
                    ? AppLocalizations.of(context).translate('french')
                    : isEnglish
                        ? AppLocalizations.of(context).translate('english')
                        : isChinese
                            ? AppLocalizations.of(context).translate('chinese')
                            : isSpanish
                                ? AppLocalizations.of(context)
                                    .translate('spanish')
                                : isGerman
                                    ? AppLocalizations.of(context)
                                        .translate('german')
                                    : AppLocalizations.of(context)
                                        .translate('japanese'),
                onTap: () {
                  showBottomSheet(context);
                },
              ),
              const SizedBox(height: 20),
              SettingItem(
                title: AppLocalizations.of(context).translate('aboutUs'),
                icon: Icons.group,
                bgColor: Coolors.blueDark,
                iconColor: Colors.white,
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => const AboutUs()));
                },
              ),
              const SizedBox(height: 20),
              SettingItem(
                title: AppLocalizations.of(context).translate('themeTitle'),
                icon: Icons.palette,
                bgColor: Coolors.blueDark,
                iconColor: Colors.white,
                onTap: () async {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return SimpleDialog(
                        title: Text(AppLocalizations.of(context)
                            .translate('chooseTheme')),
                        children: <Widget>[
                          SimpleDialogOption(
                            onPressed: () {
                              _setThemeMode(ThemeMode.light);
                              Navigator.pop(context);
                            },
                            child: Text(AppLocalizations.of(context)
                                .translate('light')),
                          ),
                          SimpleDialogOption(
                            onPressed: () {
                              _setThemeMode(ThemeMode.dark);
                              Navigator.pop(context);
                            },
                            child: Text(
                                AppLocalizations.of(context).translate('dark')),
                          ),
                          SimpleDialogOption(
                            onPressed: () {
                              _setThemeMode(ThemeMode.system);
                              Navigator.pop(context);
                            },
                            child: Text(AppLocalizations.of(context)
                                .translate('system')),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
              const SizedBox(height: 20),
              SettingItem(
                title: AppLocalizations.of(context).translate('logout'),
                icon: Ionicons.log_out_outline,
                bgColor: Coolors.blueDark,
                iconColor: Colors.white,
                onTap: () {
                  QuickAlert.show(
                    onCancelBtnTap: () {
                      Navigator.pop(context);
                    },
                    context: context,
                    type: QuickAlertType.confirm,
                    title: AppLocalizations.of(context)
                        .translate('ConfirmationLogout'),
                    text: AppLocalizations.of(context)
                        .translate('ConfirmationText'),
                    textAlignment: TextAlign.center,
                    confirmBtnText: AppLocalizations.of(context)
                        .translate('markAsPaidConfirmationYes'),
                    cancelBtnText: AppLocalizations.of(context)
                        .translate('markAsPaidConfirmationNo'),
                    confirmBtnColor: Coolors.greenDark,
                    onConfirmBtnTap: () {
                      _signOut();
                      Navigator.pop(context);
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
