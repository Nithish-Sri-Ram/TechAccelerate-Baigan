import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:baigan/routes/routes.dart';
import 'package:baigan/widgets/bottom_navbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthController extends GetxController {
  static AuthController instance = Get.find();
  late Rx<User?> _user;
  FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  @override
  void onReady() {
    super.onReady();
    _user = Rx<User?>(auth.currentUser);
    _user.bindStream(auth.userChanges());
    ever(_user, _initialScreen);
  }

  _initialScreen(User? user) {
    if (user == null) {
      Get.offAllNamed(AppPage.getLogin());
    } else {
      Get.offAll(() => const BottomNavbar());
    }
  }

  Future<void> login(String email, String password) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      await auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      isLoading.value = false;
    } on FirebaseAuthException catch (e) {
      isLoading.value = false;

      switch (e.code) {
        case 'user-not-found':
          errorMessage.value = 'No user found with this email.';
          break;
        case 'wrong-password':
          errorMessage.value = 'Incorrect password. Please try again.';
          break;
        case 'invalid-email':
          errorMessage.value = 'The email address is not valid.';
          break;
        case 'user-disabled':
          errorMessage.value = 'This user account has been disabled.';
          break;
        default:
          errorMessage.value = 'Login failed. Please try again.';
      }

      Get.snackbar(
        'Login Error',
        errorMessage.value,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        margin: const EdgeInsets.all(10),
      );
    } catch (e) {
      isLoading.value = false;
      errorMessage.value = 'An unexpected error occurred. Please try again.';

      Get.snackbar(
        'Error',
        errorMessage.value,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        margin: const EdgeInsets.all(10),
      );
    }
  }

  Future<void> register(String email, String password,
      {String name = ''}) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      // Create user with email and password
      UserCredential userCredential = await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Create user document in Firestore
      if (userCredential.user != null) {
        await _firestore.collection('users').doc(userCredential.user!.uid).set({
          'name': name.isNotEmpty ? name : 'User',
          'email': email,
          'phone': '',
          'business': '',
          'createdAt': FieldValue.serverTimestamp(),
        });

        // Update display name in Firebase Auth
        if (name.isNotEmpty) {
          await userCredential.user!.updateDisplayName(name);
        }
      }

      isLoading.value = false;
    } on FirebaseAuthException catch (e) {
      isLoading.value = false;

      switch (e.code) {
        case 'email-already-in-use':
          errorMessage.value = 'This email is already registered.';
          break;
        case 'invalid-email':
          errorMessage.value = 'The email address is not valid.';
          break;
        case 'weak-password':
          errorMessage.value = 'The password is too weak.';
          break;
        case 'operation-not-allowed':
          errorMessage.value = 'Account creation is not enabled.';
          break;
        default:
          errorMessage.value = 'Registration failed. Please try again.';
      }

      Get.snackbar(
        'Registration Error',
        errorMessage.value,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        margin: const EdgeInsets.all(10),
      );
    } catch (e) {
      isLoading.value = false;
      errorMessage.value = 'An unexpected error occurred. Please try again.';

      Get.snackbar(
        'Error',
        errorMessage.value,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        margin: const EdgeInsets.all(10),
      );
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      await auth.sendPasswordResetEmail(email: email);

      isLoading.value = false;
      Get.snackbar(
        'Password Reset',
        'Password reset link sent to $email',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        margin: const EdgeInsets.all(10),
      );
    } on FirebaseAuthException catch (e) {
      isLoading.value = false;

      switch (e.code) {
        case 'invalid-email':
          errorMessage.value = 'The email address is not valid.';
          break;
        case 'user-not-found':
          errorMessage.value = 'No user found with this email.';
          break;
        default:
          errorMessage.value = 'Password reset failed. Please try again.';
      }

      Get.snackbar(
        'Reset Error',
        errorMessage.value,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        margin: const EdgeInsets.all(10),
      );
    } catch (e) {
      isLoading.value = false;
      errorMessage.value = 'An unexpected error occurred. Please try again.';

      Get.snackbar(
        'Error',
        errorMessage.value,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        margin: const EdgeInsets.all(10),
      );
    }
  }

  Future<void> signOut() async {
    await auth.signOut();
  }

  bool validatePassword(String password, String confirmPassword) {
    if (password != confirmPassword) {
      Get.snackbar(
        'Password Error',
        'Passwords do not match',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        margin: const EdgeInsets.all(10),
      );
      return false;
    }

    if (password.length < 6) {
      Get.snackbar(
        'Password Error',
        'Password must be at least 6 characters',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        margin: const EdgeInsets.all(10),
      );
      return false;
    }

    return true;
  }
}
