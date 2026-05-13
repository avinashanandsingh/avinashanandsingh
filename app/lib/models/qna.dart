class OptionData {
  String? id;
  String? questionId;
  String? title;
  int? sort;
  bool? isChecked;

  OptionData({
    this.id = '',
    this.questionId = '',
    this.title = '',
    this.sort = 0,
    this.isChecked = false,
  });

  factory OptionData.fromJson(Map<String, dynamic> json) {
    return OptionData(
      id: json['id'] as String?,
      questionId: json['questionid'] as String?,
      title: json['title'] as String?,
      sort: (json['sort'] ?? 0) as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'questionid': questionId,
      'title': title,
      'sort': sort,
      'checked': isChecked,
    };
  }
}

class QnaData {
  String? id;
  String? courseid;
  String? type;
  String? title;
  String? description;
  String? status;
  List<OptionData>? options;
  QnaData({
    this.id,
    this.courseid,
    this.type,
    this.title,
    this.description,
    this.status,
    this.options,
  });

  factory QnaData.fromJson(Map<String, dynamic> json) {
    List<OptionData> lst = List.empty(growable: true);
    if (json['options'] != null) {
      for (var item in json['options']) {
        lst.add(OptionData.fromJson(item));
      }
    }
    lst.sort((a, b) => a.sort!.compareTo(b.sort!));
    return QnaData(
      id: json['id'] as String?,
      courseid: json['id'] as String?,
      type: json['type'] as String?,
      title: json['title'] as String?,
      description: json['description'] as String?,
      status: json['status'] as String?,
      options: lst,
    );
  }

  // Object to JSON conversion
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      if (courseid != null) 'courseid': courseid,
      if (type != null) 'type': type,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (status != null) 'status': status,
      if (options != null) 'options': options!.map((e) => e.toJson()),
    };
  }
}
