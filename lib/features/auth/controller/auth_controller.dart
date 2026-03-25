import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:northern_trader/features/auth/repository/auth_repository.dart';
import 'package:northern_trader/models/user_model.dart';

final authControllerProvider = Provider((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return AuthController(authRepository: authRepository, ref: ref);
});

final authStateProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});

final userDataAuthProvider = FutureProvider<UserModel?>((ref) async {
  final authState = ref.watch(authStateProvider);
  
  return authState.when(
    data: (user) async {
      if (user == null) return null;
      final authController = ref.watch(authControllerProvider);
      return await authController.getUserData();
    },
    loading: () => null,
    error: (_, __) => null,
  );
});

class AuthController {
  final AuthRepository authRepository;
  final ProviderRef ref;
  AuthController({
    required this.authRepository,
    required this.ref,
  });

  Future<UserModel?> getUserData() async {
    UserModel? user = await authRepository.getCurrentUserData();
    return user;
  }

  Future<void> signInWithEmail(BuildContext context, String email, String password) {
    return authRepository.signInWithEmail(context, email, password);
  }

  Future<void> signUpWithEmail(BuildContext context, String email, String password) {
    return authRepository.signUpWithEmail(context, email, password);
  }

  void saveUserDataToFirebase(
      BuildContext context, String name, dynamic profilePic) {
    authRepository.saveUserDataToFirebase(
      name: name,
      profilePic: profilePic,
      ref: ref,
      context: context,
    );
  }

  Stream<UserModel> userDataById(String userId) {
    return authRepository.userData(userId);
  }

  void setUserState(bool isOnline) {
    authRepository.setUserState(isOnline);
  }

  Future<void> signOut(BuildContext context) async {
    await authRepository.signOut(context);
  }
}

