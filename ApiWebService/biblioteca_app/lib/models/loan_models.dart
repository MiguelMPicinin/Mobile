import 'package:flutter/widgets.dart';

class LoanModels {
  final String? id;
  final String userId;
  final String bookId;
  final dynamic startDate;
  bool? returned;

  LoanModels({
    this.id,
    required this.userId,
    required this.bookId,
    required this.startDate,
    this.returned,
  });

    Map<String, dynamic> toJson() => {"id": id, "userId": userId, "bookId": bookId, "startDate": startDate, "returned": returned};


  factory LoanModels.fromJson(Map<String, dynamic> json) => LoanModels(
    id: json["id"].toString(),
    userId: json["userId"].toString(),
    bookId: json["bookId"].toString(),
    startDate: json["startDate"].toString(),
    returned: json["returned"],
  );
}
