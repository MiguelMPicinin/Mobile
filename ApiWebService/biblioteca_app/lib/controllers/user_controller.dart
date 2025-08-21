import 'dart:developer';
import 'package:biblioteca_app/models/user_models.dart';
import 'package:biblioteca_app/services/api_services.dart';

class UserController {
  //Métodos
  //GET Todos os usuarios
  Future<List<UserModels>> fetchAll() async {
    final list = await ApiService.getList("users?_sort=name");
    //Retorna lista completa de usuariso convertidos em UserModels
    return list.map<UserModels>((item) => UserModels.fromJson(item)).toList();
  }

  //GET Buscar um usuario
  Future<UserModels> fetchOne(String id) async {
    final user = await ApiService.getOne("users", id);
    //Retorna um unico usuario
    return UserModels.fromJson(user);
  }

  //POST -> criar novo usuario
  Future<UserModels> create(UserModels u) async {
    final created = await ApiService.post("users", u.toJson());
    //Adiciona um usuario novo e retorna o usuario novo
    return UserModels.fromJson(created);
  }

  // PUT - Atualizar
  Future<UserModels> update(UserModels u) async {
    final updated = await ApiService.put("users", u.toJson(), u.id!);
    return UserModels.fromJson(updated);
  }

  //DELETE - Apagar USuario
  Future<void> delete(String id) async {
    await ApiService.delete("users", id);
    //não ha retorno, o usuario ja foi deletado
  }
}
