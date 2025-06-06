import 'package:flutter/material.dart';
import 'package:sa04_widget_navegacao/view/tela_cadastro_view.dart';
import 'package:sa04_widget_navegacao/view/tela_confirmacao_view.dart';
import 'package:sa04_widget_navegacao/view/tela_inicial_view.dart';

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    initialRoute: "/",
    routes: { //3 telas de navegação do App
      "/": (context) => TelaInicialView(),
      "/cadastro":(context) => TelaCadastroView(),
      "/confirmação":(context) => TelaConfirmacaoView()
    },
  ));
}

//quando era uma unica tela -> continuava na Class