class Categoria {
  int? id;
  double alimentacao;
  double transporte;
  double lazer;
  int salario;

  Categoria({
    this.id,
    required this.alimentacao,
    required this.transporte,
    required this.lazer,
    required this.salario,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'alimentacao': alimentacao,
      'transporte': transporte,
      'lazer': lazer,
      'salario': salario,
    };
  }

  factory Categoria.fromMap(Map<String, dynamic> map) {
    return Categoria(
      id: map['id'],
      alimentacao: map['alimentacao'] is int ? (map['alimentacao'] as int).toDouble() : map['alimentacao'],
      transporte: map['transporte'] is int ? (map['transporte'] as int).toDouble() : map['transporte'],
      lazer: map['lazer'] is int ? (map['lazer'] as int).toDouble() : map['lazer'],
      salario: map['salario'],
    );
  }
}