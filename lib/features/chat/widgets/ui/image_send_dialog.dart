import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../languages/app_translations.dart';
import '../../controllers/chat_controller.dart';

class ImagePreviewSendDialog extends ConsumerStatefulWidget {
  final List<File> images;
  final String receiverId;
  final ScrollController scrollController;

  const ImagePreviewSendDialog({
    super.key,
    required this.images,
    required this.receiverId,
    required this.scrollController,
  });

  @override
  ConsumerState<ImagePreviewSendDialog> createState() =>
      _ImagePreviewSendDialogState();
}

class _ImagePreviewSendDialogState
    extends ConsumerState<ImagePreviewSendDialog> {
  final TextEditingController _captionController = TextEditingController();

  void _sendImages() async {
    if (widget.images.isEmpty) {
      Navigator.of(context).pop();
      return;
    }

    final chatController = ref.read(chatControllerProvider);

    chatController.sendImageMessage(
      context: context,
      images: widget.images,
      receiverId: widget.receiverId,
      caption: _captionController.text,
    );

    await Future.delayed(const Duration(milliseconds: 100));
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      widget.scrollController.animateTo(
        widget.scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });

    // ignore: use_build_context_synchronously
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(10),
      backgroundColor: Colors.transparent,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: <Widget>[
          ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height *
                  0.7, // ou autre pourcentage selon vos besoins
              maxWidth: MediaQuery.of(context).size.width *
                  0.9, // ou autre pourcentage selon vos besoins
            ),
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 30, 20, 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        // L'icône de fermeture
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.black),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                        // Le texte indiquant le nombre de photos à envoyer
                        Expanded(
                            child: Text(
                          widget.images.length == 1
                              ? AppLocalizations.of(context)
                                  .translateWithVariables(
                                  'send_photos_text',
                                  {'count': widget.images.length.toString()},
                                )
                              : AppLocalizations.of(context)
                                  .translateWithVariables(
                                  'send_photos_text2',
                                  {'count': widget.images.length.toString()},
                                ),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        )),
                      ],
                    ),
                    const SizedBox(height: 15),
                    SizedBox(
                      height:
                          MediaQuery.of(context).size.height * 0.3, // réglable
                      child: ListView.builder(
                        itemCount: widget.images.length,
                        itemBuilder: (context, index) {
                          return Image.file(widget.images[index],
                              fit: BoxFit.contain);
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: TextField(
                        controller: _captionController,
                        decoration: InputDecoration(
                            hintText: AppLocalizations.of(context)
                                .translate('caption_hint_text')),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: _sendImages,
                      child: Text(AppLocalizations.of(context)
                          .translate('send_button_text')),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
