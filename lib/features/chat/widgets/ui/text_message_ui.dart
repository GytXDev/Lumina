import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lumina/main.dart';

import '../../../../colors/coloors.dart';

class TextMessage extends ConsumerWidget {
  final String text;
  final DateTime timeSent;
  final bool isSeen;
  final String senderId;

  const TextMessage({
    super.key,
    required this.text,
    required this.timeSent,
    required this.isSeen,
    required this.senderId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final textColor = themeMode == ThemeMode.dark ? Colors.white : Colors.black;

    // Vérifiez si l'utilisateur actuel est l'expéditeur du message
    bool isCurrentUserSender =
        FirebaseAuth.instance.currentUser?.uid == senderId;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Text(
            text,
            style: TextStyle(
              fontSize: 16,
              color: isCurrentUserSender ? textColor : Colors.white,
            ),
          ),
        ),
        RichText(
          text: TextSpan(
            text: '${DateFormat('HH:mm').format(timeSent)}  ',
            style: TextStyle(
              fontSize: 12,
              color: isCurrentUserSender ? textColor : Colors.white,
            ),
            children: [
              WidgetSpan(
                child: _buildSeenIcon(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSeenIcon() {
    // Vérifiez si l'utilisateur actuel est l'expéditeur du message
    bool isCurrentUserSender =
        FirebaseAuth.instance.currentUser?.uid == senderId;

    // Affichez l'icône uniquement si l'utilisateur est l'expéditeur
    return isCurrentUserSender
        ? isSeen
            ? const Icon(Icons.done_all, color: Coolors.blueDark)
            : const Icon(Icons.done, color: Colors.grey)
        : const SizedBox.shrink(); // Si ce n'est pas l'expéditeur,
  }
}
