class Nota {
  //atributos
  final int? id; //permite que a variavel seja nula em um primeiro momento
  final String titulo;
  final String conteudo;

  //constuctor
  Nota({this.id, required this.titulo, required this.conteudo});

  //método map // Factory ==> tradução entre banco de dados e objetos

  //converte um objeto da classe nota para um map ( para a inserção no banco de dados )
  Map<String, dynamic> toMap() {
    return {"id": id, "titulo": titulo, "conteudo": conteudo};
  }

  //Converte um Map ( vindo do banco de dados ) => Objeto da Classe Nota
  factory Nota.fromMap(Map<String, dynamic> map) {
    return Nota(
      id: map["id"] as int,
      titulo: map["titulo"] as String,
      conteudo: map["conteudo"] as String
    );
  }
  //Método de impressão
  @override
  String toString() {
    return 'Nota{ id: $id, titulo: $titulo, conteudo: $conteudo }';
  }

  



}
