import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // Controle do nome e idade
  TextEditingController _nomeController = TextEditingController();
  String _nome = "";
  int _idade = 0;

  // Cor de fundo
  Color _backgroundColor = Colors.white;

  // Cores predefinidas
  final List<Color> _predefinedColors = [
    Colors.blue,
    Colors.red,
    Colors.green,
    Colors.purple,
  ];

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  // Carregar preferências (nome, idade e cor de fundo)
  _loadPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _nome = prefs.getString('nome') ?? "";
      _idade = prefs.getInt('idade') ?? 0;
      _backgroundColor = Color(prefs.getInt('backgroundColor') ?? Colors.white.value);
    });
  }

  // Salvar nome, idade e cor de fundo
  _savePreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('nome', _nomeController.text);
    await prefs.setInt('idade', _idade);
  }

  // Alterar a cor de fundo
  _changeBackgroundColor(Color color) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('backgroundColor', color.value); // Salvar a cor
    setState(() {
      _backgroundColor = color; // Atualizar a cor de fundo
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tema de Fundo',
      home: Scaffold(
        appBar: AppBar(
          title: Text('Alterar Tema e Salvar Dados'),
        ),
        body: Container(
          color: _backgroundColor, // Usar a cor de fundo salva
          padding: EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Entrada de nome
              TextField(
                controller: _nomeController,
                decoration: InputDecoration(labelText: 'Nome'),
              ),
              // Entrada de idade
              TextField(
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  setState(() {
                    _idade = int.tryParse(value) ?? 0;
                  });
                },
                decoration: InputDecoration(labelText: 'Idade'),
              ),
              SizedBox(height: 20),
              // Exibir nome e idade
              Text('Nome: $_nome'),
              Text('Idade: $_idade'),
              SizedBox(height: 20),
              // Botões para alterar a cor de fundo
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: _predefinedColors.map((color) {
                  return IconButton(
                    icon: Icon(Icons.circle, color: color),
                    onPressed: () => _changeBackgroundColor(color),
                  );
                }).toList(),
              ),
              SizedBox(height: 20),
              // Botão para salvar o nome e idade
              ElevatedButton(
                onPressed: _savePreferences,
                child: Text('Salvar Dados'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
