class Result<T> {
  String? id;
  bool succeed = false;
  String? message;
  T? row;
  List<T>? list;
  Result({required this.succeed, this.message, this.list, this.row});

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'succeed': succeed,
      'message': message,
      'list': list,
      'row': row,
    };
  }
}
