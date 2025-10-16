import 'package:firebase_auth/firebase_auth.dart';
import 'package:local_auth/local_auth.dart';

class FirebaseController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final LocalAuthentication _localAuth = LocalAuthentication();

  Future<User?> signInWithNifAndPassword(String nif, String password) async {
    return (await _auth.signInWithEmailAndPassword(email: nif, password: password)).user;
  }

  Future<bool> authenticateWithBiometrics() async {
    bool canCheckBiometrics = await _localAuth.canCheckBiometrics;
    if (!canCheckBiometrics) return false;
    return await _localAuth.authenticate(
      localizedReason: 'Autentique-se para registrar o ponto',
      options: const AuthenticationOptions(biometricOnly: true),
    );
  }

  User? get currentUser => _auth.currentUser;

  Future<void> signOut() async {
    await _auth.signOut();
  }
}