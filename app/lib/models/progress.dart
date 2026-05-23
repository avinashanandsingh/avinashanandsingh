class ProgressData {
  String? id;
  String? enrollmentId;
  Map<String, dynamic>? enrollment;
  String? moduleId;
  Map<String, dynamic>? module;
  String? timeSpent;
  bool? completed;
  DateTime? completedAt;

  ProgressData({
    this.id,
    this.enrollmentId,
    this.enrollment,
    this.moduleId,
    this.module,
    this.timeSpent,
    this.completed,
    this.completedAt,
  });

  factory ProgressData.fromJson(Map<String, dynamic> json) {
    return ProgressData(
      id: json['id'] as String?,
      enrollmentId: json['enrollmentid'] as String?,
      enrollment: json['enrollment'],
      moduleId: json['moduleid'] as String?,
      module: json['module'],
      timeSpent: json['time_spent'] as String?,
      completed: json['completed'] as bool?,
      completedAt: json['completedat'] != null
          ? DateTime.parse(json['completedat'])
          : null,
    );
  }

  // Object to JSON conversion
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (enrollmentId != null) 'enrollmentId': enrollmentId,
      if (moduleId != null) 'moduleId': moduleId,
      if (timeSpent != null) 'timeSpent': timeSpent,
      if (completed != null) 'completed': completed,
      if (completedAt != null) 'completedat': completedAt?.toIso8601String(),
    };
  }
}
