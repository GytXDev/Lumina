import 'package:audioplayers/audioplayers.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lumina/colors/extension/extension_theme.dart';

import '../../../../colors/coloors.dart';
import '../sound_wave.dart';

class AudioMessage extends StatefulWidget {
  final String audioUrl;
  final DateTime timeSent;
  final bool isHeard;
  final String senderId;

  const AudioMessage({
    super.key,
    required this.audioUrl,
    required this.timeSent,
    required this.isHeard,
    required this.senderId,
  });

  @override
  // ignore: library_private_types_in_public_api
  _AudioMessageState createState() => _AudioMessageState();
}

class _AudioMessageState extends State<AudioMessage> {
  late AudioPlayer audioPlayer;
  bool isPlaying = false;
  Duration duration = Duration.zero;
  Duration position = Duration.zero;
  late ThemeMode themeMode;

  @override
  void initState() {
    super.initState();
    audioPlayer = AudioPlayer();

    audioPlayer.onPlayerStateChanged.listen((state) {
      if (!mounted) return; // Vérifier si le widget est toujours monté
      setState(() {
        isPlaying = state == PlayerState.playing;
        if (state == PlayerState.completed) {
          // Réinitialisation à la fin de l'audio
          position = Duration.zero;
          isPlaying = false;
        }
      });
    });

    audioPlayer.onDurationChanged.listen((newDuration) {
      if (!mounted) return; // Vérifier si le widget est toujours monté
      setState(() {
        duration = newDuration;
      });
    });

    audioPlayer.onPositionChanged.listen((newPosition) {
      if (!mounted) return; // Vérifier si le widget est toujours monté
      setState(() {
        position = newPosition;
      });
    });

    initAudio();
  }

  Future<void> initAudio() async {
    try {
      await audioPlayer
          .setSourceUrl(widget.audioUrl)
          .timeout(const Duration(seconds: 30), onTimeout: () {
        // ignore: avoid_print
        print('Le chargement de l\'audio a pris trop de temps.');
        return;
      });
    } catch (e) {
      // ignore: avoid_print
      print('Erreur lors du chargement de l\'audio: $e');
    }
  }

  @override
  void dispose() {
    audioPlayer.dispose();
    super.dispose();
  }

  Future<void> togglePlaying() async {
    if (isPlaying) {
      await audioPlayer.pause();
    } else {
      if (position >= duration && duration != Duration.zero) {
        await audioPlayer.seek(Duration.zero);
      }
      await audioPlayer.resume();
    }
  }

  String formatTime(Duration duration) {
    return "${duration.inMinutes.remainder(60).toString().padLeft(2, '0')}:${duration.inSeconds.remainder(60).toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: togglePlaying,
      child: Container(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: Container(
                    key: ValueKey<bool>(isPlaying),
                    decoration: BoxDecoration(
                      color: context.theme.audioColor,
                      shape: BoxShape.circle,
                    ),
                    padding: const EdgeInsets.all(8),
                    child: Icon(
                      isPlaying ? Icons.pause : Icons.play_arrow,
                      size: 24,
                      color: context.theme.lightText,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: VoiceMessageWaveform(
                    isPlaying: isPlaying,
                    position: position,
                    duration: duration,
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _colorDate(),
                Row(
                  children: [
                    _colorText(),
                    const SizedBox(
                      width: 5.0,
                    ),
                    _buildHeardIcon(),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeardIcon() {
    // Vérifiez si l'utilisateur actuel est l'expéditeur du message
    bool isCurrentUserSender =
        FirebaseAuth.instance.currentUser?.uid == widget.senderId;

    // Affichez l'icône uniquement si l'utilisateur est l'expéditeur
    return isCurrentUserSender
        ? widget.isHeard
            ? const Icon(Icons.done_all, color: Coolors.blueDark)
            : const Icon(Icons.done, color: Colors.grey)
        : Container(); // Si ce n'est pas l'expéditeur, retournez un conteneur vide
  }

  Widget _colorText() {
    bool isCurrentUserSender =
        FirebaseAuth.instance.currentUser?.uid == widget.senderId;
    return isCurrentUserSender
        ? Text(
            DateFormat('HH:mm').format(widget.timeSent),
            style: TextStyle(
              fontSize: 12,
              color: context.theme.blackText,
            ),
          )
        : Text(
            DateFormat('HH:mm').format(widget.timeSent),
            style: const TextStyle(
              fontSize: 12,
              color: Colors.white,
            ),
          );
  }

  Widget _colorDate() {
    bool isCurrentUserSender =
        FirebaseAuth.instance.currentUser?.uid == widget.senderId;
    return isCurrentUserSender
        ? Text(
            "${formatTime(position)} / ${formatTime(duration)}",
            style: TextStyle(
              fontSize: 12,
              color: context.theme.blackText,
            ),
          )
        : Text(
            "${formatTime(position)} / ${formatTime(duration)}",
            style: const TextStyle(
              fontSize: 12,
              color: Colors.white,
            ),
          );
  }
}
