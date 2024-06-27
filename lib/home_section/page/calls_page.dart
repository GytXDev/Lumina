import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lumina/home_section/widgets/history_calls.dart';
import 'package:lumina/features/calls/pages/news_calls.dart';
import 'package:lumina/languages/app_translations.dart';
import 'package:lumina/models/user_models.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CallHomePage extends StatefulWidget {
  const CallHomePage({super.key});

  @override
  State<CallHomePage> createState() => _CallHomePageState();
}

class _CallHomePageState extends State<CallHomePage> {
  final currentUserId = FirebaseAuth.instance.currentUser?.uid;
  UserModel? currentUser;

  @override
  void initState() {
    super.initState();
    fetchCurrentUser();
  }

  Future<void> fetchCurrentUser() async {
    if (currentUserId != null) {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUserId)
          .get();

      // Check if the widget is still mounted before calling setState
      if (mounted) {
        setState(() {
          currentUser =
              UserModel.fromMap(userDoc.data() as Map<String, dynamic>);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context).translate('calls'),
          style: const TextStyle(
            fontSize: 20,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.add_call,
              color: Colors.white,
            ),
            onPressed: () {
              //Lancer un nouvel appel
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const NewCallPage()),
              );
            },
          ),
        ],
      ),
      body: const CallHistoryPage(),
    );
  }
}
