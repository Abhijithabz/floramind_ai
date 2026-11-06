import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

import '../../models/store_operation_result.dart';
import '../../models/seller_profile.dart';

class AuthService {
  const AuthService();

  bool get isAvailable => Firebase.apps.isNotEmpty;

  Future<StoreOperationResult> signIn({
    required String email,
    required String password,
  }) async {
    if (!isAvailable) {
      return const StoreOperationResult(
        success: true,
        message: 'Signed in in demo mode.',
      );
    }

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return const StoreOperationResult(
        success: true,
        message: 'Signed in successfully.',
      );
    } on FirebaseAuthException catch (error) {
      return StoreOperationResult(
        success: false,
        message: _friendlyMessage(error),
      );
    } catch (_) {
      return const StoreOperationResult(
        success: false,
        message: 'Unable to sign in right now.',
      );
    }
  }

  Future<StoreOperationResult> signUp({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    if (!isAvailable) {
      return const StoreOperationResult(
        success: true,
        message: 'Account created in demo mode.',
      );
    }

    try {
      final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final user = credential.user;
      if (user != null) {
        await user.updateDisplayName(name.trim());
        await user.reload();
        final refreshedUser = FirebaseAuth.instance.currentUser;
        final now = DateTime.now();
        try {
          await Future.wait([
            FirebaseFirestore.instance.collection('users').doc(user.uid).set({
              'userId': user.uid,
              'name': name.trim(),
              'email': email.trim(),
              'phone': phone.trim(),
              'createdAt': now,
              'updatedAt': now,
            }),
            FirebaseFirestore.instance
                .collection('seller_profiles')
                .doc(user.uid)
                .set({
                  'userId': user.uid,
                  'name': name.trim(),
                  'email': email.trim(),
                  'phone': phone.trim(),
                  'location': '',
                  'profileImage': '',
                  'createdAt': now,
                  'updatedAt': now,
                }),
          ]).timeout(const Duration(seconds: 10));
        } catch (_) {
          // Authentication should not fail when the optional profile database is unavailable.
        }

        if (refreshedUser != null) {
          await refreshedUser.updateDisplayName(name.trim());
        }
      }

      return const StoreOperationResult(
        success: true,
        message: 'Account created successfully.',
      );
    } on FirebaseAuthException catch (error) {
      return StoreOperationResult(
        success: false,
        message: _friendlyMessage(error),
      );
    } catch (_) {
      return const StoreOperationResult(
        success: false,
        message: 'Unable to create account right now.',
      );
    }
  }

  Future<StoreOperationResult> signOut() async {
    if (!isAvailable) {
      return const StoreOperationResult(
        success: true,
        message: 'Signed out of demo mode.',
      );
    }

    try {
      await FirebaseAuth.instance.signOut();
      return const StoreOperationResult(
        success: true,
        message: 'Signed out successfully.',
      );
    } catch (_) {
      return const StoreOperationResult(
        success: false,
        message: 'Unable to sign out right now.',
      );
    }
  }

  Future<StoreOperationResult> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    if (!isAvailable) {
      return const StoreOperationResult(
        success: false,
        message: 'Please sign in before changing your password.',
      );
    }

    final user = FirebaseAuth.instance.currentUser;
    final email = user?.email;
    if (user == null || email == null || email.isEmpty) {
      return const StoreOperationResult(
        success: false,
        message: 'Please sign in with an email and password first.',
      );
    }

    try {
      final credential = EmailAuthProvider.credential(
        email: email,
        password: currentPassword,
      );
      await user.reauthenticateWithCredential(credential);
      await user.updatePassword(newPassword);
      return const StoreOperationResult(
        success: true,
        message: 'Password changed successfully.',
      );
    } on FirebaseAuthException catch (error) {
      return StoreOperationResult(
        success: false,
        message: _friendlyMessage(error),
      );
    } catch (_) {
      return const StoreOperationResult(
        success: false,
        message: 'Unable to change your password right now.',
      );
    }
  }

  Future<StoreOperationResult> updateProfile({
    required String name,
    required String phone,
  }) async {
    if (!isAvailable) {
      return const StoreOperationResult(
        success: false,
        message: 'Please sign in before editing your profile.',
      );
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const StoreOperationResult(
        success: false,
        message: 'Please sign in before editing your profile.',
      );
    }

    final trimmedName = name.trim();
    final trimmedPhone = phone.trim();
    if (trimmedName.isEmpty) {
      return const StoreOperationResult(
        success: false,
        message: 'Name cannot be empty.',
      );
    }

    try {
      await user.updateDisplayName(trimmedName);
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'userId': user.uid,
        'name': trimmedName,
        'email': user.email ?? '',
        'phone': trimmedPhone,
        'updatedAt': DateTime.now(),
      }, SetOptions(merge: true));
      return const StoreOperationResult(
        success: true,
        message: 'Profile updated successfully.',
      );
    } on FirebaseAuthException catch (error) {
      return StoreOperationResult(
        success: false,
        message: _friendlyMessage(error),
      );
    } catch (_) {
      return const StoreOperationResult(
        success: false,
        message: 'Unable to update your profile right now.',
      );
    }
  }

  String _friendlyMessage(FirebaseAuthException error) {
    switch (error.code) {
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'The email or password is incorrect.';
      case 'requires-recent-login':
        return 'Please sign in again before changing your password.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'email-already-in-use':
        return 'This email is already registered.';
      case 'weak-password':
        return 'Please choose a stronger password.';
      case 'network-request-failed':
        return 'Network error. Please check your connection.';
      default:
        return error.message ?? 'Authentication failed.';
    }
  }
}
