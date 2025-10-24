// views/login_view.dart
import 'package:flutter/material.dart';
import 'package:form_mobile_avaliativa/views/home_view.dart';
import 'package:form_mobile_avaliativa/views/registro_view.dart';
import 'package:form_mobile_avaliativa/views/map_set_work_view.dart';
import 'package:form_mobile_avaliativa/views/map_points_view.dart';
import '../controllers/firebase_controller.dart';
import '../controllers/point_controller.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _firebaseController = FirebaseController();
  final _pointController = PointController();
  bool _loading = false;
  String? _error;

  void _loginEmail() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      setState(() {
        _error = 'Preencha todos os campos';
      });
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      await _firebaseController.signInWithEmailAndPassword(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );
      
      if (_firebaseController.currentUser != null) {
        // Verificar se já tem local de trabalho definido
        final workLocation = await _pointController.fetchWorkLocation(
          _firebaseController.currentUser!.uid
        );
        
        if (workLocation != null) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const HomeView()),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const HomeView()),
          );
        }
      }
    } catch (e) {
      setState(() {
        _error = 'Falha ao autenticar: $e';
      });
    }
    setState(() {
      _loading = false;
    });
  }

  void _loginBiometric() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      bool ok = await _firebaseController.authenticateWithBiometrics();
      if (ok && _firebaseController.currentUser != null) {
        final workLocation = await _pointController.fetchWorkLocation(
          _firebaseController.currentUser!.uid
        );
        
        if (workLocation != null) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const MapPointsView()),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const MapSetWorkView()),
          );
        }
      } else {
        setState(() {
          _error = 'Biometria falhou ou usuário não autenticado.';
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Erro na biometria: $e';
      });
    }
    setState(() {
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.work_outline,
              size: 80,
              color: Colors.blue,
            ),
            const SizedBox(height: 20),
            const Text(
              'Registro de Ponto',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 30),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                prefixIcon: Icon(Icons.email),
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(
                labelText: 'Senha',
                prefixIcon: Icon(Icons.lock),
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            if (_loading) ...[
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
            ],
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _loading ? null : _loginEmail,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
                child: const Text('Entrar com Email e Senha'),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: _loading ? null : _loginBiometric,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.fingerprint),
                    SizedBox(width: 8),
                    Text('Entrar com Biometria'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const RegistroView()),
                );
              },
              child: const Text("Ainda não tem conta? Registre-se!!!"),
            ),
            if (_error != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error, color: Colors.red),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _error!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}