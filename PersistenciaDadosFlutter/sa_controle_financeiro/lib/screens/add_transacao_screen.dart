import 'package:flutter/material.dart';
import '../controller/transacao_controller.dart';
import '../models/transacao_model.dart';

class AddTransacaoScreen extends StatefulWidget {
  final int categoriaId;
  final Transacao? transacao;

  AddTransacaoScreen({required this.categoriaId, this.transacao});

  @override
  State<AddTransacaoScreen> createState() => _AddTransacaoScreenState();
}

class _AddTransacaoScreenState extends State<AddTransacaoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _valorController = TextEditingController();
  final _descricaoController = TextEditingController();
  DateTime _data = DateTime.now();
  String _tipo = 'despesa';
  final TransacaoController _controller = TransacaoController();

  @override
  void initState() {
    super.initState();
    if (widget.transacao != null) {
      _valorController.text = widget.transacao!.valor.toString();
      _descricaoController.text = widget.transacao!.descricao;
      _data = widget.transacao!.data;
      _tipo = widget.transacao!.tipo;
    }
  }

  void _salvar() async {
    if (_formKey.currentState!.validate()) {
      if (widget.transacao == null) {
        // Nova transação
        final transacao = Transacao(
          categoriaId: widget.categoriaId,
          valor: double.tryParse(_valorController.text) ?? 0,
          descricao: _descricaoController.text,
          data: _data,
          tipo: _tipo,
        );
        await _controller.addTransacao(transacao);
      } else {
        // Editar transação
        final transacao = Transacao(
          id: widget.transacao!.id,
          categoriaId: widget.categoriaId,
          valor: double.tryParse(_valorController.text) ?? 0,
          descricao: _descricaoController.text,
          data: _data,
          tipo: _tipo,
        );
        await _controller.updateTransacao(transacao);
      }
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.transacao == null ? 'Nova Transação' : 'Editar Transação')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _valorController,
                decoration: InputDecoration(labelText: 'Valor'),
                keyboardType: TextInputType.number,
                validator: (value) => value!.isEmpty ? 'Informe o valor' : null,
              ),
              TextFormField(
                controller: _descricaoController,
                decoration: InputDecoration(labelText: 'Descrição'),
                validator: (value) => value!.isEmpty ? 'Informe a descrição' : null,
              ),
              DropdownButtonFormField<String>(
                value: _tipo,
                items: [
                  DropdownMenuItem(value: 'despesa', child: Text('Despesa')),
                  DropdownMenuItem(value: 'receita', child: Text('Receita')),
                ],
                onChanged: (v) => setState(() => _tipo = v!),
                decoration: InputDecoration(labelText: 'Tipo'),
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  Text('Data: ${_data.toString().split(" ")[0]}'),
                  Spacer(),
                  TextButton(
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _data,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) setState(() => _data = picked);
                    },
                    child: Text('Selecionar Data'),
                  ),
                ],
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _salvar,
                child: Text(widget.transacao == null ? 'Salvar' : 'Atualizar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}