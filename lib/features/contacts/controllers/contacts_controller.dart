import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lumina/features/contacts/repository/contacts_repository.dart';
import 'package:lumina/models/user_models.dart';

final contactControllerProvider =
    FutureProvider.family<List<UserModel>, String>((ref, uid) {
  final contactRepository = ref.watch(contactsRepositoryProvider);
  return contactRepository.getAllContacts(uid);
});
