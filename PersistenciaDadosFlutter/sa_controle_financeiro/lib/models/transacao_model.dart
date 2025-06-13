class Transacao {
  int? id;
  int categoriaId;
  double valor;
  String descricao;
  DateTime data;
  String tipo; // 'despesa' ou 'receita'

  Transacao({
    this.id,
    required this.categoriaId,
    required this.valor,
    required this.descricao,
    required this.data,
    required this.tipo,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'categoriaId': categoriaId,
      'valor': valor,
      'descricao': descricao,
      'data': data.toIso8601String(),
      'tipo': tipo,
    };
  }

  factory Transacao.fromMap(Map<String, dynamic> map) {
    return Transacao(
      id: map['id'],
      categoriaId: map['categoriaId'],
      valor: map['valor'],
      descricao: map['descricao'],
      data: DateTime.parse(map['data']),
      tipo: map['tipo'],
    );
  }
}