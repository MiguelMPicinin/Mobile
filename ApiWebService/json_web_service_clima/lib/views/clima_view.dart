import 'package:flutter/material.dart';
import 'package:json_web_service_clima/controllers/clima_controller.dart';
import 'package:json_web_service_clima/models/clima_model.dart';

class ClimaView extends StatefulWidget {
  const ClimaView({super.key});

  @override
  State<ClimaView> createState() => _ClimaViewState();
}

class _ClimaViewState extends State<ClimaView> {
  final TextEditingController _cidadeController = TextEditingController();
  final ClimaController _climaController = ClimaController();
  ClimaModel? _clima;
  String? _erro;

  // método para usar o controller getClima()
  void buscarCidade() async {
    final cidade = _cidadeController.text.trim(); // pega a cidade digitada
    try {
      final resultado = await _climaController.getClima(
        cidade,
      ); // estabelece conexão com a API
      setState(() {
        if (resultado != null) {
          _clima = resultado;
          _erro = null;
          //Scaffold
        } else {
          _clima = null;
          _erro = "Cidade Não Encontrada";
        }
      });
    } catch (e) {
      print("Erro ao estabelecer Conexão: $e");
    }
  }

  //buildar a Tela
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Clima em Tempo Real"),),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _cidadeController,
              decoration: InputDecoration(labelText: "Digite uma Cidade"),
            ),
            ElevatedButton(onPressed: buscarCidade, child: Text("Buscar Clima")),
            Divider(),
            //fazer um if elseif else
            if (_clima !=null) ...[
              Text("Cidade: ${_clima!.cidade}"),
              Text("Temperatura: ${_clima!.temperatura}°C"),
              Text("Descrição: ${_clima!.descricao}")
            ] else if(_erro != null) ...[
              Text(_erro!)
            ] else ...[
              Text("Procure uma Cidade")
            ]
          ],
        ),
        ),
    );
  }
}
