import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lumina/colors/coloors.dart';
import 'package:lumina/colors/extension/extension_theme.dart';
import 'package:lumina/languages/app_translations.dart';
import 'package:lumina/models/last_message_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../features/chat/controllers/chat_controller.dart';
import '../../main.dart';
import '../../models/user_models.dart';
import '../../routes/routes_pages.dart';
import '../widgets/shimmer_widget.dart';

class ChatHomePage extends ConsumerWidget {
  const ChatHomePage({super.key});

  String _getMessageTimeString(int timestamp, BuildContext context) {
    DateTime now = DateTime.now();
    DateTime messageDate = DateTime.fromMillisecondsSinceEpoch(timestamp);
    DateTime today = DateTime(now.year, now.month, now.day);
    DateTime yesterday = today.subtract(const Duration(days: 1));
    DateTime aWeekAgo = today.subtract(const Duration(days: 7));
    String locale = Localizations.localeOf(context).languageCode;

    if (messageDate.isAfter(today)) {
      // Si le message a été envoyé aujourd'hui, retourne l'heure.
      return DateFormat('HH:mm', locale).format(messageDate);
    } else if (messageDate.isAfter(yesterday)) {
      // Si le message a été envoyé hier, retourne 'Hier'.
      return AppLocalizations.of(context).translate('yesterday');
    } else if (messageDate.isAfter(aWeekAgo)) {
      // Si le message a été envoyé au cours des 7 derniers jours, retourne le jour de la semaine.
      return DateFormat('EEEE', locale).format(messageDate);
    } else {
      // Pour les messages plus anciens, retourne la date complète.
      return DateFormat('dd/MM/yyyy', locale).format(messageDate);
    }
  }

  Future<bool> _getIsSeenValue(
      String messageId, String receiverId, WidgetRef ref) async {
    return await ref
        .read(chatControllerProvider)
        .getMessageIsSeen(messageId, receiverId);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUserUid = FirebaseAuth.instance.currentUser?.uid;
    Future<void> loadData() async {
      ref.watch(chatControllerProvider).getAllLastMessageList();
    }

    // Appel de la fonction asynchrone pour précharger les données en arrière-plan
    loadData();
    return Scaffold(
      appBar: AppBar(
        // ignore: deprecated_member_use
        backgroundColor: Theme.of(context).colorScheme.background,
        title: Text(
          AppLocalizations.of(context).translate('messages'),
          style: const TextStyle(
            color: Coolors.blueDark,
            fontSize: 20,
            //fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: StreamBuilder<List<LastMessageModel>>(
        stream: ref.watch(chatControllerProvider).getAllLastMessageList(),
        builder: (_, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            final themeMode = ref.watch(themeModeProvider);
            return CustomShimmerWidget(themeMode: themeMode);
          }

          if (snapshot.hasError) {
            // ignore: avoid_print
            print('Error loading messages: ${snapshot.error}');
            return Center(
              child: Text(AppLocalizations.of(context)
                  .translate('errorLoadingMessages')),
            );
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            // Affichez un message si la liste est vide ou non disponible
            return Center(
              child: Text(AppLocalizations.of(context).translate('noMessages')),
            );
          }

          // Trier la liste des messages par timestamp croissant avant d'afficher
          List<LastMessageModel> sortedMessages = snapshot.data!;
          sortedMessages.sort((a, b) => b.timeSent.compareTo(a.timeSent));

          return ListView.builder(
            itemCount: sortedMessages.length,
            shrinkWrap: true,
            itemBuilder: (context, index) {
              final lastMessageData = sortedMessages[index];
              // ignore: avoid_print
              print('currentUserUid: $currentUserUid');
              // ignore: avoid_print
              print('lastMessageData.senderId: ${lastMessageData.senderId}');
              return FutureBuilder<bool>(
                future: _getIsSeenValue(
                  lastMessageData.lastMessageId,
                  lastMessageData.contactId,
                  ref,
                ),
                builder: (context, snapshot) {
                  bool isSeen = snapshot.data ?? false;

                  return ListTile(
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        Routes.chat,
                        arguments: UserModel(
                          lastSeen: 0,
                          email: '',
                          username: lastMessageData.username,
                          uid: lastMessageData.contactId,
                          profileImageUrl: lastMessageData.profileImageUrl,
                          active: true,
                          phoneNumber: '0',
                          userType: '',
                          isConcessionary: '',
                        ),
                      );
                    },
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(lastMessageData.username),
                        Text(
                          _getMessageTimeString(
                            lastMessageData.timeSent.millisecondsSinceEpoch,
                            context,
                          ),
                          style: TextStyle(
                            fontSize: 13,
                            color: context.theme.greyColor,
                          ),
                        )
                      ],
                    ),
                    subtitle: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            lastMessageData.lastMessage,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: context.theme.greyColor),
                          ),
                        ),
                        if (lastMessageData.unreadCount > 0)
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Coolors.greenDark,
                            ),
                            child: Text(
                              '${lastMessageData.unreadCount}',
                              style: TextStyle(
                                color: context.theme.lightText,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        // Affichez l'icône uniquement si l'utilisateur est l'expéditeur
                        lastMessageData.unreadCount > 0
                            ? (const SizedBox.shrink())
                            : (isSeen
                                ? const Icon(Icons.done_all,
                                    color: Coolors.blueDark)
                                : const Icon(Icons.done, color: Colors.grey)),
                      ],
                    ),
                    leading: CircleAvatar(
                      radius: 24,
                      backgroundColor:
                          Colors.grey[200], // Couleur de fond pour l'icône
                      backgroundImage:
                          lastMessageData.profileImageUrl.isNotEmpty
                              ? CachedNetworkImageProvider(
                                  lastMessageData.profileImageUrl)
                              : null,
                      child: lastMessageData.profileImageUrl.isEmpty
                          ? const Icon(
                              Icons.person,
                              size: 24,
                              color: Colors.grey,
                            )
                          : null,
                    ),
                  );
                
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, Routes.contact);
        },
        child: const Icon(
          Icons.chat,
        ),
      ),
    );
  }
}
