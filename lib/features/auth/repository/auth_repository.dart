// ignore_for_file: avoid_print, use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:location/location.dart';
import 'package:lumina/colors/helpers/show_loading_dialog.dart';
import 'package:lumina/features/chat/repository/chat_repository.dart';
import 'package:lumina/languages/app_translations.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:lumina/models/user_models.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart ';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';

import '../../../../colors/helper_dialogue.dart';
import '../../../../routes/routes_pages.dart';
import 'firebase_storage_repository.dart';

final authRepositoryProvider = Provider(
  (ref) {
    return AuthRepository(
      auth: FirebaseAuth.instance,
      firestore: FirebaseFirestore.instance,
      realtime: FirebaseDatabase.instance,
    );
  },
);

class AuthRepository {
  final FirebaseAuth auth;
  final FirebaseFirestore firestore;
  final FirebaseDatabase realtime;

  AuthRepository({
    required this.auth,
    required this.firestore,
    required this.realtime,
  });

  Stream<UserModel> getUserPresenceStatus({required String uid}) {
    return firestore
        .collection('users')
        .doc(uid)
        .snapshots()
        .map((event) => UserModel.fromMap(event.data()!));
  }

  UserModel? adminUser;

  // récuperer un des admins
  Future<UserModel?> findAnAdmin() async {
    try {
      QuerySnapshot adminSnapshot = await firestore
          .collection('users')
          .where('userType', isEqualTo: 'admin')
          .limit(1)
          .get();

      if (adminSnapshot.docs.isNotEmpty) {
        UserModel adminUser = UserModel.fromMap(
            adminSnapshot.docs.first.data() as Map<String, dynamic>);
        print(
            'Admin found: ${adminUser.uid}'); // Ajout d'un print pour confirmer la récupération de l'admin
        return adminUser;
      } else {
        print('No admin found'); // Aucun admin trouvé
      }
    } catch (e) {
      print(
          "Error finding an admin: $e"); // Erreur lors de la recherche d'un admin
    }
    return null;
  }

  void updateUserPresence() {
    final connectedRef = realtime.ref('.info/connected');

    // Écouter l'état de connexion en temps réel
    connectedRef.onValue.listen((event) async {
      final isConnected = event.snapshot.value as bool? ?? false;
      final userId = auth.currentUser?.uid;

      if (userId == null) {
        print('Utilisateur non authentifié.');
        return;
      }

      // Détails de la présence
      final Map<String, dynamic> online = {
        'active': true,
        'lastSeen': DateTime.now().millisecondsSinceEpoch,
      };
      final Map<String, dynamic> offline = {
        'active': false,
        'lastSeen': DateTime.now().millisecondsSinceEpoch,
      };

      try {
        if (isConnected) {
          // Mise à jour en ligne dès la connexion
          await realtime.ref(userId).update(online);
          await firestore.collection('users').doc(userId).update(online);

          // Planifier la déconnexion automatique avec `onDisconnect`
          await realtime.ref(userId).onDisconnect().update(offline);
        } else {
          // Mise à jour hors ligne en cas de déconnexion manuelle
          await firestore.collection('users').doc(userId).update(offline);
        }
      } catch (e) {
        print('Erreur lors de la mise à jour de la présence: $e');
      }
    });
  }

  Future<bool> isFirstUser() async {
    QuerySnapshot usersSnapshot =
        await firestore.collection('users').limit(1).get();
    return usersSnapshot.docs.isEmpty;
  }

  Future<String?> getCurrentUserType() async {
    final userInfo =
        await firestore.collection('users').doc(auth.currentUser?.uid).get();
    return userInfo.data()?['userType'];
  }

  Future<UserModel?> getCurrentUserInfo() async {
    try {
      final userInfo =
          await firestore.collection('users').doc(auth.currentUser?.uid).get();

      if (userInfo.exists && userInfo.data() != null) {
        return UserModel.fromMap(userInfo.data()!);
      } else {
        return null;
      }
    } catch (e) {
      print("Error fetching user info: $e");
      return null;
    }
  }

  Future<UserModel?> getUserByEmailAddress(String emailAddress) async {
    // Query the Firestore to get user by email address
    QuerySnapshot querySnapshot = await firestore
        .collection('users')
        .where('email', isEqualTo: emailAddress)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      return UserModel.fromMap(
          querySnapshot.docs.first.data() as Map<String, dynamic>);
    } else {
      return null;
    }
  }

  // Method for saving user information
  void saveUserInfoToFirestore({
    required String username,
    required var profileImage,
    required bool isConcessionary,
    required ProviderRef ref,
    required BuildContext context,
    required bool mounted,
  }) async {
    try {
      // Demander la permission de localisation
      PermissionStatus permissionStatus = await Location().requestPermission();
      if (permissionStatus != PermissionStatus.granted) {
        QuickAlert.show(
          context: context,
          type: QuickAlertType.warning,
          title: AppLocalizations.of(context).translate('error'),
          text:
              AppLocalizations.of(context).translate('locationPermissionError'),
        );
        return;
      }

      // Afficher un dialogue de chargement
      showLoadingDialog(
        context: context,
        message: AppLocalizations.of(context).translate('savingUserInfo'),
        barrierDismissible: false,
      );

      String uid = auth.currentUser!.uid;
      String email = auth.currentUser!.email!;
      String profileImageUrl = profileImage is String ? profileImage : '';
      LocationData locationData = await getCoordinates();
      double latitude = locationData.latitude ?? 0.0;
      double longitude = locationData.longitude ?? 0.0;

      final firebaseStorageRepository =
          ref.read(firebaseStorageRepositoryProvider);

      // Upload de l'image si nécessaire
      if (profileImage != null && profileImage is! String) {
        profileImageUrl = await firebaseStorageRepository.storeFileToFirebase(
            'profileImage/$uid', profileImage);
      }

      bool isAdmin = await isFirstUser();

      // Vérifier si l'utilisateur existe déjà avec le même email
      UserModel? existingUser = await getUserByEmailAddress(email);

      if (existingUser == null) {
        // L'utilisateur n'existe pas, on le crée
        await _createUser(
          uid,
          username,
          profileImageUrl,
          isConcessionary,
          isAdmin,
          latitude,
          longitude,
          context,
          ref,
        );
      } else {
        // L'utilisateur existe, on met à jour ses informations
        await _updateUser(
          existingUser,
          username,
          profileImageUrl,
          isConcessionary,
          latitude,
          longitude,
        );
      }

      Navigator.pop(context); // Fermer le dialogue de chargement

      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(context, Routes.home, (route) => false);
    } catch (e) {
      Navigator.pop(context);
      showAlertDialog(context: context, message: e.toString());
    }
  }

  // Create a new user
  Future<void> _createUser(
      String uid,
      String username,
      String profileImageUrl,
      bool isConcessionary,
      bool isAdmin,
      double latitude,
      double longitude,
      BuildContext context,
      ProviderRef ref) async {
    UserModel newUser = UserModel(
      username: username,
      uid: uid,
      profileImageUrl: profileImageUrl,
      active: true,
      lastSeen: DateTime.now().millisecondsSinceEpoch,
      email: auth.currentUser!.email!,
      phoneNumber: '',
      userType: isAdmin ? 'admin' : 'user',
      isConcessionary: isConcessionary ? 'concessionary' : 'particular',
      isCertified: false,
      latitude: latitude,
      longitude: longitude,
    );

    await firestore.collection('users').doc(uid).set(newUser.toMap());
    print('New user info saved to Firestore with UID: $uid');

    if (!isAdmin) {
      UserModel? adminUser = await findAnAdmin();
      if (adminUser != null) {
        final ChatRepository chatRepository = ref.read(chatRepositoryProvider);
        String welcomeMessage =
            AppLocalizations.of(context).translate('welcomeAdminMessage');

        // Send welcome message
        chatRepository.sendWelcomeMessage(
          context: context,
          message: welcomeMessage,
          receiverId: newUser.uid,
          adminData: adminUser,
        );
        print('Welcome message sent to new user UID: $uid');
      } else {
        print("Admin user not found, welcome message not sent.");
      }
    }
  }

  // Update existing user information
  Future<void> _updateUser(
      UserModel existingUser,
      String username,
      String profileImageUrl,
      bool isConcessionary,
      double latitude,
      double longitude) async {
    await firestore.collection('users').doc(existingUser.uid).update({
      'username': username,
      'profileImageUrl': profileImageUrl,
      'isConcessionary': isConcessionary ? 'concessionary' : 'particular',
      'latitude': latitude,
      'isCertified': existingUser.isCertified ?? false,
      'longitude': longitude,
    });
  }

  // Ajoutez cette fonction pour obtenir les coordonnées de latitude et de longitude
  Future<LocationData> getCoordinates() async {
    Location location = Location();
    return await location.getLocation();
  }

  User? getCurrentUser() {
    return auth.currentUser;
  }

  // méthode de connexion via google
  Future<UserCredential?> signInWithGoogle() async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn();
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser != null) {
        final GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;

        final OAuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        return await auth.signInWithCredential(credential);
      }
    } catch (e) {
      print("Erreur lors de la connexion avec Google: $e");
    }
    return null;
  }
}
