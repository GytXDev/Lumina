import 'dart:io';
import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final firebaseStorageRepositoryProvider = Provider(
  (ref) {
    return FirebaseStorageRepository(firebaseStorage: FirebaseStorage.instance);
  },
);

class FirebaseStorageRepository {
  final FirebaseStorage firebaseStorage;

  FirebaseStorageRepository({required this.firebaseStorage});

  //supprimer les images associées
  Future<void> deleteFileFromFirebase(String fileUrl) async {
    try {
      // Récupérer la référence du fichier à supprimer
      Reference reference = firebaseStorage.refFromURL(fileUrl);

      // Supprimer le fichier
      await reference.delete();
      // ignore: avoid_print
      print('Fichier supprimé avec succès de Firebase Storage.');
    } catch (e) {
      // ignore: avoid_print
      print('Erreur lors de la suppression du fichier : $e');
    }
  }

  storeFileToFirebase(String ref, dynamic file) async {
    UploadTask uploadTask;
    String? fileUrl;
    String contentType = 'application/octet-stream'; // Type par défaut

    String fileExtension = '';
    if (file is File) {
      fileExtension = file.path.split('.').last;
    }

    switch (fileExtension.toLowerCase()) {
      case 'jpg':
      case 'jpeg':
        contentType = 'image/jpeg';
        break;
      case 'png':
        contentType = 'image/png';
        break;
      case 'mp3':
        contentType = 'audio/mpeg';
        break;
      // Ajoutez d'autres cas selon les besoins
    }

    SettableMetadata metadata = SettableMetadata(contentType: contentType);

    try {
      if (file is File) {
        // Si c'est un fichier, utilisez putFile
        uploadTask = firebaseStorage.ref(ref).putFile(file, metadata);
      } else if (file is Uint8List) {
        // Si c'est des données binaires, utilisez putData
        uploadTask = firebaseStorage.ref(ref).putData(file, metadata);
      } else {
        throw 'Type de fichier non supporté';
      }

      TaskSnapshot snapshot = await uploadTask;
      if (snapshot.state == TaskState.success) {
        fileUrl = await snapshot.ref.getDownloadURL();
        // ignore: avoid_print
        print('File URL: $fileUrl');
      } else {
        // ignore: avoid_print
        print('Upload failed. State: ${snapshot.state}');
      }
    } on FirebaseException catch (e) {
      // ignore: avoid_print
      print('Error uploading file: $e');
    }

    return fileUrl;
  }
}
