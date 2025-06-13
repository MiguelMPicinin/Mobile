import 'package:flutter/material.dart';
import '../controller/categorias_controller.dart';
import '../controller/transacao_controller.dart';
import '../controller/salario_controller.dart';
import '../models/categorias_model.dart';
import '../models/transacao_model.dart';
import 'add_categoria_screen.dart';
import 'categoria_detalhe_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final CategoriaController _categoriaController = CategoriaController();
  final TransacaoController _transacaoController = TransacaoController();
  final SalarioController _salarioController = SalarioController();

  List<Categoria> _categorias = [];
  double _salario = 0.0;
  double _totalDespesas = 0.0;
  List<Transacao> _todasTransacoes = [];
  bool _carregando = true;

  @override
  void initState() {
    super.initState();
    _totalDespesas = 0.0;
    _loadAll();
  }

  Future<void> _loadAll() async {
    final categorias = await _categoriaController.getCategorias();
    final transacoes = await _transacaoController.getTodasTransacoes();
    final salario = await _salarioController.getSalario();

    double totalDespesas = 0.0;
    if (transacoes.isNotEmpty) {
      totalDespesas = transacoes
          .where((t) => t.tipo == 'despesa')
          .fold(0.0, (s, t) => s + t.valor);
    }

    setState(() {
      _categorias = categorias;
      _salario = salario;
      _totalDespesas = totalDespesas;
      _todasTransacoes = transacoes;
      _carregando = false;
    });
  }

  void _showMensagem(String mensagem) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensagem)),
    );
  }

  void _goToAddCategoria({Categoria? categoria}) async {
    final resultado = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => AddCategoriaScreen(categoria: categoria)),
    );
    if (resultado == true) {
      _showMensagem(
        categoria == null
            ? 'Categoria adicionada com sucesso!'
            : 'Categoria atualizada com sucesso!',
      );
      await _loadAll(); // Atualiza a lista imediatamente
    }
  }

  void _goToDetalhe(Categoria categoria) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => CategoriaDetalheScreen(categoria: categoria)),
    );
    await _loadAll(); // Recalcula totais ao voltar da tela de detalhes
  }

  void _editarSalario() async {
    final controller = TextEditingController(text: _salario.toString());
    final result = await showDialog<double>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Editar Salário'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(labelText: 'Novo salário'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancelar')),
          TextButton(
            onPressed: () {
              final valor = double.tryParse(controller.text) ?? _salario;
              Navigator.pop(context, valor);
            },
            child: Text('Salvar'),
          ),
        ],
      ),
    );
    if (result != null) {
      await _salarioController.setSalario(result);
      _showMensagem('Salário atualizado com sucesso!');
      await _loadAll();
    }
  }

  void _deletarCategoria(Categoria categoria) async {
    await _categoriaController.deleteCategoria(categoria.id!);
    _showMensagem('Categoria deletada com sucesso!');
    await _loadAll();
  }

  double _totalDespesasCategoria(Categoria categoria) {
    return _todasTransacoes
        .where((t) => t.categoriaId == categoria.id && t.tipo == 'despesa')
        .fold(0.0, (s, t) => s + t.valor);
  }

  @override
  Widget build(BuildContext context) {
    final endividado = _totalDespesas > _salario;
    if (_carregando) {
      return Scaffold(
        appBar: AppBar(title: Text('Categorias')),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_categorias.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Categorias'),
          actions: [
            IconButton(
              icon: Icon(Icons.attach_money),
              onPressed: _editarSalario,
              tooltip: 'Editar Salário',
            ),
          ],
        ),
        body: Center(
          child: ElevatedButton.icon(
            icon: Icon(Icons.add),
            label: Text('Cadastrar Categoria'),
            onPressed: () => _goToAddCategoria(),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Categorias'),
        actions: [
          IconButton(
            icon: Icon(Icons.attach_money),
            onPressed: _editarSalario,
            tooltip: 'Editar Salário',
          ),
        ],
      ),
      body: Column(
        children: [
          ListTile(
            title: Text('Salário: R\$ ${_salario.toStringAsFixed(2)}'),
            subtitle: Text('Total de despesas: R\$ ${_totalDespesas.toStringAsFixed(2)}'),
          ),
          if (endividado)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Você está endividado!',
                style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
              ),
            ),
          Expanded(
            child: ListView.builder(
              itemCount: _categorias.length,
              itemBuilder: (context, index) {
                final cat = _categorias[index];
                final despesasCat = _totalDespesasCategoria(cat);
                final estourouLimite = cat.limite != null && despesasCat > (cat.limite ?? 0);
                return ListTile(
                  title: Text(
                    cat.nome,
                    style: TextStyle(
                      color: estourouLimite ? Colors.red : null,
                      fontWeight: estourouLimite ? FontWeight.bold : null,
                    ),
                  ),
                  subtitle: cat.limite != null
                      ? Text('Limite: R\$ ${cat.limite!.toStringAsFixed(2)} | Despesas: R\$ ${despesasCat.toStringAsFixed(2)}')
                      : Text('Despesas: R\$ ${despesasCat.toStringAsFixed(2)}'),
                  onTap: () => _goToDetalhe(cat),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => _goToAddCategoria(categoria: cat),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deletarCategoria(cat),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _goToAddCategoria(),
        child: Icon(Icons.add),
      ),
    );
  }
}