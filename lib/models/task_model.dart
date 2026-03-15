import 'package:intl/intl.dart';

class TaskModel {
  final int? id;
  final String userId;
  final String title;
  final String? description;
  final String priority; // high | medium | low
  final String category;
  final DateTime? deadline;
  final String status; // pending | completed
  final DateTime createdAt;
  final DateTime? updatedAt;

  TaskModel({
    this.id,
    required this.userId,
    required this.title,
    this.description,
    required this.priority,
    required this.category,
    this.deadline,
    required this.status,
    required this.createdAt,
    this.updatedAt,
  });

  bool get isCompleted => status == 'completed';
  bool get isPending   => status == 'pending';

  bool get isOverdue =>
      isPending && deadline != null && deadline!.isBefore(DateTime.now());

  bool get isDueToday {
    if (deadline == null) return false;
    final now   = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final d     = DateTime(deadline!.year, deadline!.month, deadline!.day);
    return d == today;
  }

  String get formattedDeadline {
    if (deadline == null) return 'No deadline';
    return DateFormat('MMM d, yyyy · h:mm a').format(deadline!);
  }

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id:          json['id']          is int ? json['id'] as int
                                              : int.tryParse(json['id'].toString()),
      userId:      json['user_id']     as String,
      title:       json['title']       as String,
      description: json['description'] as String?,
      priority:    json['priority']    as String? ?? 'medium',
      category:    json['category']    as String? ?? 'Personal',
      deadline:    json['deadline']    != null
          ? DateTime.parse(json['deadline'] as String)
          : null,
      status:     json['status']      as String? ?? 'pending',
      createdAt:  json['created_at']  != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      updatedAt:  json['updated_at']  != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        'user_id':     userId,
        'title':       title,
        'description': description,
        'priority':    priority,
        'category':    category,
        'deadline':    deadline?.toUtc().toIso8601String(),
        'status':      status,
        'created_at':  createdAt.toIso8601String(),
      };

  /// Payload for POST /tasks — only fields the backend expects (no user_id, no created_at).
  Map<String, dynamic> toCreateJson() => {
        'title':       title,
        if (description != null && description!.isNotEmpty) 'description': description,
        'priority':    priority,
        'category':    category,
        if (deadline != null) 'deadline': deadline!.toUtc().toIso8601String(),
        'status':      status,
      };

  TaskModel copyWith({
    int?      id,
    String?   userId,
    String?   title,
    String?   description,
    String?   priority,
    String?   category,
    DateTime? deadline,
    String?   status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) =>
      TaskModel(
        id:          id          ?? this.id,
        userId:      userId      ?? this.userId,
        title:       title       ?? this.title,
        description: description ?? this.description,
        priority:    priority    ?? this.priority,
        category:    category    ?? this.category,
        deadline:    deadline    ?? this.deadline,
        status:      status      ?? this.status,
        createdAt:   createdAt   ?? this.createdAt,
        updatedAt:   updatedAt   ?? this.updatedAt,
      );
}
