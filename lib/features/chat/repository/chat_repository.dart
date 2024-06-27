// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lumina/colors/helper_dialogue.dart';
import 'package:lumina/common/enum/message_type.dart';
import 'package:lumina/features/auth/repository/firebase_storage_repository.dart';
import 'package:lumina/models/last_message_model.dart';
import 'package:lumina/models/message_models.dart';
import 'package:lumina/models/user_models.dart';
import 'package:uuid/uuid.dart';

final chatRepositoryProvider = Provider((ref) {
  return ChatRepository(
    firestore: FirebaseFirestore.instance,
    auth: FirebaseAuth.instance,
  );
});

class ChatRepository {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;

  ChatRepository({required this.firestore, required this.auth});

  Future<bool> hasUnreadMessages(String userId) async {
    final snapshot = await firestore
        .collection('users')
        .doc(userId)
        .collection('chats')
        .get();

    // ignore: avoid_print
    print('Query executed for user ID: $userId');

    bool hasUnreadMessages = false;

    for (var chatDoc in snapshot.docs) {
      final chatId = chatDoc.id;

      // condition pour exclure les messages de l'utilisateur lui-même
      if (chatId != userId) {
        final messagesSnapshot = await firestore
            .collection('users')
            .doc(userId)
            .collection('chats')
            .doc(chatId)
            .collection('messages')
            .where('isSeen', isEqualTo: false)
            .limit(1)
            .get();

        if (messagesSnapshot.docs.isNotEmpty) {
          // ignore: avoid_print
          print('Unread messages found for user ID: $userId in chat: $chatId');
          hasUnreadMessages = true;
        }
      }
    }

    if (!hasUnreadMessages) {
      // ignore: avoid_print
      print('No unread messages for user ID: $userId');
    }

    return hasUnreadMessages;
  }

  Future<void> markMessagesAsSeen(String senderId, String receiverId) async {
    // Mettez en œuvre la logique pour marquer les messages comme lus dans la base de données
    // Utilisez senderId et receiverId pour identifier la conversation

    // Exemple de code pour mettre à jour les messages dans Cloud Firestore
    final querySnapshot = await firestore
        .collection('users')
        .doc(senderId)
        .collection('chats')
        .doc(receiverId)
        .collection('messages')
        .where('isSeen', isEqualTo: false)
        .get();

    final messagesToUpdate = querySnapshot.docs;
    final numberOfMessagesToUpdate = messagesToUpdate.length;

    // Affichez le nombre de messages marqués comme isSeen à true
    // ignore: avoid_print
    print(
        'Nombre de messages à marquer comme isSeen à true : $numberOfMessagesToUpdate');

    for (var doc in messagesToUpdate) {
      doc.reference.update({'isSeen': true});
    }
  }

  // méthode pour supprimer un message
  void deleteMessage({
    required String messageId,
    required String receiverId,
  }) async {
    try {
      // Supprimer du côté de l'expéditeur
      await firestore
          .collection('users')
          .doc(auth.currentUser!.uid)
          .collection('chats')
          .doc(receiverId)
          .collection('messages')
          .doc(messageId)
          .delete();

      // Supprimer du côté du récepteur
      await firestore
          .collection('users')
          .doc(receiverId)
          .collection('chats')
          .doc(auth.currentUser!.uid)
          .collection('messages')
          .doc(messageId)
          .delete();

      // Vérifier si c'était le dernier message
      final isLastMessage = await isLastMessageInConversation(
          auth.currentUser!.uid, receiverId, messageId);

      // Si c'était le dernier message, mettre à jour la dernière conversation
      if (isLastMessage) {
        await saveAsLastMessageAfterDelete(auth.currentUser!.uid, receiverId);
      }
    } catch (e) {
      // Gérer les erreurs, par exemple afficher une boîte de dialogue d'erreur
      // ignore: avoid_print
      print('Erreur lors de la suppression du message: $e');
    }
  }

  // Vérifier si le message supprimé était le dernier message dans la conversation
  Future<bool> isLastMessageInConversation(
      String senderId, String receiverId, String messageId) async {
    final messages = await firestore
        .collection('users')
        .doc(senderId)
        .collection('chats')
        .doc(receiverId)
        .collection('messages')
        .orderBy('timeSent', descending: true)
        .get();

    // Si la collection de messages est vide, le message était le dernier
    if (messages.docs.isEmpty) {
      return true;
    }

    // Si le premier document dans la collection est le message supprimé, c'était le dernier
    return messages.docs.first.id == messageId;
  }

  Future<void> saveAsLastMessageAfterDelete(
      String senderId, String receiverId) async {
    try {
      // Récupérer tous les messages dans l'ordre décroissant
      final messages = await firestore
          .collection('users')
          .doc(senderId)
          .collection('chats')
          .doc(receiverId)
          .collection('messages')
          .orderBy('timeSent', descending: true)
          .get();

      // Vérifier s'il y a un message autre que celui qui vient d'être supprimé
      if (messages.docs.length > 1) {
        final newLastMessage = messages.docs[1].data();

        // Mettre à jour le dernier message avec les données du nouvel avant-dernier message
        await firestore
            .collection('users')
            .doc(senderId)
            .collection('chats')
            .doc(receiverId)
            .set(LastMessageModel.fromMap(newLastMessage).toMap());
      } else {
        // S'il n'y a pas d'autre message, supprimer complètement la dernière conversation
        await firestore
            .collection('users')
            .doc(senderId)
            .collection('chats')
            .doc(receiverId)
            .delete();
      }
    } catch (e) {
      // Gérer les erreurs, par exemple afficher une boîte de dialogue d'erreur
      // ignore: avoid_print
      print(
          'Erreur lors de la mise à jour du dernier message après la suppression: $e');
    }
  }

  Future<void> sendImageMessage({
    required List<File> images,
    required BuildContext context,
    required String receiverId,
    required UserModel senderData,
    required Ref ref,
    String? caption,
    required MessageType messageType,
  }) async {
    try {
      final timeSent = DateTime.now();
      List<String> imageUrls = [];
      final messageId = const Uuid().v1();

      for (File imageFile in images) {
        String extension = imageFile.path.split('.').last;
        String imageName =
            'chats/images/${senderData.uid}/$receiverId/$messageId/${DateTime.now().millisecondsSinceEpoch}.$extension';

        String imageUrl = await FirebaseStorageRepository(
                firebaseStorage: FirebaseStorage.instance)
            .storeFileToFirebase(imageName, imageFile);

        imageUrls.add(imageUrl);
      }

      if (imageUrls.isNotEmpty) {
        final userMap =
            await firestore.collection('users').doc(receiverId).get();
        final receiverUserData = UserModel.fromMap(userMap.data()!);

        // Définir le dernier message pour les images
        const String lastMessage = '📸 Photo message';

        // Sauvegardez dans la collection de messages
        saveToMessageCollection(
          receiverId: receiverId,
          textMessage:
              caption ?? '', // Utilisez caption pour le texte du message
          imageUrls: imageUrls, // Passez la liste des URLs d'images
          timeSent: timeSent,
          textMessageId: const Uuid().v1(),
          senderUsername: senderData.username,
          receiverUsername: receiverUserData.username,
          messageType: MessageType.image,
        );

        // Enregistrez comme dernier message
        saveAsLastMessage(
          senderUserData: senderData,
          receiverUserData: receiverUserData,
          lastMessage: lastMessage,
          timeSent: timeSent,
          receiverId: receiverId,
          lastMessageId: messageId,
          senderId: senderData.uid,
        );
      }
    } catch (e) {
      showAlertDialog(context: context, message: e.toString());
    }
  }

  void sendFileMessage({
    required var file,
    required BuildContext context,
    required String receiverId,
    required UserModel senderData,
    required Ref ref,
    required MessageType messageType,
    String? caption,
  }) async {
    try {
      final timeSent = DateTime.now();
      final messageId = const Uuid().v1();

      // Stocker le fichier dans Firebase et récupérer son URL
      final fileUrl =
          await ref.read(firebaseStorageRepositoryProvider).storeFileToFirebase(
                'chats/${messageType.type}/${senderData.uid}/$receiverId/$messageId',
                file,
              );

      final userMap = await firestore.collection('users').doc(receiverId).get();
      final receiverUserData = UserModel.fromMap(userMap.data()!);

      String lastMessage;
      switch (messageType) {
        case MessageType.image:
          lastMessage = '📸 Photo message';
          break;
        case MessageType.audio:
          lastMessage = '🎵 Audio message ';
          break;
        case MessageType.video:
          lastMessage = '🎥 Video message';
          break;
        case MessageType.gif:
          lastMessage = '🎉 GIF message';
          break;
        default:
          lastMessage = '📦 Unknown message type';
          break;
      }

      saveToMessageCollection(
        receiverId: receiverId,
        textMessage: fileUrl, // Utilisez l'URL du fichier stocké
        timeSent: timeSent,
        textMessageId: messageId,
        senderUsername: senderData.username,
        receiverUsername: receiverUserData.username,
        messageType: messageType, imageUrls: [],
      );

      saveAsLastMessage(
        senderUserData: senderData,
        receiverUserData: receiverUserData,
        lastMessage: lastMessage,
        timeSent: timeSent,
        receiverId: receiverId,
        lastMessageId: messageId,
        senderId: senderData.uid,
      );
    } catch (e) {
      showAlertDialog(context: context, message: e.toString());
    }
  }

  Stream<List<MessageModel>> getAllOneToOneMessage(String receiverId) {
    return firestore
        .collection('users')
        .doc(auth.currentUser!.uid)
        .collection('chats')
        .doc(receiverId)
        .collection('messages')
        .orderBy('timeSent')
        .snapshots()
        .map((event) {
      List<MessageModel> messages = [];
      for (var message in event.docs) {
        messages.add(MessageModel.fromMap(message.data()));
      }
      return messages;
    });
  }

  Stream<List<LastMessageModel>> getAllLastMessageList() {
    return firestore
        .collection('users')
        .doc(auth.currentUser!.uid)
        .collection('chats')
        .snapshots()
        .asyncMap((event) async {
      List<LastMessageModel> contacts = [];

      for (var document in event.docs) {
        final lastMessage = LastMessageModel.fromMap(document.data());

        // Ajoutez la logique pour récupérer le nombre de messages non lus
        final messagesSnapshot = await firestore
            .collection('users')
            .doc(auth.currentUser!.uid)
            .collection('chats')
            .doc(lastMessage.contactId)
            .collection('messages')
            .where('senderId', isEqualTo: lastMessage.contactId)
            .where('isSeen', isEqualTo: false)
            .get();

        int unreadCount = messagesSnapshot.docs.length;

        final userData = await firestore
            .collection('users')
            .doc(lastMessage.contactId)
            .get();
        final user = UserModel.fromMap(userData.data()!);

        contacts.add(
          LastMessageModel(
            username: user.username,
            profileImageUrl: user.profileImageUrl,
            contactId: lastMessage.contactId,
            timeSent: lastMessage.timeSent,
            lastMessage: lastMessage.lastMessage,
            unreadCount: unreadCount,
            lastMessageId: lastMessage.lastMessageId,
            senderId: auth.currentUser!.uid,
          ),
        );
      }

      return contacts;
    });
  }

  //récuperer la valeur isSeen
  Future<bool> getMessageIsSeen(String messageId, String receiverId) async {
    try {
      final QuerySnapshot querySnapshot = await firestore
          .collection('users')
          .doc(receiverId)
          .collection('chats')
          .doc(auth.currentUser!.uid)
          .collection('messages')
          .where('messageId', isEqualTo: messageId)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        return querySnapshot.docs.first['isSeen'] ?? false;
      } else {
        return false;
      }
    } catch (error) {
      // ignore: avoid_print
      print('Error getting isSeen value: $error');
      return false;
    }
  }

  void sendTextMessage({
    required BuildContext context,
    required String textMessage,
    required String receiverId,
    required UserModel senderData,
  }) async {
    try {
      final timeSent = DateTime.now();
      final receiverDataMap =
          await firestore.collection('users').doc(receiverId).get();
      final receiverData = UserModel.fromMap(receiverDataMap.data()!);
      final textMessageId = const Uuid().v1();

      saveToMessageCollection(
        receiverId: receiverId,
        textMessage: textMessage,
        timeSent: timeSent,
        imageUrls: [],
        textMessageId: textMessageId,
        senderUsername: senderData.username,
        receiverUsername: receiverData.username,
        messageType: MessageType.text,
      );

      saveAsLastMessage(
        senderUserData: senderData,
        receiverUserData: receiverData,
        lastMessage: textMessage,
        timeSent: timeSent,
        receiverId: receiverId,
        lastMessageId: textMessageId,
        senderId: senderData.uid,
      );
    } catch (e) {
      showAlertDialog(context: context, message: e.toString());
    }
  }

  void sendWelcomeMessage({
    required BuildContext context,
    required String receiverId,
    required UserModel adminData, // Données de l'admin
    required String message, // Message de bienvenue
  }) async {
    final timeSent = DateTime.now();
    final messageId = const Uuid().v1();

    final MessageModel welcomeMessage = MessageModel(
      senderId: adminData.uid, // UID de l'admin
      receiverId: receiverId,
      textMessage: message,
      type: MessageType.text,
      timeSent: timeSent,
      messageId: messageId,
      isSeen: false, imageUrls: [],
    );

    // Enregistrez le message dans les collections 'messages' de l'expéditeur (admin) et du destinataire (nouvel utilisateur)
    await firestore
        .collection('users')
        .doc(adminData.uid)
        .collection('chats')
        .doc(receiverId)
        .collection('messages')
        .doc(messageId)
        .set(welcomeMessage.toMap());

    await firestore
        .collection('users')
        .doc(receiverId)
        .collection('chats')
        .doc(adminData.uid)
        .collection('messages')
        .doc(messageId)
        .set(welcomeMessage.toMap());

    // Du côté de l'administrateur, le dernier message doit afficher les informations de l'utilisateur
    final LastMessageModel adminLastMessageInfo = LastMessageModel(
      username: adminData.username, // Nom d'utilisateur de l'admin
      profileImageUrl: adminData.profileImageUrl, // Image de profil de l'admin
      contactId: receiverId, // ID de contact de l'utilisateur
      timeSent: timeSent,
      lastMessage: message,
      lastMessageId: messageId,
      senderId: adminData.uid,
    );

    // Du côté de l'utilisateur, le dernier message doit afficher les informations de l'administrateur
    final LastMessageModel userLastMessageInfo = LastMessageModel(
      username: adminData.username, // Nom d'utilisateur de l'admin
      profileImageUrl: adminData.profileImageUrl, // Image de profil de l'admin
      contactId: adminData.uid, // UID de l'admin
      timeSent: timeSent,
      lastMessage: message,
      lastMessageId: messageId,
      senderId: adminData.uid,
    );

    // Enregistrez le dernier message pour l'administrateur
    await firestore
        .collection('users')
        .doc(adminData.uid)
        .collection('chats')
        .doc(receiverId)
        .set(adminLastMessageInfo.toMap());

    // Enregistrez le dernier message pour l'utilisateur
    await firestore
        .collection('users')
        .doc(receiverId)
        .collection('chats')
        .doc(adminData.uid)
        .set(userLastMessageInfo.toMap());
  }

  void saveToMessageCollection({
    required String receiverId,
    required String textMessage,
    required DateTime timeSent,
    required List<String> imageUrls,
    required String textMessageId,
    required String senderUsername,
    required String receiverUsername,
    required MessageType messageType,
  }) async {
    final message = MessageModel(
      senderId: auth.currentUser!.uid,
      receiverId: receiverId,
      textMessage: textMessage,
      imageUrls: imageUrls,
      type: messageType,
      timeSent: timeSent,
      messageId: textMessageId,
      isSeen: false,
    );

    // sender
    await firestore
        .collection('users')
        .doc(auth.currentUser!.uid)
        .collection('chats')
        .doc(receiverId)
        .collection('messages')
        .doc(textMessageId)
        .set(message.toMap());

    // receiver
    await firestore
        .collection('users')
        .doc(receiverId)
        .collection('chats')
        .doc(auth.currentUser!.uid)
        .collection('messages')
        .doc(textMessageId)
        .set(message.toMap());
  }

  void saveAsLastMessage({
    required UserModel senderUserData,
    required UserModel receiverUserData,
    required String lastMessage,
    required DateTime timeSent,
    required String receiverId,
    required String lastMessageId,
    required String senderId,
  }) async {
    final receiverLastMessage = LastMessageModel(
      username: senderUserData.username,
      profileImageUrl: senderUserData.profileImageUrl,
      contactId: senderUserData.uid,
      timeSent: timeSent,
      lastMessage: lastMessage,
      lastMessageId: lastMessageId,
      senderId: senderId,
    );

    await firestore
        .collection('users')
        .doc(receiverId)
        .collection('chats')
        .doc(auth.currentUser!.uid)
        .set(receiverLastMessage.toMap());

    final senderLastMessage = LastMessageModel(
      username: receiverUserData.username,
      profileImageUrl: receiverUserData.profileImageUrl,
      contactId: receiverUserData.uid,
      timeSent: timeSent,
      lastMessage: lastMessage,
      lastMessageId: lastMessageId,
      senderId: senderId,
    );

    await firestore
        .collection('users')
        .doc(auth.currentUser!.uid)
        .collection('chats')
        .doc(receiverId)
        .set(senderLastMessage.toMap());
  }
}
