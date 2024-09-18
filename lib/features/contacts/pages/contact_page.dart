import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lumina/colors/coloors.dart';
import 'package:lumina/colors/extension/extension_theme.dart';
import 'package:lumina/features/contacts/widgets/contact_card.dart';
import 'package:lumina/languages/app_translations.dart';
import 'package:lumina/routes/routes_pages.dart';

import '../../../models/user_models.dart';
import '../../auth/repository/auth_repository.dart';
import '../../auth/widgets/custom_icon_button.dart';
import '../controllers/contacts_controller.dart';

final userTypeProvider = FutureProvider<String?>((ref) async {
  final authRepository = ref.read(authRepositoryProvider);
  return await authRepository.getCurrentUserType();
});

final _searchController = TextEditingController();

class ContactPage extends ConsumerWidget {
  const ContactPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userTypeAsyncValue = ref.watch(userTypeProvider);

    // Récupérer l'uid depuis Firebase Auth
    final authRepository = ref.read(authRepositoryProvider);
    final user = authRepository.getCurrentUser();
    final uid =
        user?.uid ?? ''; // Utiliser une chaîne vide comme valeur par défaut
    final allContactsAsyncValue = ref.watch(contactControllerProvider(uid));

    // Filtrer les contacts en fonction de la recherche
    // ignore: no_leading_underscores_for_local_identifiers
    List<UserModel> _filteredContacts(
        List<UserModel> contacts, String searchQuery) {
      if (searchQuery.trim().isEmpty) {
        return contacts;
      }
      return contacts
          .where((contact) => contact.username
              .toLowerCase()
              .contains(searchQuery.toLowerCase()))
          .toList();
    }

    return Scaffold(
      appBar: AppBar(
        // ignore: deprecated_member_use
        backgroundColor: Theme.of(context).colorScheme.background,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            color: Coolors.greyDark,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context).translate('selectContact'),
              style: const TextStyle(
                  color: Coolors.blueDark, fontFamily: 'Playfair Display'),
            ),
            const SizedBox(height: 3),
            userTypeAsyncValue.when(
              data: (userType) {
                if (userType == 'admin') {
                  return allContactsAsyncValue.when(
                    data: (allContacts) => Text(
                      "${allContacts.length} ${AppLocalizations.of(context).translate('contact')}${allContacts.length == 1 ? '' : 's'}",
                      style: const TextStyle(
                          fontSize: 13, color: Coolors.greyDark),
                    ),
                    error: (e, t) => const SizedBox(),
                    loading: () => const Text(
                      'Counting...',
                      style: TextStyle(fontSize: 12, color: Colors.black),
                    ),
                  );
                } else {
                  return const SizedBox.shrink();
                }
              },
              loading: () => const SizedBox.shrink(),
              error: (e, t) => const SizedBox.shrink(),
            ),
          ],
        ),
        actions: [
          CustomIconButton(onTap: () {}, icon: Icons.more_vert),
        ],
      ),
      body: userTypeAsyncValue.when(
        data: (userType) {
          return allContactsAsyncValue.when(
            data: (allContacts) {
              final searchQuery = _searchController.text;
              List<UserModel> firebaseContacts =
                  _filteredContacts(allContacts, searchQuery);

              if (userType == 'user') {
                final currentUserID = user?.uid;
                firebaseContacts = firebaseContacts
                    .where((contact) =>
                        contact.userType == 'admin' &&
                        contact.uid != currentUserID)
                    .toList();
              }

              if (firebaseContacts.isEmpty) {
                return Center(
                    child: Text(AppLocalizations.of(context)
                        .translate('noUsersFound')));
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Barre de recherche transparente avec une marge
                  Container(
                    margin: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 14.0),
                    decoration: BoxDecoration(
                      color: context.theme.searchBar,
                      borderRadius: BorderRadius.circular(30.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          spreadRadius: 0,
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: TextFormField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText:
                            AppLocalizations.of(context).translate('search'),
                        hintStyle: const TextStyle(color: Coolors.greyDark),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20.0, vertical: 15.0),
                        prefixIcon:
                            const Icon(Icons.search, color: Coolors.blueDark),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear,
                                    color: Coolors.blueDark),
                                onPressed: () {
                                  _searchController.clear();
                                },
                              )
                            : null,
                        filled: true,
                        fillColor: Colors.transparent,
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: firebaseContacts.length,
                      itemBuilder: (context, index) {
                        UserModel contact = firebaseContacts[index];
                        return ContactCard(
                          onTap: () {
                            Navigator.of(context).pushNamed(
                              Routes.chat,
                              arguments: contact,
                            );
                          },
                          contactSource: contact,
                        );
                      },
                    ),
                  ),
                ],
              );
            },
            loading: () => Center(
              child: CircularProgressIndicator(
                color: context.theme.authAppbarTextColor,
              ),
            ),
            error: (err, stack) => Center(child: Text("Erreur: $err")),
          );
        },
        loading: () => Center(
          child: CircularProgressIndicator(
            color: context.theme.authAppbarTextColor,
          ),
        ),
        error: (err, stack) => Center(child: Text("Erreur: $err")),
      ),
    );
  }
}
