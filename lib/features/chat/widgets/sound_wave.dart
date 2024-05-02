import 'dart:math';

import 'package:flutter/material.dart';

class VoiceMessageWaveform extends StatelessWidget {
  final bool isPlaying;
  final Duration position;
  final Duration duration;
  final int barCount;
  final double maxWidth;
  final double maxHeight;

  const VoiceMessageWaveform({super.key, 
    required this.isPlaying,
    required this.position,
    required this.duration,
    this.barCount = 50,
    this.maxWidth = 2.0,
    this.maxHeight = 30.0,
  });

  @override
  Widget build(BuildContext context) {
    final progress =
        (position.inMilliseconds / duration.inMilliseconds).clamp(0.0, 1.0);
    final activeBars = (barCount * progress).round();

    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculer l'espace disponible entre les barres
        double spacing =
            (constraints.maxWidth - (barCount * maxWidth)) / barCount;

        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(barCount, (index) {
            final isActive = index <= activeBars;
            // Générer une hauteur aléatoire pour chaque barre
            final randomHeight = Random().nextInt(maxHeight.toInt()).toDouble();
            final barHeight = isActive
                ? randomHeight
                : randomHeight * 0.6; // Moins de hauteur quand inactif

            // Ajouter un point au début avec une progression
            if (index == 0 && isPlaying) {
              return _buildProgressPoint(isActive, spacing, barHeight);
            }

            // Créer un widget pour chaque barre
            return AnimatedContainer(
              duration: Duration(milliseconds: isActive ? 200 : 500),
              height: barHeight,
              width: maxWidth,
              margin: EdgeInsets.symmetric(horizontal: spacing / 2),
              decoration: BoxDecoration(
                color: isActive ? Colors.blue[400] : Colors.grey[200],
                borderRadius: BorderRadius.circular(3),
              ),
            );
          }),
        );
      },
    );
  }

  Widget _buildProgressPoint(bool isActive, double spacing, double barHeight) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      height: barHeight,
      width: maxWidth,
      margin: EdgeInsets.symmetric(horizontal: spacing / 2),
      decoration: BoxDecoration(
        color: Colors.green[400],
        borderRadius: BorderRadius.circular(3),
      ),
      child: Center(
        child: Container(
          width: 4.0, // Ajustez la largeur du point ici
          height: barHeight,
          decoration: BoxDecoration(
            color: Colors.white, // Couleur du point
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ),
    );
  }
}
