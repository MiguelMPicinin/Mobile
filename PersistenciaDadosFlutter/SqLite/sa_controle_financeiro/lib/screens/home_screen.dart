import 'package:flutter/material.dart';
import '../controller/categorias_controller.dart';
import '../models/categorias_model.dart';
import 'add_categoria_screen.dart';
import 'categoria_detalhe_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final CategoriasController _categoriasController = CategoriasController();
  List<Categoria> _categorias = [];

  @override
  void initState() {
    super.initState();
    _loadCategorias();
  }

  Future<void> _loadCategorias() async {
    final categorias = await _categoriasController.getCategorias();
    setState(() {
      _categorias = categorias;
    });
  }

  void _goToAddCategoria() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => AddCategoriaScreen()),
    );
    _loadCategorias();
  }

  void _goToDetalhe(Categoria categoria) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => CategoriaDetalheScreen(categoria: categoria)),
    );
    _loadCategorias();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Categorias')),
      body: ListView.builder(
        itemCount: _categorias.length,
        itemBuilder: (context, index) {
          final cat = _categorias[index];
          return ListTile(
            title: Text('Alimentação: ${cat.alimentacao}'),
            subtitle: Text('Transporte: ${cat.transporte}, Lazer: ${cat.lazer}, Salário: ${cat.salario}'),
            onTap: () => _goToDetalhe(cat),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _goToAddCategoria,
        child: Icon(Icons.add),
      ),
    );
  }
}