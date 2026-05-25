import 'package:app/models/user.dart';
import 'package:intl/intl.dart';

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

  String? get postedAt {
    String? formatted;
    final date = DateFormat('dd-MMM-yyy');
    if (createdAt != null) {
      formatted = date.format(createdAt!);
    }
    return formatted;
  }

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
      rating: json['rating'] as int?,
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

class ReviewSummaryData {
  String? context;
  String? contextId;
  int? reviews;
  double? average;
  int? r1;
  int? r2;
  int? r3;
  int? r4;
  int? r5;

  ReviewSummaryData({
    this.context,
    this.contextId,
    this.reviews,
    this.average,
    this.r1,
    this.r2,
    this.r3,
    this.r4,
    this.r5,
  });

  factory ReviewSummaryData.fromJson(Map<String, dynamic> json) {
    return ReviewSummaryData(
      context: json['context'] as String?,
      contextId: json['contextid'] as String?,
      reviews: json['reviews'] as int?,
      average: json['average'] as double?,
      r1: json['r1'] as int?,
      r2: json['r2'] as int?,
      r3: json['r3'] as int?,
      r4: json['r4'] as int?,
      r5: json['r5'] as int?,
    );
  }

  // Object to JSON conversion
  Map<String, dynamic> toJson() {
    return {
      if (context != null) 'context': context,
      if (contextId != null) 'contextid': contextId,
      if (reviews != null) 'reviews': reviews,
      if (average != null) 'average': average,
      if (r1 != null) 'r1': r1,
      if (r2 != null) 'r2': r2,
      if (r3 != null) 'r3': r3,
      if (r4 != null) 'r4': r4,
      if (r5 != null) 'r5': r5,
    };
  }
}
