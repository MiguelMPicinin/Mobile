import 'package:flutter/material.dart';
import '../models/categorias_model.dart';
import '../controller/transacao_controller.dart';
import '../models/transacao_model.dart';
import 'add_transacao_screen.dart';

class CategoriaDetalheScreen extends StatefulWidget {
  final Categoria categoria;
  CategoriaDetalheScreen({required this.categoria});

  @override
  State<CategoriaDetalheScreen> createState() => _CategoriaDetalheScreenState();
}

class _CategoriaDetalheScreenState extends State<CategoriaDetalheScreen> {
  final TransacaoController _transacaoController = TransacaoController();
  List<Transacao> _transacoes = [];
  double _gastoAlimentacao = 0;
  double _gastoTransporte = 0;
  double _gastoLazer = 0;

  @override
  void initState() {
    super.initState();
    _loadTransacoes();
  }

  Future<void> _loadTransacoes() async {
    final transacoes = await _transacaoController.getTransacoesPorCategoria(widget.categoria.id!);
    setState(() {
      _transacoes = transacoes;
      // Modificado: cálculo dos gastos por categoria
      _gastoAlimentacao = _transacoes
          .where((t) => t.descricao.toLowerCase().contains('alimentação') && t.tipo == 'despesa')
          .fold(0.0, (s, t) => s + t.valor);
      _gastoTransporte = _transacoes
          .where((t) => t.descricao.toLowerCase().contains('transporte') && t.tipo == 'despesa')
          .fold(0.0, (s, t) => s + t.valor);
      _gastoLazer = _transacoes
          .where((t) => t.descricao.toLowerCase().contains('lazer') && t.tipo == 'despesa')
          .fold(0.0, (s, t) => s + t.valor);
    });
  }

  void _goToAddTransacao() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddTransacaoScreen(categoriaId: widget.categoria.id!),
      ),
    );
    _loadTransacoes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Detalhes da Categoria')),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            title: Text('Limites:'),
            subtitle: Text(
                'Alimentação: ${widget.categoria.alimentacao} | Transporte: ${widget.categoria.transporte} | Lazer: ${widget.categoria.lazer} | Salário: ${widget.categoria.salario}'),
          ),
          // Modificado: avisos em vermelho se ultrapassar limite
          if (_gastoAlimentacao > widget.categoria.alimentacao)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text('Limite de Alimentação ultrapassado!',
                  style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
            ),
          if (_gastoTransporte > widget.categoria.transporte)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text('Limite de Transporte ultrapassado!',
                  style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
            ),
          if (_gastoLazer > widget.categoria.lazer)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text('Limite de Lazer ultrapassado!',
                  style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
            ),
          Divider(),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text('Transações:', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _transacoes.length,
              itemBuilder: (context, index) {
                final t = _transacoes[index];
                return ListTile(
                  title: Text('${t.descricao} (${t.tipo})'),
                  subtitle: Text('Valor: ${t.valor} - Data: ${t.data.toString().split(" ")[0]}'),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _goToAddTransacao,
        child: Icon(Icons.add),
      ),
    );
  }
}