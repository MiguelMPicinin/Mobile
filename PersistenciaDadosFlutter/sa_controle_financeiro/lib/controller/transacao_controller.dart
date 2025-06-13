import '../models/transacao_model.dart';
import '../database/db_helper.dart';

class TransacaoController {
  final FinanceiroDBHelper _dbHelper = FinanceiroDBHelper();

Future<List<Transacao>> getTodasTransacoes() async {
  return await _dbHelper.getTodasTransacoes();
}

  Future<int> addTransacao(Transacao transacao) async {
    return await _dbHelper.insertTransacao(transacao);
  }

  Future<List<Transacao>> getTransacoesPorCategoria(int categoriaId) async {
    return await _dbHelper.getTransacoesPorCategoria(categoriaId);
  }

  Future<int> deleteTransacao(int id) async {
    return await _dbHelper.deleteTransacao(id);
  }

  Future<int> updateTransacao(Transacao transacao) async {
    return await _dbHelper.updateTransacao(transacao);
  }
}