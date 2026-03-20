import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'activity_model.dart';

const _uuid = Uuid();

class ActivityNotifier extends StateNotifier<List<Activity>> {
  ActivityNotifier() : super([]);

  void add({
    required String title,
    required DateTime date,
    DateTime? time,
    int priority = 1,
    String category = 'Kerja',
    String? note,
  }) {
    final activity = Activity(
      id: _uuid.v4(),
      title: title,
      date: date,
      time: time,
      priority: priority,
      category: category,
      note: note,
      createdAt: DateTime.now(),
    );
    state = [...state, activity];
  }

  void toggleDone(String id) {
    state = state.map((a) {
      if (a.id == id) return a.copyWith(isDone: !a.isDone);
      return a;
    }).toList();
  }

  void delete(String id) {
    state = state.where((a) => a.id != id).toList();
  }

  void update({
    required String id,
    String? title,
    DateTime? date,
    DateTime? time,
    int? priority,
    String? category,
    String? note,
  }) {
    state = state.map((a) {
      if (a.id != id) return a;
      return a.copyWith(
        title: title,
        date: date,
        time: time,
        priority: priority,
        category: category,
        note: note,
      );
    }).toList();
  }

  List<Activity> todayActivities() {
    final now = DateTime.now();
    return state.where((a) {
      return a.date.year == now.year &&
          a.date.month == now.month &&
          a.date.day == now.day;
    }).toList()
      ..sort((a, b) {
        if (a.time == null && b.time == null) return 0;
        if (a.time == null) return 1;
        if (b.time == null) return -1;
        return a.time!.compareTo(b.time!);
      });
  }
}

final activityProvider =
    StateNotifierProvider<ActivityNotifier, List<Activity>>(
  (ref) => ActivityNotifier(),
);

final todayActivitiesProvider = Provider<List<Activity>>((ref) {
  final notifier = ref.watch(activityProvider.notifier);
  ref.watch(activityProvider);
  return notifier.todayActivities();
});
