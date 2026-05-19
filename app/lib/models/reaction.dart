class ReactionData {
  String? id;
  String? type;
  String? userId;
  String? context;
  String? contextId;

  ReactionData({this.id, this.type, this.userId, this.context, this.contextId});

  factory ReactionData.fromJson(Map<String, dynamic> json) {
    return ReactionData(
      id: json['id'] as String?,
      type: json['type'] as String?,
      userId: json['userid'] as String?,
      context: json['context'] as String?,
      contextId: json['contextid'] as String?,
    );
  }

  // Object to JSON conversion
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'userid': userId,
      'context': context,
      'contextid': contextId,
    };
  }
}
