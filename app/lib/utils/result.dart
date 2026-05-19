class Result<T> {
  String? id;
  bool succeed = false;
  String? message;
  T? row;
  List<T>? data;
  Result({required this.succeed, this.message, this.data, this.row});

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'succeed': succeed,
      'message': message,
      'list': data,
      'row': row,
    };
  }
}
