//Classe representando o json books
class BooksModels {
  final String? id;
  final String title;
  final String author;
  bool avaliable;

  BooksModels({
    this.id,
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
  factory BooksModels.fromJson(Map<String, dynamic> map) => BooksModels(
    id: map["id"].toString(),
    title: map["title"].toString(),
    author: map["author"].toString(),
    avaliable: map["avaliable"] == true ? true : false
  );
}
