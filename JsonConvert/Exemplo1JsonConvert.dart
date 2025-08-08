// Exemplo de Teste de Conversão Json

import 'dart:convert'; //biblioteca para o funcionamento

void main() {
  //texto em formado JSON
  String DbJson = '''{
      "id": 1,
      "nome": "João",
      "login": "joao_user",
      "ativo": true,
      "senha": 1234
                  } ''';

  //Convertendo texto JSON -> map(dart)
  Map<String, dynamic> usuario = json.decode(DbJson);

  print(usuario["login"]);

  //mudar a senha para 1111

  usuario["senha"] = 1111;

  //fazer o encode -> map(dart) -> texto JSON

  DbJson = json.encode(usuario);

  //printar o json

  print(DbJson);
}
