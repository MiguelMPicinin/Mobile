import 'package:exemplo01_shared_preferences/ListaTarefas.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(
    MaterialApp(
      home: MyApp(),
      theme: ThemeData(brightness: Brightness.light),
      darkTheme: ThemeData(brightness: Brightness.dark),
    ),
  );
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  //armazenar dados do TextField
  TextEditingController _nomeController = TextEditingController();
  // Nome que será exibido na tela
  String _nome = "";
  bool _darkMode = false; //variavel de controle do tema do app

  // ação feita ao carregar oa aplicativo
  @override
  void initState() {
    super.initState();
    _carregarPreferencias(); //método para carregar o nome salvo no armazenamento interno
  }

  //método para carregar informações do sharedPreferences -> roda de forma assincrona
  void _carregarPreferencias() async {
    //vou chamar o sharedPreferences -> instalar a dependecia
    SharedPreferences _prefs =
        await SharedPreferences.getInstance(); //pegar as informações salvas no cache do app
    setState(() {
      _nome =
          _prefs.getString("nome") ??
          ""; //pegue a informação da key->nome -> Caso null(??) ""
      _darkMode =
          _prefs.getBool("darkMode") ?? false; //pega o valor do darkMode
    });
  }

  //método para salvar o nome
  void _salvarNome() async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    if (_nomeController.text.trim().isNotEmpty) {
      _prefs.setString("nome", _nomeController.text);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Digite um Nome Válido!")));
    }
    _carregarPreferencias(); //atualizar o nome na tela
    _nomeController.clear(); //limpa o campo de texto
  }

  //método para alterar o tema do app
  void _mudarDarkMode() async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    setState(() {
      _darkMode = !_darkMode; //inverte o valor do darkMode
    });
    _prefs.setBool("darkMode", _darkMode); //salva o valor no SharedPreferences
  }

  //build do app
  @override
  Widget build(BuildContext context) {
    return AnimatedTheme(
      data:
          _darkMode ? ThemeData.dark() : ThemeData.light(), //muda o tema do app
      duration: Duration(milliseconds: 500),
      child: Scaffold(
        appBar: AppBar(
          title: Text("Bem-Vindo ${_nome == "" ? "Visitante" : _nome} "),
          centerTitle: true,
          actions: [
            IconButton(
              icon: Icon(
                _darkMode ? Icons.light_mode : Icons.dark_mode,
              ), //icone do darkMode
              onPressed:
                  () => _mudarDarkMode(), //ao clicar no icone, muda o tema
            ),
          ],
        ),
        body: Center(
          child: Column(
            children: [
              TextField(
                controller: _nomeController,
                decoration: InputDecoration(labelText: "Digite seu Nome"),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => _salvarNome(),
                child: Text("Entrar"),
              ),
              SizedBox(height: 15,),
                ElevatedButton(
                  child: Text("Ver Lista de Tarefas"),
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ListaTarefas())),
                ),
              ],
            ),
          ),
        ),
      );
  }
}
