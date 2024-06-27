import 'package:lumina/colors/coloors.dart';
import 'package:flutter/material.dart';

extension ExtendedTheme on BuildContext {
  CustomThemeExtension get theme {
    return Theme.of(this).extension<CustomThemeExtension>()!;
  }
}

class CustomThemeExtension extends ThemeExtension<CustomThemeExtension> {
  //extension on dart
  static CustomThemeExtension lightMode = CustomThemeExtension(
    greyColor: Coolors.greyLight,
    blueColor: Coolors.blueLight,
    langBtnBgColor: const Color(0xFFF8F8F8),
    langBtnHighLightColor: const Color(0xFFE8E8ED),
    authAppbarTextColor: Coolors.greenLight,
    photoIconBgColor: const Color(0xFFF0F2F3),
    photoIconColor: const Color(0xFF9DAAB3),
    profilePagebg: const Color(0xFFF7F8FA),
    chatTextBg: Colors.white,
    chatPageBgColor: const Color(0xFF0B141A),
    chatPageDoodleColor: Coolors.greyBackground,
    senderChatCardBg: Colors.white,
    receiverChatCardBg:
        const Color.fromARGB(255, 141, 139, 139).withOpacity(0.6),
    infoCardBgColor: const Color(0xFFFFEECC),
    infoCardTextColor: const Color(0xFF222E35),
    textAppBar: Colors.white,
    redColor: const Color(0xFFFF0000),
    purpleColor: const Color.fromARGB(255, 27, 19, 31),
    searchBar: Colors.white.withOpacity(0.9),
    blackText: Colors.black,
    lightText: Colors.white,
    audioColor: Colors.black.withOpacity(0.4),
  );

  static CustomThemeExtension darkMode = CustomThemeExtension(
    circleImageColor: Coolors.greenDark,
    greyColor: Coolors.greyDark,
    blueColor: Coolors.blueDark,
    langBtnBgColor: const Color(0xFF182229),
    langBtnHighLightColor: const Color(0xFF09141A),
    authAppbarTextColor: const Color(0xFFE9EDEF),
    photoIconBgColor: const Color(0xFF283339),
    photoIconColor: const Color(0xFF61717B),
    profilePagebg: const Color(0xFF0B141A),
    chatTextBg: Coolors.greyBackground,
    chatPageBgColor: const Color(0xFF081419),
    chatPageDoodleColor: const Color(0xFF172428),
    senderChatCardBg: null,
    receiverChatCardBg: Coolors.greyBackground,
    infoCardBgColor: const Color(0xFF222E35),
    infoCardTextColor: const Color(0xFFFFEECC),
    textAppBar: Colors.black,
    redColor: const Color(0xFFB30000),
    purpleColor: const Color(0xFF5B008A),
    searchBar: Colors.grey[850]!.withOpacity(0.9),
    blackText: Colors.white,
    lightText: Colors.black,
    audioColor: Colors.white,
  );

  final Color? circleImageColor;
  final Color? greyColor;
  final Color? blueColor;
  final Color? langBtnBgColor;
  final Color? langBtnHighLightColor;
  final Color? authAppbarTextColor;
  final Color? photoIconBgColor;
  final Color? photoIconColor;
  final Color? profilePagebg;
  final Color? chatTextBg;
  final Color? chatPageBgColor;
  final Color? chatPageDoodleColor;
  final Color? senderChatCardBg;
  final Color? receiverChatCardBg;
  final Color? infoCardBgColor;
  final Color? infoCardTextColor;
  final Color? textAppBar;
  final Color? redColor;
  final Color? purpleColor;
  final Color? searchBar;
  final Color? blackText;
  final Color? lightText;
  final Color? audioColor;

  const CustomThemeExtension({
    this.circleImageColor,
    this.greyColor,
    this.blueColor,
    this.langBtnBgColor,
    this.langBtnHighLightColor,
    this.authAppbarTextColor,
    this.photoIconBgColor,
    this.photoIconColor,
    this.profilePagebg,
    this.chatTextBg,
    this.chatPageBgColor,
    this.chatPageDoodleColor,
    this.senderChatCardBg,
    this.receiverChatCardBg,
    this.infoCardBgColor,
    this.infoCardTextColor,
    this.textAppBar,
    this.redColor,
    this.purpleColor,
    this.searchBar,
    this.blackText,
    this.lightText,
    this.audioColor,
  });

  get textColor => null;

  @override
  ThemeExtension<CustomThemeExtension> copyWith({
    Color? circleImageColor,
    Color? greyColor,
    Color? blueColor,
    Color? langBtnBgColor,
    Color? langBtnHighLightColor,
    Color? authAppbarTextColor,
    Color? photoIconBgColor,
    Color? photoIconColor,
    Color? profilePagebg,
    Color? chatTextBg,
    Color? chatPageBgColor,
    Color? chatPageDoodleColor,
    Color? senderChatCardBg,
    Color? receiverChatCardBg,
    Color? infoCardBgColor,
    Color? infoCardTextColor,
    Color? textAppBar,
    Color? redColor,
    Color? purpleColor,
    Color? searchBar,
    Color? blackText,
    Color? lightText,
    Color? audioColor,
  }) {
    return CustomThemeExtension(
      circleImageColor: circleImageColor ?? this.circleImageColor,
      greyColor: greyColor ?? this.greyColor,
      blueColor: blueColor ?? this.blueColor,
      langBtnBgColor: langBtnBgColor ?? this.langBtnBgColor,
      langBtnHighLightColor:
          langBtnHighLightColor ?? this.langBtnHighLightColor,
      authAppbarTextColor: authAppbarTextColor ?? this.authAppbarTextColor,
      photoIconBgColor: photoIconBgColor ?? this.photoIconBgColor,
      photoIconColor: photoIconColor ?? this.photoIconColor,
      profilePagebg: profilePagebg ?? this.profilePagebg,
      chatTextBg: chatTextBg ?? this.chatTextBg,
      chatPageBgColor: chatPageBgColor ?? this.chatPageBgColor,
      chatPageDoodleColor: chatPageDoodleColor ?? this.chatPageDoodleColor,
      senderChatCardBg: senderChatCardBg ?? this.senderChatCardBg,
      receiverChatCardBg: receiverChatCardBg ?? this.receiverChatCardBg,
      infoCardBgColor: infoCardBgColor ?? this.infoCardBgColor,
      infoCardTextColor: infoCardTextColor ?? this.infoCardTextColor,
      textAppBar: textAppBar ?? this.textAppBar,
      redColor: redColor ?? this.redColor,
      purpleColor: purpleColor ?? this.purpleColor,
      searchBar: searchBar ?? this.searchBar,
      blackText: blackText ?? this.blackText,
      lightText: lightText ?? this.lightText,
      audioColor: audioColor ?? this.audioColor,
    );
  }

  @override
  ThemeExtension<CustomThemeExtension> lerp(
      ThemeExtension<CustomThemeExtension>? other, double t) {
    if (other is! CustomThemeExtension) return this;
    return CustomThemeExtension(
      circleImageColor: Color.lerp(circleImageColor, other.circleImageColor, t),
      greyColor: Color.lerp(greyColor, other.greyColor, t),
      blueColor: Color.lerp(blueColor, other.blueColor, t),
      langBtnBgColor: Color.lerp(langBtnBgColor, other.langBtnBgColor, t),
      langBtnHighLightColor:
          Color.lerp(langBtnHighLightColor, other.langBtnHighLightColor, t),
      authAppbarTextColor:
          Color.lerp(authAppbarTextColor, other.authAppbarTextColor, t),
      photoIconBgColor: Color.lerp(photoIconBgColor, other.photoIconBgColor, t),
      photoIconColor: Color.lerp(photoIconColor, other.photoIconColor, t),
      profilePagebg: Color.lerp(profilePagebg, other.profilePagebg, t),
      chatTextBg: Color.lerp(chatTextBg, other.chatTextBg, t),
      chatPageBgColor: Color.lerp(chatPageBgColor, other.chatPageBgColor, t),
      chatPageDoodleColor:
          Color.lerp(chatPageDoodleColor, other.chatPageDoodleColor, t),
      senderChatCardBg: Color.lerp(senderChatCardBg, other.senderChatCardBg, t),
      receiverChatCardBg:
          Color.lerp(receiverChatCardBg, other.receiverChatCardBg, t),
      infoCardBgColor: Color.lerp(infoCardBgColor, other.infoCardBgColor, t),
      infoCardTextColor:
          Color.lerp(infoCardTextColor, other.infoCardTextColor, t),
      textAppBar: Color.lerp(textAppBar, other.textAppBar, t),
      redColor: Color.lerp(redColor, other.redColor, t),
      purpleColor: Color.lerp(purpleColor, other.purpleColor, t),
      searchBar: Color.lerp(searchBar, other.searchBar, t),
      blackText: Color.lerp(blackText, other.blackText, t),
      lightText: Color.lerp(lightText, other.lightText, t),
      audioColor: Color.lerp(audioColor, other.audioColor, t)
    );
  }
}
