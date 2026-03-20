class Activity {
  final String id;
  final String title;
  final DateTime date;
  final DateTime? time;
  final int priority;
  final String category;
  final bool isDone;
  final String? note;
  final int? reminderMinutes;
  final DateTime createdAt;

  Activity({
    required this.id,
    required this.title,
    required this.date,
    this.time,
    this.priority = 1,
    this.category = 'Kerja',
    this.isDone = false,
    this.note,
    this.reminderMinutes,
    required this.createdAt,
  });

  Activity copyWith({
    String? title,
    DateTime? date,
    DateTime? time,
    int? priority,
    String? category,
    bool? isDone,
    String? note,
    int? reminderMinutes,
  }) {
    return Activity(
      id: id,
      title: title ?? this.title,
      date: date ?? this.date,
      time: time ?? this.time,
      priority: priority ?? this.priority,
      category: category ?? this.category,
      isDone: isDone ?? this.isDone,
      note: note ?? this.note,
      reminderMinutes: reminderMinutes ?? this.reminderMinutes,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'date': date.toIso8601String(),
        'time': time?.toIso8601String(),
        'priority': priority,
        'category': category,
        'isDone': isDone,
        'note': note,
        'reminderMinutes': reminderMinutes,
        'createdAt': createdAt.toIso8601String(),
      };

  factory Activity.fromJson(Map<String, dynamic> json) => Activity(
        id: json['id'] as String,
        title: json['title'] as String,
        date: DateTime.parse(json['date'] as String),
        time: json['time'] != null
            ? DateTime.parse(json['time'] as String)
            : null,
        priority: json['priority'] as int? ?? 1,
        category: json['category'] as String? ?? 'Kerja',
        isDone: json['isDone'] as bool? ?? false,
        note: json['note'] as String?,
        reminderMinutes: json['reminderMinutes'] as int?,
        createdAt: DateTime.parse(json['createdAt'] as String),
      );
}
