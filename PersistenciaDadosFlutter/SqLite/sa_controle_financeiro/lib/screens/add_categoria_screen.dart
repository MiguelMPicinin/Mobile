import 'package:flutter/material.dart';
import '../controller/categorias_controller.dart';
import '../models/categorias_model.dart';

class AddCategoriaScreen extends StatefulWidget {
  @override
  State<AddCategoriaScreen> createState() => _AddCategoriaScreenState();
}

class _AddCategoriaScreenState extends State<AddCategoriaScreen> {
  final _formKey = GlobalKey<FormState>();
  final _alimentacaoController = TextEditingController();
  final _transporteController = TextEditingController();
  final _lazerController = TextEditingController();
  final _salarioController = TextEditingController();
  final CategoriasController _controller = CategoriasController();

  void _salvar() async {
    if (_formKey.currentState!.validate()) {
      final categoria = Categoria(
        alimentacao: double.tryParse(_alimentacaoController.text) ?? 0,
        transporte: double.tryParse(_transporteController.text) ?? 0,
        lazer: double.tryParse(_lazerController.text) ?? 0,
        salario: int.tryParse(_salarioController.text) ?? 0,
      );
      await _controller.addCategoria(categoria);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Novo Limite de Categoria')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _alimentacaoController,
                decoration: InputDecoration(labelText: 'Limite para Alimentação (ex: 500)'),
                keyboardType: TextInputType.number,
                validator: (value) => value!.isEmpty ? 'Informe o limite de alimentação' : null,
              ),
              TextFormField(
                controller: _transporteController,
                decoration: InputDecoration(labelText: 'Limite para Transporte (ex: 700)'),
                keyboardType: TextInputType.number,
                validator: (value) => value!.isEmpty ? 'Informe o limite de transporte' : null,
              ),
              TextFormField(
                controller: _lazerController,
                decoration: InputDecoration(labelText: 'Limite para Lazer (ex: 200)'),
                keyboardType: TextInputType.number,
                validator: (value) => value!.isEmpty ? 'Informe o limite de lazer' : null,
              ),
              TextFormField(
                controller: _salarioController,
                decoration: InputDecoration(labelText: 'Salário (ex: 3500)'),
                keyboardType: TextInputType.number,
                validator: (value) => value!.isEmpty ? 'Informe o salário' : null,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _salvar,
                child: Text('Salvar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}