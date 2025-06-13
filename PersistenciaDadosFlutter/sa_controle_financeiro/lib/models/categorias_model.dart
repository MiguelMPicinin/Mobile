class Categoria {
  int? id;
  String nome;
  double? limite; // Limite opcional

  Categoria({this.id, required this.nome, this.limite});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'limite': limite,
    };
  }

  factory Categoria.fromMap(Map<String, dynamic> map) {
    return Categoria(
      id: map['id'],
      nome: map['nome'],
      limite: map['limite'] != null ? (map['limite'] as num).toDouble() : null,
    );
  }
}