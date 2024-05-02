import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import '../sound_wave.dart';

class AudioPlayerWidget extends StatefulWidget {
  final String audioUrl;

  const AudioPlayerWidget({super.key, required this.audioUrl});

  @override
  // ignore: library_private_types_in_public_api
  _AudioPlayerWidgetState createState() => _AudioPlayerWidgetState();
}

class _AudioPlayerWidgetState extends State<AudioPlayerWidget> {
  late final AudioPlayer audioPlayer;
  late bool isPlaying;
  late Duration duration;
  late Duration position;

  @override
  void initState() {
    super.initState();
    audioPlayer = AudioPlayer();
    isPlaying = false;
    duration = Duration.zero;
    position = Duration.zero;

    audioPlayer.onPlayerStateChanged.listen((state) {
      if (mounted) {
        setState(() {
          isPlaying = (state == PlayerState.playing);
        });
      }
    });

    audioPlayer.onDurationChanged.listen((d) {
      if (mounted) {
        setState(() {
          duration = d;
        });
      }
    });

    audioPlayer.onPositionChanged.listen((p) {
      if (mounted) {
        setState(() {
          position = p;
        });
      }
    });
  }

  void togglePlaying() async {
    if (isPlaying) {
      await audioPlayer.pause();
    } else {
      if (position >= duration && duration != Duration.zero) {
        await audioPlayer.seek(Duration.zero);
      }
      await audioPlayer.resume();
    }
  }

  @override
  void dispose() {
    audioPlayer.dispose();
    super.dispose();
  }

  String formatTime(Duration duration) {
    return "${duration.inMinutes.remainder(60).toString().padLeft(2, '0')}:${duration.inSeconds.remainder(60).toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: togglePlaying,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.8),
          shape: BoxShape.circle,
        ),
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isPlaying ? Icons.pause : Icons.play_arrow,
              size: 24,
              color: Colors.black,
            ),
            VoiceMessageWaveform(
              isPlaying: isPlaying,
              position: position,
              duration: duration,
            ),
            Text(
              "${formatTime(position)} / ${formatTime(duration)}",
              style: const TextStyle(
                fontSize: 12,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
