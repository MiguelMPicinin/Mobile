import 'package:flutter/material.dart';
import '../controller/categorias_controller.dart';
import '../models/categorias_model.dart';

class AddCategoriaScreen extends StatefulWidget {
  final Categoria? categoria;
  AddCategoriaScreen({this.categoria});

  @override
  State<AddCategoriaScreen> createState() => _AddCategoriaScreenState();
}

class _AddCategoriaScreenState extends State<AddCategoriaScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _limiteController = TextEditingController();
  final CategoriaController _controller = CategoriaController();

  @override
  void initState() {
    super.initState();
    if (widget.categoria != null) {
      _nomeController.text = widget.categoria!.nome;
      _limiteController.text = widget.categoria!.limite?.toString() ?? '';
    }
  }

  void _salvar() async {
    if (_formKey.currentState!.validate()) {
      final categoria = Categoria(
        id: widget.categoria?.id,
        nome: _nomeController.text,
        limite: _limiteController.text.isNotEmpty ? double.tryParse(_limiteController.text) : null,
      );
      if (widget.categoria == null) {
        await _controller.addCategoria(categoria);
      } else {
        await _controller.updateCategoria(categoria);
      }
      Navigator.pop(context, true); // Retorna true para a HomeScreen
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.categoria == null ? 'Nova Categoria' : 'Editar Categoria')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nomeController,
                decoration: InputDecoration(labelText: 'Nome da Categoria'),
                validator: (value) => value == null || value.isEmpty ? 'Informe o nome da categoria' : null,
              ),
              TextFormField(
                controller: _limiteController,
                decoration: InputDecoration(labelText: 'Limite (opcional)'),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _salvar,
                child: Text(widget.categoria == null ? 'Salvar' : 'Atualizar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}