import 'dart:convert';

import 'package:http/http.dart' as http;

class ApiService {
  //base url com Conexão com API
  static const String _baseURL = "http://10.109.197.31:3014";

  //métodos da classe e não do obj => não instanciar obj
  //GET ( Listar Todos )
  static Future<List<dynamic>> getList(String path) async {
    final res = await http.get(Uri.parse("$_baseURL/$path"));
    if (res.statusCode == 200)
      return json.decode(res.body); // Se deu certo interrompe o codigo aqui
    throw Exception(
      "Falha ao carregar Lista de $path",
    ); // Se o if não deu certo -> gerar um erro
  }

  //GET ( Listar Apenas um Unico Recurso )
  static Future<Map<String, dynamic>> getOne(String path, String id) async {
    final res = await http.get(Uri.parse("$_baseURL/$path/$id"));
    if (res.statusCode == 200) return json.decode(res.body);
    //se não deu certo
    throw Exception("Falha ao Carregar Recurso de $path");
  }

  //POST ( Criar um novo Recurso )
  static Future<Map<String, dynamic>> post(
    String path,
    Map<String, dynamic> body,
  ) async {
    final res = await http.post(
      Uri.parse("$_baseURL/$path"),
      headers: {"Content-Type": "application/json"},
      body: json.encode(body),
    );
    if (res.statusCode == 201) return json.decode(res.body);
    throw Exception("Falha ao criar em $path");
  }

  //PUT ( Atualizar o Recurso )
  static Future<Map<String, dynamic>> put(
    String path,
    Map<String, dynamic> body,
    String id,
  ) async {
    final res = await http.put(
      Uri.parse("$_baseURL/$path/$id"),
      headers: {"Content-Type": "application/json"},
      body: json.encode(body),
    );
    if (res.statusCode == 201) return json.decode(res.body);
    throw Exception("Falha ao Atualizar em $path");
  }

  //DELETE ( Apagar um recurso )
  static delete(String path, String id) async {
    final res = await http.delete(Uri.parse("$_baseURL/$path/$id"));
    if (res.statusCode != 200) throw Exception("Falha ao deletar de $path");
  }
}
