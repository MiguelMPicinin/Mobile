class LoanModels {
  final String id;
  final String userId;
  final String bookId;
  final dynamic startDate;
  bool returned;

  LoanModels({
    required this.id,
    required this.userId,
    required this.bookId,
    required this.startDate,
    required this.returned,
  });

  factory LoanModels.fromJson(Map<String, dynamic> json) => LoanModels(
    id: json["id"].toString(),
    userId: json["userId"].toString(),
    bookId: json["bookId"].toString(),
    startDate: json["startDate"].toString(),
    returned: json["returned"],
  );
}
