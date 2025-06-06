import 'package:sqflite/sqflite.dart';
import 'package:sqflite/sqlite_api.dart';
import 'package:path/path.dart';
import '../models/categorias_model.dart';
import '../models/transacao_model.dart';

class FinanceiroDBHelper {
  static Database? _database;
  static final FinanceiroDBHelper _instance = FinanceiroDBHelper._internal();

  FinanceiroDBHelper._internal();
  factory FinanceiroDBHelper() {
    return _instance;
  }

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final _dbPath = await getDatabasesPath();
    final path = join(_dbPath, "Financeiro.db");
    return await openDatabase(path, version: 1, onCreate: _onCreateDB);
  }

  Future<void> _onCreateDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS categorias(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        alimentacao TEXT NOT NULL,
        transporte TEXT NOT NULL,
        lazer TEXT NOT NULL,
        salario INTEGER NOT NULL
      )
    ''');
    print("Tabela categorias criada");

    await db.execute('''
      CREATE TABLE IF NOT EXISTS transacoes(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        categoriaId INTEGER NOT NULL,
        valor REAL NOT NULL,
        descricao TEXT NOT NULL,
        data TEXT NOT NULL,
        tipo TEXT NOT NULL,
        FOREIGN KEY (categoriaId) REFERENCES categorias(id) ON DELETE CASCADE
      )
    ''');
    print("Tabela transacoes criada");
  }

  // CRUD para Categoria
  Future<int> insertCategoria(Categoria categoria) async {
    final db = await database;
    return await db.insert("categorias", categoria.toMap());
  }

  Future<List<Categoria>> getCategorias() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query("categorias");
    return maps.map((e) => Categoria.fromMap(e)).toList();
  }

  Future<int> deleteCategoria(int id) async {
    final db = await database;
    return await db.delete("categorias", where: "id=?", whereArgs: [id]);
  }

  // CRUD para Transacao
  Future<int> insertTransacao(Transacao transacao) async {
    final db = await database;
    return await db.insert("transacoes", transacao.toMap());
  }

  Future<List<Transacao>> getTransacoesPorCategoria(int categoriaId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      "transacoes",
      where: "categoriaId = ?",
      whereArgs: [categoriaId],
      orderBy: "data DESC"
    );
    return maps.map((e) => Transacao.fromMap(e)).toList();
  }

  Future<int> deleteTransacao(int id) async {
    final db = await database;
    return await db.delete("transacoes", where: "id=?", whereArgs: [id]);
  }
}