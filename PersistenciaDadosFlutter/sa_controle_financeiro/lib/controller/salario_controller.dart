import '../database/db_helper.dart';

class SalarioController {
  final FinanceiroDBHelper _dbHelper = FinanceiroDBHelper();

  Future<double> getSalario() async {
    return await _dbHelper.getSalario();
  }

  Future<void> setSalario(double valor) async {
    await _dbHelper.setSalario(valor);
  }
}