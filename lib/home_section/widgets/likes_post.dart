import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lumina/colors/coloors.dart';
import 'package:lumina/colors/extension/extension_theme.dart';
import 'package:lumina/models/cars_model.dart';
import 'package:flutter/material.dart';

class LikeButton extends StatefulWidget {
  final CarsModel car;

  const LikeButton({super.key, required this.car});

  @override
  State<LikeButton> createState() => _LikeButtonState();
}

class _LikeButtonState extends State<LikeButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Color?> _colorAnimation;
  bool isLiked = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _colorAnimation = ColorTween(
      begin: Coolors.greyDark,
      end: Colors.purple,
    ).animate(_controller);

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        // Change color and update Firestore when animation is completed
        setState(() {
          isLiked = !isLiked;
        });
      }
    });
  }

  Future<String?> getUID() async {
    User? user = FirebaseAuth.instance.currentUser;

    // Vérifier si l'utilisateur est connecté
    if (user != null) {
      return user.uid;
    } else {
      // L'utilisateur n'est pas connecté
      return null;
    }
  }

  void onLikeButtonPressed(String carId, String userId) async {
    final carDoc = FirebaseFirestore.instance.collection('cars').doc(carId);
    final car = await carDoc.get();

    if (car.exists) {
      List<String> usersLiked = List<String>.from(car['usersLiked'] ?? []);
      if (usersLiked.contains(userId)) {
        usersLiked.remove(userId); // Retirer l'utilisateur de la liste
        await carDoc.update({
          'totalLike': car['totalLike'] - 1,
          'usersLiked': usersLiked,
        });
        // L'utilisateur a déjà aimé, retirez son like
      } else {
        // Incrémenter le compteur de likes et ajouter l'utilisateur à la liste des utilisateurs ayant aimé
        usersLiked.add(userId);
        await carDoc.update({
          'totalLike': car['totalLike'] + 1,
          'usersLiked': usersLiked,
        });
      }
    }
  }

  Future<void> _likePost() async {
    final carDoc =
        FirebaseFirestore.instance.collection('cars').doc(widget.car.carId);

    // Utilisation de la propriété userId du widget au lieu de passer en paramètre
    final userUid = await getUID();

    if (userUid != null) {
      final car = await carDoc.get();

      if (car.exists && car.data()!.containsKey('usersLiked')) {
        List<String> usersLiked = List<String>.from(car['usersLiked'] ?? []);

        if (usersLiked.contains(userUid)) {
          // L'utilisateur a déjà aimé, retirez son like
          usersLiked.remove(userUid);
        } else {
          // Incrémenter le compteur de likes et ajouter l'utilisateur à la liste des utilisateurs ayant aimé
          usersLiked.add(userUid);
        }

        // Mettez à jour la voiture avec la nouvelle liste d'utilisateurs qui ont aimé
        await carDoc.update({
          'totalLike': usersLiked.length,
          'usersLiked': usersLiked,
        });
      } else {
        throw Exception(
            "Le champ 'usersLiked' est absent dans le document Firestore.");
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: AnimatedBuilder(
        animation: _colorAnimation,
        builder: (context, child) => Icon(
          isLiked ? Icons.favorite : Icons.favorite_border,
          color: isLiked ? context.theme.purpleColor : _colorAnimation.value,
        ),
      ),
      onPressed: () {
        if (isLiked) {
          _controller.reverse();
        } else {
          _controller.forward();
          _likePost();
        }
      },
    );
  }
}
