import 'package:app/models/course.dart';
import 'package:app/models/schedule.dart';
import 'package:app/models/user.dart';

class ReviewData {
  String? id;
  String? context;
  String? contextId;
  String? userId;
  UserBasicData? user;
  int? rating;
  String? content;
  bool? public;
  DateTime? createdAt;

  ReviewData({
    this.id,
    this.context,
    this.contextId,
    this.userId,
    this.user,
    this.rating,
    this.content,
    this.public,
    this.createdAt,
  });

  factory ReviewData.fromJson(Map<String, dynamic> json) {
    return ReviewData(
      id: json['id'] as String?,
      context: json['context'] as String?,
      contextId: json['contextid'] as String?,
      userId: json['userid'] as String?,
      user: UserBasicData.fromJson(json['user']),
      rating: int.parse(json['rating'] ?? '0'),
      content: json['content'] as String?,
      public: json['public'] as bool?,
      createdAt: json['createdat'] != null
          ? DateTime.parse(json['createdat'])
          : null,
    );
  }

  // Object to JSON conversion
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (context != null) 'context': context,
      if (contextId != null) 'contextid': contextId,
      if (userId != null) 'userid': userId,
      if (rating != null) 'rating': rating,
      if (content != null) 'content': content,
      if (public != null) 'public': public,
      if (createdAt != null) 'createdat': createdAt,
    };
  }
}
