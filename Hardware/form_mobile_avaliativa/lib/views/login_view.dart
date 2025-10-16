import 'package:flutter/material.dart';
import '../controllers/firebase_controller.dart';
import 'map_set_work_view.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _nifController = TextEditingController();
  final _passwordController = TextEditingController();
  final _firebaseController = FirebaseController();
  bool _loading = false;
  String? _error;

  void _loginNif() async {
    setState(() { _loading = true; _error = null; });
    try {
      await _firebaseController.signInWithNifAndPassword(
        _nifController.text.trim(),
        _passwordController.text.trim(),
      );
      Navigator.pushReplacement(context, MaterialPageRoute(
        builder: (_) => const MapSetWorkView(),
      ));
    } catch (e) {
      setState(() { _error = 'Falha ao autenticar: $e'; });
    }
    setState(() { _loading = false; });
  }

  void _loginBiometric() async {
    setState(() { _loading = true; _error = null; });
    bool ok = await _firebaseController.authenticateWithBiometrics();
    if (ok && _firebaseController.currentUser != null) {
      Navigator.pushReplacement(context, MaterialPageRoute(
        builder: (_) => const MapSetWorkView(),
      ));
    } else {
      setState(() { _error = 'Biometria falhou ou usuário não autenticado.'; });
    }
    setState(() { _loading = false; });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _nifController,
              decoration: const InputDecoration(labelText: 'NIF (Email)'),
            ),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Senha'),
              obscureText: true,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loading ? null : _loginNif,
              child: const Text('Entrar com NIF e Senha'),
            ),
            ElevatedButton(
              onPressed: _loading ? null : _loginBiometric,
              child: const Text('Entrar com Biometria'),
            ),
            if (_error != null) ...[
              const SizedBox(height: 16),
              Text(_error!, style: const TextStyle(color: Colors.red)),
            ],
          ],
        ),
      ),
    );
  }
}