class Pet {
  final int?
  id; // Permite valores nulos na criação de objetos( id gerado pelo BD, pode ser null na criação do objeto )
  final String nome;
  final String raca;
  final String nomeDono;
  final String telefoneDono;

  // Construtor( serve para instanciar objetos da classe )
  Pet({
    this.id, // id pode ser nulo não é obrigatorio
    required this.nome, //ja os outros são obrigadorios e não podem ser nulos
    required this.raca,
    required this.nomeDono,
    required this.telefoneDono,
  });

  //converter um Objeto em um map util para inserir as informações no Banco de Dados
  Map<String, dynamic> toMap() {
    //tabela não ordenada, é buscada por chave, ( dynamic serve para ordenar cada tipo de dado em umma coluna nome-string id-int etc)
    return {
      "id": id,
      "Nome": nome,
      "raca": raca,
      "nome_dono": nomeDono,
      "telefone_dono": telefoneDono,
    };
  }

  //Criar um Objeto a partir de um map, irá ler uma informação do banco de Dados e transformar em um objeto
  factory Pet.fromMap(Map<String, dynamic> map) {
    return Pet(
      id: map["id"] as int,
      nome: map["nome"] as String,
      raca: map["raca"] as String,
      nomeDono: map["nome_dono"] as String,
      telefoneDono: map["telefone_dono"] as String,
    );
  }

  @override
  String toString() {
    return "Pet{id: $id, nome: $nome, raça: $raca,Dono: $nomeDono, Telefone: $telefoneDono}";
  }
}
