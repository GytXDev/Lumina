import 'package:lumina/colors/dark_theme.dart';
import 'package:lumina/colors/light_theme.dart';
import 'package:lumina/features/auth/widgets/welcome_page.dart';
import 'package:lumina/languages/app_translations.dart';

import 'package:lumina/routes/routes_pages.dart';
import 'package:flutter/material.dart';
import 'package:lumina/widgets/error_pemission.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'features/auth/controllers/auth_controller.dart';
import 'home_section/home_page.dart';
import 'package:lumina/firebase_options.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

Locale? initialLocale;

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  // Initialiser les données de localisation
  await initializeDateFormatting();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Récupérer la langue sauvegardée depuis SharedPreferences
  final sharedPreferences = await SharedPreferences.getInstance();
  final savedLocale = sharedPreferences.getString('locale');

  String savedThemeMode =
      sharedPreferences.getString('themeMode') ?? 'ThemeMode.system';
  // ignore: avoid_print
  print("Saved theme mode: $savedThemeMode"); // Ajoutez cette ligne

  ThemeMode themeMode;
  switch (savedThemeMode) {
    case 'light':
      themeMode = ThemeMode.light;
      break;
    case 'dark':
      themeMode = ThemeMode.dark;
      break;
    default:
      themeMode = ThemeMode.system;
      break;
  }

  final container = ProviderContainer();
  container.read(themeModeProvider.notifier).state = themeMode;

  // Utiliser la langue sauvegardée ou la langue par défaut
  initialLocale =
      savedLocale != null ? Locale(savedLocale) : const Locale('fr');

  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.system);

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    return MaterialApp(
      title: 'Lumina',
      theme: lightTheme(),
      darkTheme: darkTheme(),
      debugShowCheckedModeBanner: false,
      locale: initialLocale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', 'US'),
        Locale('fr', 'FR'),
        Locale('zh', 'CN'), //Langue Chinoise
        Locale('de', 'DE'), // Langue Allemande
        Locale('es', 'ES'), //Langue Espagnol
        Locale('ja', 'JP'), // Langue Japonaise
        Locale('ar', 'AR'), //Langue arabe
      ],
      home: ref.watch(userInfoAuthProvider).when(
        data: (user) {
          FlutterNativeSplash.remove();
          if (user == null) return const WelcomePage();
          return const HomePage();
        },
        error: (error, trace) {
          // Gérer spécifiquement les erreurs de permission Firestore
          if (error == 'PERMISSION_DENIED') {
            // Naviguer vers la page d'erreur de permission
            return const PermissionErrorPage();
          } else {
            // Gérer les autres erreurs
            return const Scaffold(
              body: Center(
                child: Text('Something wrong happened!'),
              ),
            );
          }
        },
        loading: () {
          return const Scaffold(
            body: Center(
              child: Icon(
                Icons.whatshot_outlined,
                size: 30,
              ),
            ),
          );
        },
      ),
      themeMode: themeMode,
      onGenerateRoute: Routes.onGenerateRoute,
    );
  }
}
