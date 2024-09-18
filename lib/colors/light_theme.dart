import 'package:lumina/colors/coloors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'extension/extension_theme.dart';

ThemeData lightTheme() {
  final ThemeData base = ThemeData.light();
  return base.copyWith(
    // ignore: deprecated_member_use
    scaffoldBackgroundColor: Coolors.backgroundLight,
    extensions: [
      CustomThemeExtension.lightMode,
    ],
    appBarTheme: AppBarTheme(
      backgroundColor:
          const Color.fromARGB(255, 141, 139, 139).withOpacity(0.9),
      titleTextStyle: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
      systemOverlayStyle: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarBrightness: Brightness.light,
      ),
      iconTheme: const IconThemeData(
        color: Colors.white,
      ),
    ),
    tabBarTheme: const TabBarTheme(
      indicator: UnderlineTabIndicator(
        borderSide: BorderSide(
          color: Colors.white,
          width:
              2.0, // Correction : Ajout du .0 après le 2 pour indiquer un double
        ),
      ),
      unselectedLabelColor: Color(0xFFB3D9D2),
      labelColor: Colors.white,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Coolors.greenLight,
        foregroundColor: Coolors.backgroundLight,
        splashFactory: NoSplash.splashFactory,
        elevation: 0,
        shadowColor: Colors.transparent,
      ),
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: Coolors.backgroundLight,
      modalBackgroundColor: Coolors.backgroundLight,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
    ),
    dialogBackgroundColor: Coolors.backgroundLight,
    dialogTheme: DialogTheme(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: Coolors.blueLight,
      foregroundColor: Colors.white,
    ),
    listTileTheme: const ListTileThemeData(
      iconColor: Coolors.greyDark,
      tileColor: Coolors.backgroundLight,
    ),
    switchTheme: const SwitchThemeData(
      thumbColor: WidgetStatePropertyAll(Color(0xFF83939C)),
      trackColor: WidgetStatePropertyAll(Color(0xFF344047)),
    ), colorScheme: ColorScheme(
  surface: Coolors.backgroundLight,
  onSurface: Colors.black, // Exemple d'une couleur par défaut
  brightness: Brightness.light, // Brightness est obligatoire (light ou dark)
  primary: Colors.blue, // Exemple d'une couleur
  onPrimary: Colors.white, // Contraste avec la couleur primaire
  secondary: Colors.green, // Exemple d'une couleur secondaire
  onSecondary: Colors.white, // Contraste avec la couleur secondaire
  error: Colors.red, // Couleur pour les erreurs
  onError: Colors.white, // Contraste pour l'arrière-plan
),

  );
}
