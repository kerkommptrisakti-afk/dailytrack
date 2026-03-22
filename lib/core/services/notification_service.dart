import 'package:flutter/services.dart';
import '../constants/app_constants.dart';

class NotificationService {
  static const _channel = MethodChannel('id.dailytrack.fresh/notification');

  static Future<void> init() async {
    try {
      await _channel.invokeMethod('createChannel');
    } catch (_) {}
  }

  static Future<void> schedule({
    required int id,
    required String title,
    required String body,
    required DateTime triggerTime,
  }) async {
    try {
      await _channel.invokeMethod('scheduleNotification', {
        'id': id,
        'title': title,
        'body': body,
        'triggerMs': triggerTime.millisecondsSinceEpoch,
      });
    } catch (_) {}
  }

  static Future<void> cancel(int id) async {
    try {
      await _channel.invokeMethod('cancelNotification', {'id': id});
    } catch (_) {}
  }

  /// Schedule 2 notifikasi untuk satu kegiatan:
  /// 1. Tepat waktu kegiatan
  /// 2. X menit sebelum (sesuai reminderMinutes)
  static Future<void> scheduleForActivity({
    required String activityId,
    required String title,
    required DateTime activityTime,
    int? reminderMinutes,
  }) async {
    final baseId = activityId.hashCode.abs();

    // Notif tepat waktu
    if (activityTime.isAfter(DateTime.now())) {
      await schedule(
        id: baseId,
        title: '⏰ $title',
        body: 'Waktunya dimulai sekarang!',
        triggerTime: activityTime,
      );
    }

    // Notif X menit sebelum
    if (reminderMinutes != null && reminderMinutes > 0) {
      final reminderTime = activityTime.subtract(
        Duration(minutes: reminderMinutes),
      );
      if (reminderTime.isAfter(DateTime.now())) {
        await schedule(
          id: baseId + 1,
          title: '🔔 $title',
          body: '$reminderMinutes menit lagi dimulai',
          triggerTime: reminderTime,
        );
      }
    }
  }

  static Future<void> cancelForActivity(String activityId) async {
    final baseId = activityId.hashCode.abs();
    await cancel(baseId);
    await cancel(baseId + 1);
  }
}
