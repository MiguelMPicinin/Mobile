import 'dart:developer';
import 'package:biblioteca_app/models/loan_models.dart';
import 'package:biblioteca_app/services/api_services.dart';

class LoanController {
  //Métodos
  //GET Todos os usuarios
  Future<List<LoanModels>> fetchAll() async {
    final list = await ApiService.getList("loans?_sort=name");
    //Retorna lista completa de usuariso convertidos em LoanModels
    return list.map<LoanModels>((item) => LoanModels.fromJson(item)).toList();
  }

  //GET Buscar um usuario
  Future<LoanModels> fetchOne(String id) async {
    final user = await ApiService.getOne("loans", id);
    //Retorna um unico usuario
    return LoanModels.fromJson(user);
  }

  //POST -> criar novo usuario
  Future<LoanModels> create(LoanModels u) async {
    final created = await ApiService.post("loans", u.toJson());
    //Adiciona um usuario novo e retorna o usuario novo
    return LoanModels.fromJson(created);
  }

  // PUT - Atualizar
  Future<LoanModels> update(LoanModels u) async {
    final updated = await ApiService.put("loans", u.toJson(), u.id!);
    return LoanModels.fromJson(updated);
  }

  //DELETE - Apagar USuario
  Future<void> delete(String id) async {
    await ApiService.delete("loans", id);
    //não ha retorno, o usuario ja foi deletado
  }
}
