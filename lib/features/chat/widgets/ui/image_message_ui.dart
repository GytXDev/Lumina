import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lumina/colors/coloors.dart';
import 'package:lumina/main.dart';

class ImageMessage extends ConsumerWidget {
  final List<String> imageUrls;
  final String caption;
  final DateTime timeSent;
  final bool isSeen;
  final String senderId;

  const ImageMessage({
    super.key,
    required this.imageUrls,
    required this.caption,
    required this.timeSent,
    required this.isSeen,
    required this.senderId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Vérifiez si l'utilisateur actuel est l'expéditeur du message
    bool isCurrentUserSender =
        FirebaseAuth.instance.currentUser?.uid == senderId;
    final themeMode = ref.watch(themeModeProvider);
    final textColor = themeMode == ThemeMode.dark ? Colors.white : Colors.black;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        imageUrls.length > 1
            ? GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 4,
                  mainAxisSpacing: 4,
                ),
                itemCount: imageUrls.length,
                itemBuilder: (context, index) {
                  return InkWell(
                    onTap: () => _showImageDialog(context, imageUrls[index]),
                    child: Image.network(imageUrls[index], fit: BoxFit.cover),
                  );
                },
              )
            : InkWell(
                onTap: () => _showImageDialog(context, imageUrls.first),
                child: Image.network(imageUrls.first, fit: BoxFit.cover),
              ),

        if (caption.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              caption,
              style: TextStyle(
                  fontSize: 16,
                  color: isCurrentUserSender ? textColor : Colors.white),
            ),
          ),

        // Temps d'envoi
        Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                DateFormat('HH:mm').format(timeSent),
                style: TextStyle(
                    fontSize: 12,
                    color: isCurrentUserSender ? textColor : Colors.white),
              ),
              const SizedBox(
                width: 5,
              ),
              // Ajoutez ici la logique pour afficher l'icône en fonction de isSeen
              _buildSeenIcon(),
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
        : Container(); // Si ce n'est pas l'expéditeur, retournez un conteneur vide
  }
}

void _showImageDialog(BuildContext context, String imageUrl) {
  showDialog(
    context: context,
    builder: (_) => Dialog(
      backgroundColor: Colors.transparent,
      child: GestureDetector(
        onTap: () => Navigator.of(context)
            .pop(), // Ferme la boîte de dialogue sur un tap
        child: SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: Image.network(imageUrl, fit: BoxFit.contain),
        ),
      ),
    ),
  );
}
