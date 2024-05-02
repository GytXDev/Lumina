import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lumina/colors/coloors.dart';
import 'package:lumina/home_section/page/calls_page.dart';
import 'package:lumina/home_section/page/cars_page.dart';
import 'package:lumina/home_section/page/chat_page.dart';
import 'package:lumina/home_section/page/profil_page.dart';
import 'package:lumina/home_section/widgets/bar_navigation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lumina/home_section/widgets/cars_post.dart';
import '../features/auth/controllers/auth_controller.dart';
import '../models/user_models.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  late Timer timer;

  updateUserPresence() {
    ref.read(authControllerProvider).updateUserPresence();
  }

  @override
  void initState() {
    updateUserPresence();
    timer = Timer.periodic(
      const Duration(minutes: 1),
      (timer) => setState(() {}),
    );
    super.initState();
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  int _currentIndex = 0;

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          FutureBuilder<Widget>(
            future: _getPage(_currentIndex),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: Coolors.blueDark,
                  ),
                );
              }
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }
              return snapshot.data ?? Container();
            },
          ),
        ],
      ),
      bottomNavigationBar: MyBottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
      ),
    );
  }

  Future<Widget> _getPage(int index) async {
    switch (index) {
      case 0:
        return const CarsPage();
      case 1:
        return const ChatHomePage();
      case 2:
        return Container();
      case 3:
        return const CallHomePage();
      case 4:
        return _buildUserProfilePage(); // Appel à la méthode pour la page de profil utilisateur
      default:
        return Container();
    }
  }

  FutureBuilder<UserModel?> _buildUserProfilePage() {
    return FutureBuilder<UserModel?>(
      future: getCurrentUser(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError || snapshot.data == null) {
          return Container(); // Ou un widget d'erreur approprié
        }

        UserModel user = snapshot.data!;
        return FutureBuilder<UserModel>(
          future: getUserData(user.uid),
          builder: (context, userSnapshot) {
            if (userSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (userSnapshot.hasError || userSnapshot.data == null) {
              return Container(); // Ou un widget d'erreur approprié
            }

            UserModel userData = userSnapshot.data!;
            return UserProfiles(user: userData);
          },
        );
      },
    );
  }

  Future<UserModel> getUserData(String uid) async {
    DocumentSnapshot<Map<String, dynamic>> userDoc =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();
    return UserModel.fromMap(userDoc.data()!);
  }
}
