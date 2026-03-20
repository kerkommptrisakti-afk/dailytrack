import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'activity_model.dart';

const _uuid = Uuid();
const _prefKey = 'activities';

class ActivityNotifier extends StateNotifier<List<Activity>> {
  ActivityNotifier() : super([]) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefKey);
    if (raw == null) return;
    try {
      final list = (jsonDecode(raw) as List)
          .map((e) => Activity.fromJson(e as Map<String, dynamic>))
          .toList();
      state = list;
    } catch (_) {}
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _prefKey,
      jsonEncode(state.map((a) => a.toJson()).toList()),
    );
  }

  void add({
    required String title,
    required DateTime date,
    DateTime? time,
    int priority = 1,
    String category = 'Kerja',
    String? note,
    int? reminderMinutes,
  }) {
    final activity = Activity(
      id: _uuid.v4(),
      title: title,
      date: date,
      time: time,
      priority: priority,
      category: category,
      note: note,
      reminderMinutes: reminderMinutes,
      createdAt: DateTime.now(),
    );
    state = [...state, activity];
    _save();
  }

  void toggleDone(String id) {
    state = state.map((a) {
      if (a.id == id) return a.copyWith(isDone: !a.isDone);
      return a;
    }).toList();
    _save();
  }

  void delete(String id) {
    state = state.where((a) => a.id != id).toList();
    _save();
  }

  void update({
    required String id,
    String? title,
    DateTime? date,
    DateTime? time,
    int? priority,
    String? category,
    String? note,
    int? reminderMinutes,
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
        reminderMinutes: reminderMinutes,
      );
    }).toList();
    _save();
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
