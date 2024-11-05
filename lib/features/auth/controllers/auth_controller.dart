import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../models/user_models.dart';
import '../../../routes/routes_pages.dart';
import '../repository/auth_repository.dart';

final authControllerProvider = Provider(
  (ref) {
    final authRepository = ref.watch(authRepositoryProvider);
    return AuthController(authRepository: authRepository, ref: ref);
  },
);

final userInfoAuthProvider = FutureProvider((ref) {
  final authController = ref.watch(authControllerProvider);
  return authController.getCurrentUserInfo();
});

class AuthController {
  final AuthRepository authRepository;

  final ProviderRef ref;

  AuthController({required this.authRepository, required this.ref});

  Stream<UserModel> getUserPresenceStatus({required String uid}) {
    return authRepository.getUserPresenceStatus(uid: uid);
  }

  void updateUserPresence() {
    return authRepository.updateUserPresence();
  }

  Future<UserModel?> getCurrentUserInfo() async {
    UserModel? user = await authRepository.getCurrentUserInfo();
    return user;
  }

  void saveUserInfoToFirestore({
    required String username,
    required var profileImage,
    required bool isConcessionary,
    required BuildContext context,
    required bool mounted,
  }) {
    authRepository.saveUserInfoToFirestore(
      username: username,
      profileImage: profileImage,
      ref: ref,
      isConcessionary: isConcessionary,
      context: context,
      mounted: mounted,
    );
  }

  Future<void> signInWithGoogle(BuildContext context) async {
    try {
      final UserCredential? userCredential =
          await authRepository.signInWithGoogle();
      if (userCredential != null) {
        Navigator.of(context).pushNamedAndRemoveUntil(
          Routes.userInfo,
          (route) => false,
        );
      } else {
        print('erreur');
      }
    } catch (e) {
      print("Error signing in with Google: $e");
    }
  }
}
