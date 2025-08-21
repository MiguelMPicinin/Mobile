//Classe representando o json books
class BooksModels {
  final String id;
  final String title;
  final String author;
  bool avaliable;

  BooksModels({
    required this.id,
    required this.title,
    required this.author,
    required this.avaliable,
  });

  //Métodos
  //toJson
  Map<String, dynamic> toJson() => {
    "id": id,
    "title": title,
    "author": author,
    "avaliable": avaliable,
  };

  //fromJson
  factory BooksModels.formJson(Map<String, dynamic> json) => BooksModels(
    id: json["id"].toString(),
    title: json["title"].toString(),
    author: json["author"].toString(),
    avaliable: json["avaliable"]
  );
}
