// main.dart (atualizado)
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:form_mobile_avaliativa/views/historico_view.dart';
import 'views/login_view.dart';
import 'views/registro_view.dart';
import 'views/home_view.dart';
import 'views/map_set_work_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Sistema de Ponto',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginView(),
        '/registro': (context) => const RegistroView(),
        '/home': (context) => const HomeView(),
        '/set-work': (context) => const MapSetWorkView(),
        '/history': (context) => const HistoryView(),
      },
    );
  }
}