import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/categorias_model.dart';
import '../models/transacao_model.dart';
// ...restante do código...

class FinanceiroDBHelper {
  static Database? _database;
  static final FinanceiroDBHelper _instance = FinanceiroDBHelper._internal();

  FinanceiroDBHelper._internal();
  factory FinanceiroDBHelper() => _instance;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, "Financeiro.db");
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreateDB,
    );
  }

  Future<void> _onCreateDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE categorias(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nome TEXT NOT NULL,
        limite REAL
      )
    ''');

    await db.execute('''
      CREATE TABLE transacoes(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        categoriaId INTEGER NOT NULL,
        valor REAL NOT NULL,
        descricao TEXT NOT NULL,
        data TEXT NOT NULL,
        tipo TEXT NOT NULL,
        FOREIGN KEY (categoriaId) REFERENCES categorias(id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE salario(
        id INTEGER PRIMARY KEY,
        valor REAL NOT NULL
      )
    ''');

    // Salário inicial padrão
    await db.insert('salario', {'id': 1, 'valor': 0.0});
  }

  // CRUD Categoria
  Future<int> insertCategoria(Categoria categoria) async {
    final db = await database;
    return await db.insert("categorias", categoria.toMap());
  }

  Future<List<Categoria>> getCategorias() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query("categorias");
    return maps.map((e) => Categoria.fromMap(e)).toList();
  }

  Future<int> updateCategoria(Categoria categoria) async {
    final db = await database;
    return await db.update(
      "categorias",
      categoria.toMap(),
      where: "id = ?",
      whereArgs: [categoria.id],
    );
  }

  Future<int> deleteCategoria(int id) async {
    final db = await database;
    return await db.delete("categorias", where: "id=?", whereArgs: [id]);
  }

  // CRUD Transacao
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

  Future<List<Transacao>> getTodasTransacoes() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query("transacoes");
    return maps.map((e) => Transacao.fromMap(e)).toList();
  }

  Future<int> deleteTransacao(int id) async {
    final db = await database;
    return await db.delete("transacoes", where: "id=?", whereArgs: [id]);
  }

  Future<int> updateTransacao(Transacao transacao) async {
    final db = await database;
    return await db.update(
      "transacoes",
      transacao.toMap(),
      where: "id = ?",
      whereArgs: [transacao.id],
    );
  }

  // Salário
  Future<double> getSalario() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query("salario", where: "id = 1");
    if (maps.isNotEmpty) {
      return (maps.first['valor'] as num).toDouble();
    }
    return 0.0;
  }

  Future<void> setSalario(double valor) async {
    final db = await database;
    int count = await db.update("salario", {'valor': valor}, where: "id = 1");
    if (count == 0) {
      await db.insert("salario", {'id': 1, 'valor': valor});
    }
  }
}