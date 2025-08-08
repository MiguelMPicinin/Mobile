import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ConfigPage extends StatefulWidget {
  //atributos
  final bool temaEscuro;
  final String nomeUsuario;
  final Function(bool, String) onSalvar;

  //construtor
  ConfigPage({
    required this.temaEscuro,
    required this.nomeUsuario,
    required this.onSalvar,
  });

  @override
  State<StatefulWidget> createState() {
    return _ConfigPageState();
  }
}

class _ConfigPageState extends State<ConfigPage> {
  //Atributos
  //late -> inicialmente null -> vai receber o valor depois
  late bool _temaEscuro;
  //Receber dados de Campos de Formulario
  late TextEditingController _nomeController;

  @override
  void initState() {
    super.initState();
    //atribui valor da String/json
    _temaEscuro = widget.temaEscuro;
    _nomeController = TextEditingController(text: widget.nomeUsuario);
  }

  //método para salvar as configurações do usuario
  void salvarConfiguracoes() async {
    Map<String, dynamic> config = {
      "temaEscuro": _temaEscuro,
      "nome": _nomeController.text.trim(),
    };
    //chama o Shared Preferences
    //Converte a MAP => String/Json
    //Salva o valor no SharedPreferences para a Chave "config"
    final prefs = await SharedPreferences.getInstance();
    String jsonString = json.encode(config);
    prefs.setString("config", jsonString);

    //Chama a atualização
    widget.onSalvar(_temaEscuro, _nomeController.text.trim());
  }

  //construção dos Widgets
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Preferencias do Usuário")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            SwitchListTile(
              title: Text("Tema Escuro"),
              value: _temaEscuro,
              onChanged: (bool value) {
                setState(() {
                  _temaEscuro = value;
                });
              },
            ),
            TextField(
              controller: _nomeController,
              decoration: InputDecoration(labelText: "Nome do Usuario"),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                salvarConfiguracoes();
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text("Preferencias Salvas")));
              },
              child: Text("Salvar Preferencias"),
            ),
            SizedBox(height: 40,),
            Divider(),
            Text("Resumo Atual: ",
            style: TextStyle(fontWeight: FontWeight.bold
            ),
            
            ),
            SizedBox(height: 10,),
            Text("Tema: ${_temaEscuro ? "Escuro" : "Claro"}"),
            Text("Usuario: ${_nomeController.text}"),
            
          ],
        ),
      ),
    );
  }
}
