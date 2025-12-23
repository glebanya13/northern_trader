import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:northern_trader/common/repositories/common_firebase_storage_repository.dart';
import 'package:northern_trader/common/utils/utils.dart';
import 'package:northern_trader/features/auth/screens/user_information_screen.dart';
import 'package:northern_trader/models/user_model.dart';
import 'package:northern_trader/mobile_layout_screen.dart';
import 'package:northern_trader/features/landing/screens/landing_screen.dart';

final authRepositoryProvider = Provider(
  (ref) => AuthRepository(
    auth: FirebaseAuth.instance,
    firestore: FirebaseFirestore.instance,
  ),
);

class AuthRepository {
  final FirebaseAuth auth;
  final FirebaseFirestore firestore;
  AuthRepository({
    required this.auth,
    required this.firestore,
  });

  Future<UserModel?> getCurrentUserData() async {
    if (auth.currentUser == null) {
      return null;
    }
    
    String uid = auth.currentUser!.uid;
    
    var userData = await firestore.collection('users').doc(uid).get();

    UserModel? user;
    if (userData.exists && userData.data() != null) {
      try {
        user = UserModel.fromMap(userData.data()!);
        return user;
      } catch (e) {
      }
    }
    
    return null;
  }

  String _getErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'Пользователь с таким email не найден.';
      case 'wrong-password':
        return 'Неверный пароль.';
      case 'email-already-in-use':
        return 'Email уже используется.';
      case 'invalid-email':
        return 'Неверный формат email.';
      case 'weak-password':
        return 'Пароль слишком слабый. Используйте минимум 6 символов.';
      case 'too-many-requests':
        return 'Слишком много запросов. Пожалуйста, подождите немного и попробуйте снова.';
      case 'user-disabled':
        return 'Аккаунт заблокирован.';
      default:
        return e.message ?? 'Произошла ошибка. Попробуйте снова.';
    }
  }

  Future<void> signInWithEmail(BuildContext context, String email, String password) async {
    try {
      if (email.trim().isEmpty) {
        showSnackBar(context: context, content: 'Пожалуйста, введите email');
        return;
      }
      if (password.trim().isEmpty) {
        showSnackBar(context: context, content: 'Пожалуйста, введите пароль');
        return;
      }
      
      await auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      
      String uid = auth.currentUser!.uid;
      var userDoc = await firestore.collection('users').doc(uid).get();
      
      if (userDoc.exists && userDoc.data() != null) {
        await Future.delayed(const Duration(milliseconds: 500));
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => const MobileLayoutScreen(),
          ),
          (route) => false,
        );
      } else {
        Navigator.pushNamedAndRemoveUntil(
          context,
          UserInformationScreen.routeName,
          (route) => false,
        );
      }
    } on FirebaseAuthException catch (e) {
      showSnackBar(context: context, content: _getErrorMessage(e));
      rethrow;
    } catch (e) {
      showSnackBar(context: context, content: 'Произошла ошибка: ${e.toString()}');
      rethrow;
    }
  }

  Future<void> signUpWithEmail(BuildContext context, String email, String password) async {
    try {
      if (email.trim().isEmpty) {
        showSnackBar(context: context, content: 'Пожалуйста, введите email');
        return;
      }
      if (password.trim().isEmpty) {
        showSnackBar(context: context, content: 'Пожалуйста, введите пароль');
        return;
      }
      if (password.length < 6) {
        showSnackBar(context: context, content: 'Пароль должен содержать минимум 6 символов');
        return;
      }
      
      await auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      
      Navigator.pushNamedAndRemoveUntil(
        context,
        UserInformationScreen.routeName,
        (route) => false,
      );
    } on FirebaseAuthException catch (e) {
      showSnackBar(context: context, content: _getErrorMessage(e));
      rethrow;
    } catch (e) {
      showSnackBar(context: context, content: 'Произошла ошибка: ${e.toString()}');
      rethrow;
    }
  }


  void saveUserDataToFirebase({
    required String name,
    required dynamic profilePic, 
    required ProviderRef ref,
    required BuildContext context,
  }) async {
    try {
      if (auth.currentUser == null) {
        showSnackBar(context: context, content: 'Пользователь не авторизован');
        return;
      }
      
      String uid = auth.currentUser!.uid;
      String email = auth.currentUser!.email ?? '';
      String photoUrl = ''; 

      if (profilePic != null) {
        photoUrl = await ref
            .read(commonFirebaseStorageRepositoryProvider)
            .storeFileToFirebase(
              'profilePic/$uid',
              profilePic,
            );
      }

      var user = UserModel(
        name: name,
        uid: uid, 
        profilePic: photoUrl,
        isOnline: true,
        phoneNumber: email,
        isOwner: false,
      );

      await firestore.collection('users').doc(uid).set(user.toMap());

      await Future.delayed(const Duration(milliseconds: 500));
      
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => const MobileLayoutScreen(),
        ),
        (route) => false,
      );
    } catch (e) {
      showSnackBar(context: context, content: e.toString());
    }
  }

  Stream<UserModel> userData(String userId) {
    return firestore.collection('users').doc(userId).snapshots().map(
          (event) => UserModel.fromMap(
            event.data()!,
          ),
        );
  }

  void setUserState(bool isOnline) async {
    if (auth.currentUser == null) return;
    
    String uid = auth.currentUser!.uid;
    
    await firestore.collection('users').doc(uid).update({
      'isOnline': isOnline,
    });
  }

  Future<void> signOut(BuildContext context) async {
    try {
      if (auth.currentUser != null) {
        setUserState(false);
      }
      await auth.signOut();
      if (context.mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LandingScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      if (context.mounted) {
        showSnackBar(context: context, content: 'Ошибка выхода: ${e.toString()}');
      }
    }
  }
}

