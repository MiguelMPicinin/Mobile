import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:to_do_list_firebase/views/login_view.dart';
import 'package:to_do_list_firebase/views/tarefas_view.dart';

//Tela que direciona o usuario de acordo com o Status de autenticação
class AutenticacaoView extends StatelessWidget {
  const AutenticacaoView({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      //classe User é modelo pronto do firebase auth
      //A Mudança de tela é determinada pela conexão do usuario ao Firebase_Auth
      stream: FirebaseAuth.instance.authStateChanges(),
      //Snapshot == cache, explicando mais detalhatamente é como o Listener do JavaScript
      builder: (context, snapshot) {
        //Se o snapshot contem dados do usuario
        if (snapshot.hasData) {
          //Direciona o usuario para a tela de tarefas
          return TarefasView();
        }
        //caso contrario
        //Direciona para a tela de login
        else{
          return LoginView();
        }
      },
    );
  }
}
