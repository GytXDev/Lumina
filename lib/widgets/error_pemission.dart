import 'package:flutter/material.dart';

class PermissionErrorPage extends StatelessWidget {
  const PermissionErrorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Erreur de permission'),
      ),
      body: const Center(
        child: Text('Désolé, vous n\'avez pas les autorisations nécessaires.'),
      ),
    );
  }
}
