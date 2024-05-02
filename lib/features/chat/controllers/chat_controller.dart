import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:lumina/models/last_message_model.dart';
import 'package:lumina/models/message_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../common/enum/message_type.dart';
import '../../auth/controllers/auth_controller.dart';
import '../repository/chat_repository.dart';

final chatControllerProvider = Provider((ref) {
  final chatRepository = ref.watch(chatRepositoryProvider);
  final auth = FirebaseAuth.instance; // Obtenez l'instance FirebaseAuth
  return ChatController(
    chatRepository: chatRepository,
    ref: ref,
    auth: auth, // Passez FirebaseAuth au constructeur
  );
});

class ChatController {
  final ChatRepository chatRepository;
  final ProviderRef ref;
  final FirebaseAuth
      auth; // Déclaration de la variable d'instance pour FirebaseAuth

  ChatController({
    required this.chatRepository,
    required this.ref,
    required this.auth, // Initialisation via le constructeur
  });
  Future<void> markMessagesAsSeen(String receiverId) async {
    final userId = auth.currentUser!.uid;

    // Appelez la méthode correspondante dans le repository
    await chatRepository.markMessagesAsSeen(userId, receiverId);
  }

  Future<bool> checkForUnreadMessages(String userId) async {
    return await chatRepository. hasUnreadMessages(userId); 
  }

  //controller pour la valeur isSeen 
  Future<bool> getMessageIsSeen(String messageId, String receiverId) async {
    return await chatRepository.getMessageIsSeen(messageId, receiverId);
  }

  void sendFileMessage(
    BuildContext context,
    var file,
    String receiverId,
    MessageType messageType,
  ) {
    ref.read(userInfoAuthProvider).whenData((senderData) {
      return chatRepository.sendFileMessage(
        file: file,
        context: context,
        receiverId: receiverId,
        senderData: senderData!,
        ref: ref,
        messageType: messageType,
      );
    });
  }

  void sendImageMessage({
    required BuildContext context,
    required List<File> images,
    required String receiverId,
    String? caption,
  }) {
    ref.read(userInfoAuthProvider).whenData((senderData) async {
      if (senderData != null) {
        await chatRepository.sendImageMessage(
          context: context,
          images: images,
          receiverId: receiverId,
          senderData: senderData,
          ref: ref,
          caption: caption,
          messageType: MessageType.image,
        );
      } else {}
    });
  }

  Stream<List<MessageModel>> getAllOneToOneMessage(String receiverId) {
    return chatRepository.getAllOneToOneMessage(receiverId);
  }

  Stream<List<LastMessageModel>> getAllLastMessageList() {
    return chatRepository.getAllLastMessageList();
  }

  void sendTextMessage({
    required BuildContext context,
    required String textMessage,
    required String receiverId,
  }) {
    ref.read(userInfoAuthProvider).whenData(
          (value) => chatRepository.sendTextMessage(
            context: context,
            textMessage: textMessage,
            receiverId: receiverId,
            senderData: value!,
          ),
        );
  }
}
