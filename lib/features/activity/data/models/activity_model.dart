class Activity {
  final String id;
  final String title;
  final DateTime date;
  final DateTime? time;
  final int priority;
  final String category;
  final bool isDone;
  final String? note;
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
      createdAt: createdAt,
    );
  }
}
