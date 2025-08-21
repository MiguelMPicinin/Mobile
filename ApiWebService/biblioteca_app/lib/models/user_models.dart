class UserModels {
  final String? id;
  final String name;
  final String email;

  UserModels({this.id, required this.name, required this.email});

  //Métodos
  //toJson
  Map<String, dynamic> toJson() => {"id": id, "name": name, "email": email};

  //fromJson
  factory UserModels.fromJson(Map<String, dynamic> json) => UserModels(
    id: json["id"].toString(),
    name: json["name"].toString(),
    email: json["email"].toString(),
  );
}
