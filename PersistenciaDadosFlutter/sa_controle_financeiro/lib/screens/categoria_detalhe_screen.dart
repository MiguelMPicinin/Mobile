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

  @override
  void initState() {
    super.initState();
    _loadTransacoes();
  }

  Future<void> _loadTransacoes() async {
    final transacoes = await _transacaoController.getTransacoesPorCategoria(widget.categoria.id!);
    setState(() {
      _transacoes = transacoes;
    });
  }

  void _showMensagem(String mensagem) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensagem)),
    );
  }

  void _adicionarTransacao() async {
    final resultado = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddTransacaoScreen(
          categoriaId: widget.categoria.id!,
        ),
      ),
    );
    if (resultado == true) {
      _showMensagem('Despesa adicionada com sucesso!');
      _loadTransacoes();
    }
  }

  void _editarTransacao(Transacao transacao) async {
    final resultado = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddTransacaoScreen(
          categoriaId: widget.categoria.id!,
          transacao: transacao,
        ),
      ),
    );
    if (resultado == true) {
      _showMensagem('Despesa atualizada com sucesso!');
      _loadTransacoes();
    }
  }

  void _deletarTransacao(Transacao transacao) async {
    await _transacaoController.deleteTransacao(transacao.id!);
    _showMensagem('Despesa deletada com sucesso!');
    _loadTransacoes();
  }

  double _totalDespesasCategoria() {
    return _transacoes
        .where((t) => t.tipo == 'despesa')
        .fold(0.0, (s, t) => s + t.valor);
  }

  @override
  Widget build(BuildContext context) {
    final totalDespesas = _totalDespesasCategoria();
    final estourouLimite = widget.categoria.limite != null &&
        totalDespesas > (widget.categoria.limite ?? 0);

    return Scaffold(
      appBar: AppBar(title: Text(widget.categoria.nome)),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            title: Text(widget.categoria.nome, style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(
              widget.categoria.limite != null
                  ? 'Limite: R\$ ${widget.categoria.limite!.toStringAsFixed(2)} | Despesas: R\$ ${totalDespesas.toStringAsFixed(2)}'
                  : 'Despesas: R\$ ${totalDespesas.toStringAsFixed(2)}',
              style: TextStyle(
                color: estourouLimite ? Colors.red : null,
                fontWeight: estourouLimite ? FontWeight.bold : null,
              ),
            ),
          ),
          if (estourouLimite)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Limite da categoria ultrapassado!',
                style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
              ),
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
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => _editarTransacao(t),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deletarTransacao(t),
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
        onPressed: _adicionarTransacao,
        child: Icon(Icons.add),
      ),
    );
  }
}