import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lumina/colors/extension/extension_theme.dart';
import 'package:custom_clippers/custom_clippers.dart';
import 'package:flutter/material.dart';
import 'package:lumina/colors/helpers/show_loading_dialog.dart';
import 'package:lumina/common/enum/message_type.dart' as my_type;
import 'package:lumina/features/chat/repository/chat_repository.dart';
import 'package:lumina/features/chat/widgets/ui/text_message_ui.dart';
import 'package:lumina/languages/app_translations.dart';

import '../../../models/message_models.dart';
import 'ui/audio_ui.dart';
import 'ui/image_message_ui.dart';

class MessageCard extends StatelessWidget {
  const MessageCard({
    super.key,
    required this.isSender,
    required this.haveNip,
    required this.message,
    required this.refContainer,
    required this.receiverId,
  });

  final bool isSender;
  final bool haveNip;
  final MessageModel message;
  final WidgetRef refContainer;
  final String receiverId;

  bool isCurrentUserSender(MessageModel message) {
    return message.senderId == FirebaseAuth.instance.currentUser!.uid;
  }

  Future<bool> getMessageIsSeen(MessageModel message, String receiverId) async {
    // Exemple de logique de récupération dans Firestore (à adapter à votre structure de données)
    try {
      final DocumentSnapshot messageDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(receiverId)
          .collection('chats')
          .doc(message
              .senderId) // Assurez-vous que c'est la logique correcte pour récupérer le bon message
          .collection('messages')
          .doc(message.messageId)
          .get();

      if (messageDoc.exists) {
        // Si le document existe, utilisez la valeur isSeen du destinataire
        return messageDoc['isSeen'] ?? false;
      }
    } catch (error) {
      // Gérer les erreurs ici, par exemple, afficher un message à l'utilisateur
      // ignore: avoid_print
      print('Error getting isSeen value: $error');
    }

    // Par défaut, retournez false si la récupération échoue
    return false;
  }

  void _deleteMessageAndCloseDialog(
      MessageModel message, BuildContext context) {
    showLoadingDialog(
      context: context,
      message: AppLocalizations.of(context).translate('deletingMessage'),
      barrierDismissible: false,
    );

    try {
      refContainer.read(chatRepositoryProvider).deleteMessage(
            messageId: message.messageId,
            receiverId: message.receiverId,
          );
    } catch (error) {
      // Gérer l'erreur ici, par exemple, afficher un message à l'utilisateur
      // ignore: avoid_print
      print('Error deleting message: $error');
    } finally {
      Navigator.pop(
          context); // Fermer le dialogue de chargement après la suppression.
    }
  }

  void onclickDeleteMessage(MessageModel message, BuildContext context) async {
    _deleteMessageAndCloseDialog(message, context);
  }

  void showDeleteDialog(BuildContext context, MessageModel message) {
    if (isCurrentUserSender(message)) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(
                AppLocalizations.of(context).translate('deleteDialogTitle')),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(AppLocalizations.of(context).translate('cancel')),
              ),
              TextButton(
                onPressed: () {
                  onclickDeleteMessage(message, context);
                  Navigator.pop(context);
                },
                child: Text(AppLocalizations.of(context).translate('delete')),
              ),
            ],
          );
        },
      );
    } else {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(AppLocalizations.of(context)
                .translate('unauthorizedActionTitle')),
            content: Text(AppLocalizations.of(context)
                .translate('unauthorizedActionContent')),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(AppLocalizations.of(context).translate('ok')),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Pas de changement basé sur isShortMessage donc on l'enlève
    final ThemeData theme = Theme.of(context);
    final bool isCurrentUser = isCurrentUserSender(message);

    return GestureDetector(
      onLongPress: () => showDeleteDialog(context, message),
      child: Align(
        alignment: isCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          margin: EdgeInsets.only(
            top: 4,
            bottom: 4,
            left: isCurrentUser ? 60 : 15,
            right: isCurrentUser ? 15 : 60,
          ),
          child: ClipPath(
            clipper: haveNip
                ? UpperNipMessageClipperTwo(
                    isCurrentUser ? MessageType.send : MessageType.receive,
                    nipWidth: 8,
                    nipHeight: 10,
                    bubbleRadius: 12,
                  )
                : null,
            child: Container(
              padding: const EdgeInsets.symmetric(
                vertical: 10,
                horizontal: 14,
              ),
              decoration: BoxDecoration(
                color: isSender
                    ? theme.extension<CustomThemeExtension>()!.senderChatCardBg
                    : theme
                        .extension<CustomThemeExtension>()!
                        .receiverChatCardBg,
                borderRadius: haveNip ? null : BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(
                        theme.brightness == Brightness.dark ? 0.2 : 0.4),
                    blurRadius: 2,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: FutureBuilder<bool>(
                future: getMessageIsSeen(message, receiverId),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    return message.type == my_type.MessageType.audio
                        ? AudioMessage(
                            audioUrl: message.textMessage,
                            timeSent: message.timeSent,
                            isHeard: snapshot.data ?? false,
                            senderId: message.senderId,
                          )
                        : message.type == my_type.MessageType.image ||
                                message.type == my_type.MessageType.video
                            ? ImageMessage(
                                imageUrls: message.imageUrls,
                                caption: message.textMessage,
                                timeSent: message.timeSent,
                                isSeen: snapshot.data ?? false,
                                senderId: message.senderId,
                              )
                            : TextMessage(
                                text: message.textMessage,
                                timeSent: message.timeSent,
                                isSeen: snapshot.data ?? false,
                                senderId: message.senderId,
                              );
                  } else {
                    return message.type == my_type.MessageType.audio
                        ? AudioMessage(
                            audioUrl: message.textMessage,
                            timeSent: message.timeSent,
                            isHeard: false,
                            senderId: message.senderId,
                          )
                        : message.type == my_type.MessageType.image ||
                                message.type == my_type.MessageType.video
                            ? ImageMessage(
                                imageUrls: message.imageUrls,
                                caption: message.textMessage,
                                timeSent: message.timeSent,
                                isSeen: false,
                                senderId: message.senderId,
                              )
                            : TextMessage(
                                text: message.textMessage,
                                timeSent: message.timeSent,
                                isSeen: false,
                                senderId: message.senderId,
                              );
                  }
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
