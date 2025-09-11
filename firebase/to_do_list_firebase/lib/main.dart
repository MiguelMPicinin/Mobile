import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:to_do_list_firebase/firebase_options.dart';
import 'package:to_do_list_firebase/views/autenticacao_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();// garantir a inincialização dos bindigs
  //inicializa o firebase -  ao mesmo tempo que abre as telas
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(MaterialApp(
    title: "Lista de Tarefas",
    home: AutenticacaoView(), //direciona para a tela de aurenticação
  ));
}
