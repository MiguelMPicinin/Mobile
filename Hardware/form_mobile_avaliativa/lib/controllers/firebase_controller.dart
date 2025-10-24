// controllers/firebase_controller.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:local_auth/local_auth.dart';

class FirebaseController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final LocalAuthentication _localAuth = LocalAuthentication();

  Future<User?> signInWithEmailAndPassword(String email, String password) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      return userCredential.user;
    } catch (e) {
      throw FirebaseAuthException(code: 'login-failed', message: 'Falha no login: $e');
    }
  }

  Future<User?> registerWithEmailAndPassword(String email, String password) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      return userCredential.user;
    } catch (e) {
      throw FirebaseAuthException(code: 'register-failed', message: 'Falha no registro: $e');
    }
  }

  Future<bool> authenticateWithBiometrics() async {
    try {
      bool canCheckBiometrics = await _localAuth.canCheckBiometrics;
      if (!canCheckBiometrics) return false;

      bool isBiometricAvailable = await _localAuth.isDeviceSupported();
      if (!isBiometricAvailable) return false;

      return await _localAuth.authenticate(
        localizedReason: 'Autentique-se para registrar o ponto',
        options: const AuthenticationOptions(
          biometricOnly: true,
          useErrorDialogs: true,
          stickyAuth: true,
        ),
      );
    } catch (e) {
      return false;
    }
  }

  User? get currentUser => _auth.currentUser;

  Future<void> signOut() async {
    await _auth.signOut();
  }
}