// ignore_for_file: avoid_print, use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:location/location.dart';
import 'package:lumina/colors/helpers/show_loading_dialog.dart';
import 'package:lumina/features/chat/repository/chat_repository.dart';
import 'package:lumina/languages/app_translations.dart';
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
    Map<String, dynamic> online = {
      'active': true,
      'lastSeen': DateTime.now().millisecondsSinceEpoch,
    };
    Map<String, dynamic> offline = {
      'active': false,
      'lastSeen': DateTime.now().millisecondsSinceEpoch,
    };

    final connectedRef = realtime.ref('.info/connected');

    connectedRef.onValue.listen((event) async {
      final isConnected = event.snapshot.value as bool? ?? false;
      if (isConnected) {
        await realtime.ref().child(auth.currentUser!.uid).update(online);
        await firestore
            .collection('users')
            .doc(auth.currentUser!.uid)
            .update(online);
      } else {
        await realtime
            .ref()
            .child(auth.currentUser!.uid)
            .onDisconnect()
            .update(offline);
        await firestore
            .collection('users')
            .doc(auth.currentUser!.uid)
            .update(offline);
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
    UserModel? user;
    final userInfo =
        await firestore.collection('users').doc(auth.currentUser?.uid).get();
    if (userInfo.data() == null) return user;
    user = UserModel.fromMap(userInfo.data()!);
    return user;
  }

  // method for saving user information
  void saveUserInfoToFirestore({
    required String username,
    required var profileImage,
    required bool isConcessionary,
    required ProviderRef ref,
    required BuildContext context,
    required bool mounted,
  }) async {
    try {
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

      showLoadingDialog(
        context: context,
        message: AppLocalizations.of(context).translate('savingUserInfo'),
        barrierDismissible: false,
      );

      String uid = auth.currentUser!.uid;
      String profileImageUrl = profileImage is String ? profileImage : '';
      LocationData locationData = await getCoordinates();
      double latitude = locationData.latitude!;
      double longitude = locationData.longitude!;

      final firebaseStorageRepository =
          ref.read(firebaseStorageRepositoryProvider);
      if (profileImage != null && profileImage is! String) {
        profileImageUrl = await firebaseStorageRepository.storeFileToFirebase(
            'profileImage/$uid', profileImage);
      }

      bool isAdmin = await isFirstUser();
      bool isCertified = false;
      UserModel? existingUser =
          await getUserByPhoneNumber(auth.currentUser!.phoneNumber!);

      if (existingUser == null) {
        // Aucun utilisateur existant, créer un nouvel utilisateur
        UserModel newUser = UserModel(
          username: username,
          uid: uid,
          profileImageUrl: profileImageUrl,
          active: true,
          lastSeen: DateTime.now().millisecondsSinceEpoch,
          phoneNumber: auth.currentUser!.phoneNumber!,
          userType: isAdmin ? 'admin' : 'user',
          isConcessionary: isConcessionary ? 'concessionary' : 'particular',
          isCertified: isCertified,
          latitude: latitude,
          longitude: longitude,
        );

        await firestore.collection('users').doc(uid).set(newUser.toMap());
        print('New user info saved to Firestore with UID: $uid');

        if (!isAdmin) {
          UserModel? adminUser = await findAnAdmin();
          if (adminUser != null) {
            final ChatRepository chatRepository =
                ref.read(chatRepositoryProvider);
            String welcomeMessage =
                AppLocalizations.of(context).translate('welcomeAdminMessage');

            // Appelez la nouvelle méthode sendWelcomeMessage
            chatRepository.sendWelcomeMessage(
              context: context,
              message: welcomeMessage,
              receiverId: newUser.uid,
              adminData:
                  adminUser, // Assurez-vous que ceci est l'objet UserModel de l'administrateur
            );
            print('Welcome message sent to new user UID: $uid');
          } else {
            print("Admin user not found, welcome message not sent.");
          }
        }
      } else {
        // Utilisateur existant, vérifier si le champ isCertified existe déjà
        if (existingUser.isCertified != null) {
          isCertified = existingUser.isCertified!;
        }
        // Utilisateur existant, mettre à jour les informations
        await firestore.collection('users').doc(uid).update({
          'username': username,
          'profileImageUrl': profileImageUrl,
          'isConcessionary': isConcessionary ? 'concessionary' : 'particular',
          'latitude': latitude,
          'isCertified': isCertified,
          'longitude': longitude,
        });
      }

      Navigator.pop(context); // Ferme le dialogue de chargement
      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(context, Routes.home, (route) => false);
    } catch (e) {
      Navigator.pop(context);
      showAlertDialog(context: context, message: e.toString());
    }
  }

// Ajoutez cette fonction pour obtenir les coordonnées de latitude et de longitude
  Future<LocationData> getCoordinates() async {
    Location location = Location();
    return await location.getLocation();
  }

  Future<UserModel?> getUserByPhoneNumber(String phoneNumber) async {
    // Query the Firestore to get user by phoneNumber
    QuerySnapshot querySnapshot = await firestore
        .collection('users')
        .where('phoneNumber', isEqualTo: phoneNumber)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      return UserModel.fromMap(
          querySnapshot.docs.first.data() as Map<String, dynamic>);
    } else {
      return null;
    }
  }

  User? getCurrentUser() {
    return auth.currentUser;
  }

  //method for verify Code Sms
  void verifySmsCode({
    required BuildContext context,
    required String smsCodeId,
    required String smsCode,
    required bool mounted,
  }) async {
    try {
      showLoadingDialog(
        context: context,
        message: AppLocalizations.of(context).translate('verifyingCode'),
        barrierDismissible: false,
      );
      final credential = PhoneAuthProvider.credential(
        verificationId: smsCodeId,
        smsCode: smsCode,
      );
      await auth.signInWithCredential(credential);
      UserModel? user = await getCurrentUserInfo();
      if (!mounted) return;
      Navigator.of(context).pushNamedAndRemoveUntil(
        Routes.userInfo,
        (route) => false,
        arguments: user?.profileImageUrl,
      );
    } on FirebaseAuthException catch (e) {
      Navigator.of(context).pop();
      showAlertDialog(
        context: context,
        message: AppLocalizations.of(context).translate('invalidCode'),
      );
      print(e);
    }
  }

  // method for smsCode

  Future<void> sendSmsCode({
    required BuildContext context,
    required String phoneNumber,
  }) async {
    try {
      showLoadingDialog(
        context: context,
        message: AppLocalizations.of(context).translateWithVariables(
            'sendingVerificationCode', {"phoneNumber": phoneNumber}),
        barrierDismissible: false,
      );

      await auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (phoneAuthCredential) async {
          await auth.signInWithCredential(phoneAuthCredential);
        },
        verificationFailed: (e) {
          // Ferme le dialogue de chargement avec un délai pour attendre la fermeture effective
          Future.delayed(Duration.zero, () {
            Navigator.of(context).pop();
            showAlertDialog(context: context, message: e.toString());
          });
        },
        codeSent: (verificationId, forceResendingToken) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            Routes.verification,
            (route) => false,
            arguments: {
              'phoneNumber': phoneNumber,
              'smsCodeId': verificationId,
            },
          );
        },
        codeAutoRetrievalTimeout: (verificationId) {},
      );
    } on FirebaseAuthException catch (e) {
      // Ferme le dialogue de chargement avec un délai pour attendre la fermeture effective
      Future.delayed(Duration.zero, () {
        Navigator.of(context).pop();
        showAlertDialog(context: context, message: e.toString());
      });
    }
  }
  //methde pour appel
}
