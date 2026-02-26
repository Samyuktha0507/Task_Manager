/// Model representing a task from JSONPlaceholder API.
class TaskModel {
  final int id;
  final int userId;
  final String title;
  final bool completed;
  final String description;
  final String? coverImageUrl;
  final String? coverImagePath;
  final DateTime? deadline;
  final bool repeatDaily;
  final String category;
  final int colorValue;

  const TaskModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.completed,
    this.description = '',
    this.coverImageUrl,
    this.coverImagePath,
    this.deadline,
    this.repeatDaily = false,
    this.category = 'General',
    this.colorValue = 0xFF7C4DFF,
  });

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: json['id'] as int,
      userId: json['userId'] as int,
      title: json['title'] as String,
      completed: json['completed'] as bool,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'title': title,
        'completed': completed,
        'description': description,
        'coverImageUrl': coverImageUrl,
        'coverImagePath': coverImagePath,
        'deadline': deadline?.toIso8601String(),
        'repeatDaily': repeatDaily,
        'category': category,
        'colorValue': colorValue,
      };

  /// Status label for UI: "Completed" or "Pending"
  String get statusLabel => completed ? 'Completed' : 'Pending';

  TaskModel copyWith({
    int? id,
    int? userId,
    String? title,
    bool? completed,
    String? description,
    String? coverImageUrl,
    String? coverImagePath,
    DateTime? deadline,
    bool clearDeadline = false,
    bool? repeatDaily,
    String? category,
    int? colorValue,
  }) {
    return TaskModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      completed: completed ?? this.completed,
      description: description ?? this.description,
      coverImageUrl: coverImageUrl ?? this.coverImageUrl,
      coverImagePath: coverImagePath ?? this.coverImagePath,
      deadline: clearDeadline ? null : (deadline ?? this.deadline),
      repeatDaily: repeatDaily ?? this.repeatDaily,
      category: category ?? this.category,
      colorValue: colorValue ?? this.colorValue,
    );
  }
}
