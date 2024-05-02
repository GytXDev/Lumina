import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/user_models.dart';

final contactsRepositoryProvider = Provider((ref) {
  return ContactsRepository(firestore: FirebaseFirestore.instance);
});

class ContactsRepository {
  final FirebaseFirestore firestore;

  ContactsRepository({required this.firestore});

  Future<List<UserModel>> getAllContacts(String uid) async {
    List<UserModel> firebaseContacts = [];

    try {
      final userCollection = await firestore.collection('users').get();

      for (var firebaseContactData in userCollection.docs) {
        var firebaseContact = UserModel.fromMap(firebaseContactData.data());
        firebaseContacts.add(firebaseContact);
      }
    } catch (e) {
      log(e.toString());
    }

    return firebaseContacts;
  }
}
