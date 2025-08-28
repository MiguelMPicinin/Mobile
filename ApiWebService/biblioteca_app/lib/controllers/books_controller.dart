import 'dart:developer';
import 'package:biblioteca_app/models/books_models.dart';
import 'package:biblioteca_app/services/api_services.dart';

class BooksController {
  //Métodos
  //GET Todos os usuarios
  Future<List<BooksModels>> fetchAll() async {
    final list = await ApiService.getList("books?_sort=name");
    //Retorna lista completa de usuariso convertidos em BooksModels
    return list.map<BooksModels>((item) => BooksModels.fromJson(item)).toList();
  }

  //GET Buscar um usuario
  Future<BooksModels> fetchOne(String id) async {
    final books = await ApiService.getOne("books", id);
    //Retorna um unico usuario
    return BooksModels.fromJson(books);
  }

  //POST -> criar novo usuario
  Future<BooksModels> create(BooksModels u) async {
    final created = await ApiService.post("books", u.toJson());
    //Adiciona um usuario novo e retorna o usuario novo
    return BooksModels.fromJson(created);
  }

  // PUT - Atualizar
  Future<BooksModels> update(BooksModels u) async {
    final updated = await ApiService.put("books", u.toJson(), u.id!);
    return BooksModels.fromJson(updated);
  }

  //DELETE - Apagar USuario
  Future<void> delete(String id) async {
    await ApiService.delete("books", id);
    //não ha retorno, o usuario ja foi deletado
  }
}
