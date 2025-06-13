import '../models/categorias_model.dart';
import '../database/db_helper.dart';

class CategoriaController {
  final FinanceiroDBHelper _dbHelper = FinanceiroDBHelper();

  Future<int> addCategoria(Categoria categoria) async {
    return await _dbHelper.insertCategoria(categoria);
  }

  Future<List<Categoria>> getCategorias() async {
    return await _dbHelper.getCategorias();
  }

  Future<int> updateCategoria(Categoria categoria) async {
    return await _dbHelper.updateCategoria(categoria);
  }

  Future<int> deleteCategoria(int id) async {
    return await _dbHelper.deleteCategoria(id);
  }
}