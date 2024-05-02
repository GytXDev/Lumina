import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lumina/colors/coloors.dart';
import 'package:lumina/colors/extension/extension_theme.dart';
import 'package:lumina/languages/app_translations.dart';
import '../../../models/user_models.dart';
import 'calling_page.dart';

class NewCallPage extends StatefulWidget {
  const NewCallPage({super.key});

  @override
  State<NewCallPage> createState() => _NewCallPageState();
}

class _NewCallPageState extends State<NewCallPage> {
  UserModel? currentUser;
  List<UserModel> users = [];
  List<UserModel> filteredUsers = [];
  final searchController = TextEditingController();
  String? currentUserId = FirebaseAuth.instance.currentUser?.uid;

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  @override
  void dispose() {
    super.dispose();
  }

  _fetchUsers() async {
    if (currentUserId == null) return;
    final usersCollection = FirebaseFirestore.instance.collection('users');

    final currentUserDoc = await usersCollection.doc(currentUserId!).get();
    currentUser =
        UserModel.fromMap(currentUserDoc.data() as Map<String, dynamic>);

    final usersDocs = await usersCollection.get();
    List<UserModel> tempUsers =
        usersDocs.docs.map((doc) => UserModel.fromMap(doc.data())).toList();

    if (currentUser?.userType == 'user') {
      tempUsers = tempUsers.where((user) => user.userType == 'admin').toList();
    }

    setState(() {
      users = tempUsers;
      filteredUsers = List.from(users);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context).translate('newCall'),
          style: const TextStyle(
            fontSize: 18,
            fontFamily: 'Playfair Display',
          ),
        ),
      ),
      body: Column(
        children: [
          Container(
            margin:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
            decoration: BoxDecoration(
              color: context.theme.searchBar,
              borderRadius: BorderRadius.circular(30.0), // Coins très arrondis
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  spreadRadius: 0,
                  blurRadius: 10,
                  offset: const Offset(0, 4), // Ombre douce
                ),
              ],
            ),
            child: TextFormField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: AppLocalizations.of(context).translate('search'),
                hintStyle: const TextStyle(
                    color: Coolors.greyDark), // Style du texte indicatif
                border: InputBorder.none, // Suppression de la bordure
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20.0, vertical: 15.0), // Padding interne
                prefixIcon: const Icon(Icons.search,
                    color: Coolors.blueDark), // Icône de recherche
                suffixIcon: searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Coolors.blueDark),
                        onPressed: () {
                          searchController.clear();
                          // Mise à jour de l'UI après la suppression du texte
                          setState(() {});
                        },
                      )
                    : null,
                filled: true,
                fillColor:
                    Colors.transparent, // Fond de remplissage transparent
              ),
              onChanged: (value) {
                setState(() {
                  filteredUsers = users
                      .where((user) => user.username
                          .toLowerCase()
                          .contains(value.toLowerCase()))
                      .toList();
                });
              },
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredUsers.length,
              itemBuilder: (context, index) {
                var user = filteredUsers[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(user.profileImageUrl),
                  ),
                  title: Text(
                    user.username,
                  ),
                  onTap: () {
                    if (user.username.isNotEmpty) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CallingPage(
                            calleeName: user.username,
                            calleeAvatar: user.profileImageUrl,
                            calleePhone: user.phoneNumber,
                            calleeUid: user.uid,
                            callerName: currentUser!.username,
                            callerPhone: currentUser!.phoneNumber,
                            callerUid: currentUser!.uid,
                            callerAvatar: currentUser!.profileImageUrl,
                          ),
                        ),
                      );
                    }
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
