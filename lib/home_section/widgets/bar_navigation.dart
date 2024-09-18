import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lumina/colors/extension/extension_theme.dart';
import 'package:lumina/features/cars/pages/add_cars.dart';
import 'package:flutter/material.dart';
import 'package:lumina/languages/app_translations.dart';

import '../../colors/coloors.dart';
import '../../features/chat/controllers/chat_controller.dart';

class MyBottomNavigationBar extends StatefulWidget {
  final int currentIndex;
  final Function(int) onTap;

  const MyBottomNavigationBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  State<MyBottomNavigationBar> createState() => _MyBottomNavigationBarState();
}

class _MyBottomNavigationBarState extends State<MyBottomNavigationBar> {
  bool isFloatingBarOpen = false;
  final unreadMessageProvider = FutureProvider<bool>((ref) async {
    final chatController = ref.read(chatControllerProvider);

    // Assurez-vous que l'utilisateur est authentifié avant d'extraire l'ID
    final userId = FirebaseAuth.instance.currentUser?.uid ?? '';

    return chatController.checkForUnreadMessages(userId);
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.topCenter,
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.0),
          ),
          margin: const EdgeInsets.symmetric(horizontal: 2.0),
          child: BottomNavigationBar(
            unselectedItemColor: Colors.white,
            selectedItemColor: Coolors.blueDark,
            currentIndex: widget.currentIndex,
            onTap: (index) {
              if (index == 2) {
                toggleFloatingBar();
              } else {
                widget.onTap(index);
              }
            },
            items: [
              BottomNavigationBarItem(
                icon: const Icon(
                  Icons.home,
                  color: Coolors.blueDark,
                ),
                label: AppLocalizations.of(context).translate('home'),
              ),
              BottomNavigationBarItem(
                icon: Consumer(
                  builder: (context, ref, child) {
                    final userId = FirebaseAuth.instance.currentUser?.uid ?? '';
                    final chatController = ref.watch(chatControllerProvider);

                    return FutureBuilder<bool>(
                      future: chatController.checkForUnreadMessages(userId),
                      builder: (context, snapshot) {
                        bool hasUnreadMessages = snapshot.data ?? false;

                        return Stack(
                          children: [
                            const Icon(
                              Icons.chat_bubble,
                              color: Coolors.blueDark,
                            ),
                            if (hasUnreadMessages)
                              Positioned(
                                right: 0,
                                top: 0,
                                child: Container(
                                  padding: const EdgeInsets.all(1),
                                  decoration: BoxDecoration(
                                    color: Colors.red,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  constraints: const BoxConstraints(
                                    minWidth: 12,
                                    minHeight: 12,
                                  ),
                                ),
                              ),
                          ],
                        );
                      },
                    );
                  },
                ),
                label: AppLocalizations.of(context).translate('chat'),
              ),
              BottomNavigationBarItem(
                icon: const Icon(
                  Icons.add_circle_outline,
                  color: Coolors.blueDark,
                ),
                label: AppLocalizations.of(context).translate('barNew'),
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.call, color: Coolors.blueDark),
                label: AppLocalizations.of(context).translate('barCalls'),
              ),
              BottomNavigationBarItem(
                icon: const Icon(
                  Icons.person,
                  color: Coolors.blueDark,
                ),
                label: AppLocalizations.of(context).translate('profile'),
              ),
            ],
          ),
        ),
        buildFloatingBar(), // Utilisez la fonction sans passer de paramètres
      ],
    );
  }

  void toggleFloatingBar() {
    setState(() {
      isFloatingBarOpen = !isFloatingBarOpen;
    });
  }

  //widget pour les post
  Widget buildFloatingBar() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: isFloatingBarOpen ? 200.0 : 0.0,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20.0),
          topRight: Radius.circular(20.0),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: ListView(
        padding: const EdgeInsets.all(8.0),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: Icon(
                  Icons.close,
                  color: context.theme.blackText,
                ),
                onPressed: () {
                  toggleFloatingBar(); // Fermeture de la barre flottante
                },
              ),
              Flexible(
                child: Text(
                  AppLocalizations.of(context).translate('postCarOfferNow'),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13.0,
                  ),
                  overflow: TextOverflow
                      .ellipsis, // Pour éviter le débordement du texte
                ),
              ),
              const SizedBox(height: 20),
              IconButton(
                icon: Icon(
                  Icons.directions_car,
                  color: context.theme.blackText,
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const AddCarsPage()),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
