import 'dart:convert';

enum Priority { high, medium, low }

extension PriorityExtension on Priority {
  String get turkishName {
    switch (this) {
      case Priority.high:
        return 'YÜKSEK';
      case Priority.medium:
        return 'ORTA';
      case Priority.low:
        return 'DÜŞÜK';
    }
  }
}

class Task {
  final String id;
  String title;
  String? notes;
  bool completed;
  int? dueDateMillis;
  Priority priority;
  List<String> blockIds;

  int pomodoroMinutes;
  int pomodoroSessionsCompleted;
  int? lastSessionMillis;

  Task({
    required this.id,
    required this.title,
    this.notes,
    this.completed = false,
    this.dueDateMillis,
    this.priority = Priority.medium,
    List<String>? blockIds,
    this.pomodoroMinutes = 25,
    this.pomodoroSessionsCompleted = 0,
    this.lastSessionMillis,
  }) : blockIds = blockIds ?? [];

  factory Task.create({
    required String title,
    String? notes,
    Priority priority = Priority.medium,
    int? dueDateMillis,
  }) {
    return Task(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      title: title,
      notes: notes,
      priority: priority,
      dueDateMillis: dueDateMillis,
    );
  }

  factory Task.fromJson(Map<String, dynamic> json) => Task(
    id: json['id'] as String,
    title: json['title'] as String,
    notes: json['notes'] as String?,
    completed: json['completed'] as bool? ?? false,
    dueDateMillis: json['dueDateMillis'] as int?,
    priority: Priority.values.firstWhere(
      (e) => e.toString() == json['priority'],
      orElse: () => Priority.medium,
    ),
    blockIds:
        (json['blockIds'] as List<dynamic>?)
            ?.map((e) => e as String)
            .toList() ??
        [],
    pomodoroMinutes: json['pomodoroMinutes'] as int? ?? 25,
    pomodoroSessionsCompleted: json['pomodoroSessionsCompleted'] as int? ?? 0,
    lastSessionMillis: json['lastSessionMillis'] as int?,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'notes': notes,
    'completed': completed,
    'dueDateMillis': dueDateMillis,
    'priority': priority.toString(),
    'blockIds': blockIds,
    'pomodoroMinutes': pomodoroMinutes,
    'pomodoroSessionsCompleted': pomodoroSessionsCompleted,
    'lastSessionMillis': lastSessionMillis,
  };

  static String encodeList(List<Task> list) =>
      json.encode(list.map((e) => e.toJson()).toList());

  static List<Task> decodeList(String raw) {
    final data = json.decode(raw) as List<dynamic>;
    return data.map((e) => Task.fromJson(e as Map<String, dynamic>)).toList();
  }
}
