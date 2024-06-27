// ignore_for_file: avoid_print

import 'dart:async';
import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lumina/colors/coloors.dart';
import 'package:lumina/colors/extension/extension_theme.dart';
import 'package:lumina/features/auth/widgets/custom_icon_button.dart';
import 'package:lumina/languages/app_translations.dart';
import '../../../common/enum/message_type.dart';
import '../../cars/pages/multiple_images.dart';
import '../controllers/chat_controller.dart';
import 'package:record/record.dart';
import 'package:lumina/features/chat/widgets/ui/image_send_dialog.dart';

class ChatTextField extends ConsumerStatefulWidget {
  const ChatTextField({
    super.key,
    required this.receiverId,
    required this.scrollController,
  });

  final String receiverId;
  final ScrollController scrollController;

  @override
  ConsumerState<ChatTextField> createState() => _ChatTextFieldState();
}

class _ChatTextFieldState extends ConsumerState<ChatTextField> {
  late TextEditingController messageController;
  bool isMessageIconEnabled = false;
  double cardHeight = 0;

  bool isRecording = false;
  Duration recordingDuration = Duration.zero;
  Timer? recordingTimer;

  bool isRecordingAnimated = false;
  late AnimationController animationController;
  late Animation<double> animation;
  String recordingTime = "00:00";
  Timer? timer;
  double opacity = 1.0;

  late final Record audioRecord;
  late AudioPlayer audioPlayer;
  String audioPath = '';

  Future<void> startRecordingAnimation() async {
    startRecording();
    setState(() {
      isRecordingAnimated = true;
    });
  }

  void stopRecordingAnimation() {
    stopRecording();
    setState(() {
      isRecordingAnimated = false;
      recordingTime = "00:00";
    });
  }

  Widget animatedMicIcon() {
    return GestureDetector(
      onTap: () {
        if (isRecordingAnimated) {
          stopRecordingAnimation(); // Arrête l'enregistrement si déjà en cours
        } else {
          startRecordingAnimation(); // Commence l'enregistrement sinon
        }
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Animation des ondes
          AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            width: isRecordingAnimated ? 100 : 0, // Taille de départ de l'onde
            height: isRecordingAnimated ? 100 : 0,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.red.withOpacity(0.5), // Couleur de l'onde
            ),
          ),
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white, // Couleur de fond du cercle
            ),
            padding: const EdgeInsets.all(8),
            child: Icon(
              isRecordingAnimated ? Icons.delete : Icons.mic_none_outlined,
              color: isRecordingAnimated
                  ? Colors.red
                  : Colors.grey, // Changement de couleur de l'icône
              size: isRecordingAnimated
                  ? 30
                  : 24, // Changement de taille de l'icône
            ),
          ),
        ],
      ),
    );
  }

  void sendTextMessage() async {
    if (isMessageIconEnabled) {
      ref.read(chatControllerProvider).sendTextMessage(
            context: context,
            textMessage: messageController.text,
            receiverId: widget.receiverId,
          );
      messageController.clear();
    }

    await Future.delayed(const Duration(milliseconds: 100));
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      widget.scrollController.animateTo(
        widget.scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  void showImagePreviewDialog(BuildContext context, List<File> images) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return ImagePreviewSendDialog(
          images: images,
          receiverId: widget.receiverId,
          scrollController: widget.scrollController,
        );
      },
    );
  }

  void showAttachmentMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SizedBox(
          height: 150,
          child: Column(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Photo or Video'),
                onTap: () {
                  imageHelper
                      .pickImage(multiple: true)
                      .then((List<XFile?> files) {
                    final List<File> images = files
                        .where((xFile) => xFile != null)
                        .map((xFile) => File(xFile!.path))
                        .toList();

                    print('${images.length} images have been selected.');

                    Navigator.pop(context); // Ferme le bottom sheet
                    showImagePreviewDialog(
                        context, images); // Affiche l'aperçu des images
                  }).catchError((e) {
                    print('Error selecting images: $e');
                  });
                },
              ),
              // Vous pouvez ajouter d'autres options ici si nécessaire
            ],
          ),
        );
      },
    );
  }

  Future<void> stopRecordingAndSendMessage() async {
    final path = await audioRecord.stop();
    if (path == null) return;

    setState(() {
      isRecording = false;
      audioPath = path;
      recordingTime = "00:00"; // Réinitialiser le temps d'enregistrement
    });

    final chatController = ref.read(chatControllerProvider);
    final file = File(audioPath);
    chatController.sendFileMessage(
      // ignore: use_build_context_synchronously
      context,
      file,
      widget.receiverId,
      MessageType.audio,
    );
    stopRecordingAnimation();
  }

  @override
  void initState() {
    super.initState();
    messageController = TextEditingController();
    audioPlayer = AudioPlayer();
    audioRecord = Record();

    // Ajout du Listener au TextEditingController
    messageController.addListener(() {
      final isNotEmpty = messageController.text.isNotEmpty;
      if (isMessageIconEnabled != isNotEmpty) {
        setState(() {
          isMessageIconEnabled = isNotEmpty;
        });
      }
    });
  }

  @override
  void dispose() {
    messageController.dispose();
    audioPlayer.dispose();
    audioRecord.dispose();
    timer?.cancel();
    super.dispose();
  }

  Future<void> startRecording() async {
    setState(() {
      isRecording = true;
    });
    int seconds = 0;
    timer = Timer.periodic(const Duration(seconds: 1), (Timer t) {
      setState(() {
        seconds++;
        recordingTime =
            "${(seconds ~/ 60).toString().padLeft(2, '0')}:${(seconds % 60).toString().padLeft(2, '0')}";
      });
    });

    // Pour le point rouge clignotant
    Timer.periodic(const Duration(milliseconds: 500), (Timer t) {
      if (!isRecording) {
        t.cancel();
      }
      setState(() {
        opacity = opacity == 1.0 ? 0.0 : 1.0;
      });
    });
    try {
      if (await audioRecord.hasPermission()) {
        await audioRecord.start();
        setState(() {
          isRecording = true;
        });
      }
    } catch (e) {
      print('error recording : $e');
    }
  }

  Future<void> stopRecording() async {
    setState(() {
      isRecording = false;
      recordingTime = "00:00";
    });
    timer?.cancel();
    try {
      String? path = await audioRecord.stop();
      setState(() {
        isRecording = false;
        audioPath = path!;
      });
    } catch (e) {
      print('error stopping recording : $e');
    }
  }

  String getHintText() {
    if (isRecording) {
      return recordingTime;
    } else {
      return AppLocalizations.of(context).translate('messageInputHint');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedContainer(
          duration: const Duration(
              milliseconds: 300), // Rendre l'animation plus fluide
          curve: Curves.easeInOut, // Ajouter une courbe d'animation
          height: cardHeight,
          width: double.maxFinite,
          margin: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: context.theme.receiverChatCardBg,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 2,
                blurRadius: 7,
                offset: const Offset(0, 3),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(5.0),
          child: Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: messageController,
                  maxLines: 4,
                  minLines: 1,
                  decoration: InputDecoration(
                    hintText:
                        getHintText(), // Utilisez la méthode pour générer le hintText
                    hintStyle: TextStyle(color: context.theme.greyColor),
                    filled: true,
                    fillColor: context.theme.chatTextBg,
                    isDense: true,
                    border: OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.circular(30),
                    ),

                    // Icône de suppression, affichée conditionnellement
                    suffixIcon: isRecording
                        ? IconButton(
                            icon:
                                const Icon(Icons.send, color: Coolors.blueDark),
                            onPressed: () {
                              stopRecordingAndSendMessage();
                            },
                          )
                        : IconButton(
                            icon: Icon(Icons.attach_file,
                                color: context.theme.greyColor),
                            onPressed: () {
                              showAttachmentMenu(context);
                            },
                          ),
                  ),
                ),
              ),
              const SizedBox(width: 5),
              GestureDetector(
                onTap: () {
                  startRecordingAnimation();
                },
                child: isMessageIconEnabled
                    ? CustomIconButton(
                        onTap: sendTextMessage,
                        icon: Icons.send_outlined,
                        background: Coolors.blueDark,
                        iconColor: Colors.white,
                      )
                    : animatedMicIcon(),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
