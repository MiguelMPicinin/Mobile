import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:json_shared_preferences/config_page.dart';
import 'package:shared_preferences/shared_preferences.dart'; //Biblioteca instalada no pubspec atraves do comando (flutter pub add)

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _MyAppState();
  }
}

class _MyAppState extends State<MyApp> {
  //atributos
  bool temaEscuro = false;
  String nomeUsuario = "";

  // para carregar informações no começo da aplicação
  @override
  void initState() {
    super.initState();
    carregarPreferencias();
  }

  //Metodos aync servem para não travar a aplicação enquanto carrega novas informações, ele realiza atividades de forma Asincrona
  void carregarPreferencias() async {
    //conexão com o cache para pegar informações armazenadas pelo o usuario
    final prefs = await SharedPreferences.getInstance();
    //armazenando em um texto as configurações salvas
    String? jsonString = prefs.getString('config');
    if (jsonString != null) {
      //converter o texto/json em map/dart
      Map<String, dynamic> config = json.decode(jsonString);
      //Chama a mudança de estado
      setState(() {
        //atribui a bollean a chave tema escuro caso nulo atribui falso
        temaEscuro = config["tema escuro"] ?? false;
        nomeUsuario = config["nome"] ?? "";
      });
    }
  } //fim do metodo

  //método build
  @override
  Widget build(BuildContext context) {
    return (MaterialApp(
      title: "App de Configuração",
      //Operador Ternario
      theme: temaEscuro ? ThemeData.dark() : ThemeData.light(),
      home: ConfigPage(
        temaEscuro: temaEscuro,
        nomeUsuario: nomeUsuario,
        onSalvar: (bool novoTema, String novoNome) {
          setState(() {
            temaEscuro = novoTema;
            nomeUsuario = novoNome;
          });
        }
      ),
    ));
  }
}
