import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/activity/data/models/activity_model.dart';
import '../../features/activity/data/models/activity_provider.dart';
import '../../shared/widgets/reminder_overlay.dart';
import 'notification_service.dart';

class ReminderChecker {
  Timer? _timer;
  final WidgetRef _ref;
  final BuildContext _context;
  final Set<String> _triggered = {};

  ReminderChecker(this._ref, this._context);

  void start() {
    _timer = Timer.periodic(const Duration(seconds: 30), (_) => _check());
    _check();
  }

  void stop() {
    _timer?.cancel();
    _triggered.clear();
  }

  void _check() {
    if (!_context.mounted) return;
    final activities = _ref.read(activityProvider);
    final now = DateTime.now();

    for (final activity in activities) {
      if (activity.isDone) continue;
      if (activity.time == null) continue;
      if (_triggered.contains(activity.id)) continue;

      final actTime = DateTime(
        activity.date.year,
        activity.date.month,
        activity.date.day,
        activity.time!.hour,
        activity.time!.minute,
      );

      final diff = actTime.difference(now).inSeconds;

      // Trigger saat tepat waktu (±60 detik)
      if (diff >= -60 && diff <= 60) {
        _triggered.add(activity.id);
        _showOverlay(activity);
      }

      // Trigger reminder X menit sebelum
      if (activity.reminderMinutes != null) {
        final reminderTime = actTime.subtract(
          Duration(minutes: activity.reminderMinutes!),
        );
        final reminderDiff = reminderTime.difference(now).inSeconds;
        final reminderId = '${activity.id}_reminder';

        if (reminderDiff >= -60 &&
            reminderDiff <= 60 &&
            !_triggered.contains(reminderId)) {
          _triggered.add(reminderId);
          _showReminderWarning(activity);
        }
      }
    }
  }

  void _showOverlay(Activity activity) {
    if (!_context.mounted) return;
    showReminderOverlay(
      _context,
      activityTitle: activity.title,
      category: activity.category,
      onDismiss: () {},
      onMarkDone: () {
        _ref.read(activityProvider.notifier).toggleDone(activity.id);
      },
    );
  }

  void _showReminderWarning(Activity activity) {
    if (!_context.mounted) return;
    ScaffoldMessenger.of(_context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.notifications_active_rounded,
              color: Colors.white,
              size: 18,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                '${activity.reminderMinutes} menit lagi: ${activity.title}',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF7C3AED),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        duration: const Duration(seconds: 5),
      ),
    );
  }

  /// Schedule system notification untuk activity
  void scheduleSystemNotif(Activity activity) {
    if (activity.time == null) return;
    final actTime = DateTime(
      activity.date.year,
      activity.date.month,
      activity.date.day,
      activity.time!.hour,
      activity.time!.minute,
    );
    NotificationService.scheduleForActivity(
      activityId: activity.id,
      title: activity.title,
      activityTime: actTime,
      reminderMinutes: activity.reminderMinutes,
    );
  }
}

final reminderCheckerProvider = Provider<ReminderChecker?>((ref) => null);
