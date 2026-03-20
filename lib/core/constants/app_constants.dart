abstract class AppConstants {
  static const appName = 'DailyTrack';
  static const appVersion = '3.0.0';
  static const bundleId = 'id.dailytrack.app';
  static const dbName = 'dailytrack_db';
  static const aiMinDaysForTraining = 7;
  static const aiLookbackDays = 30;
  static const aiMinConfidenceScore = 0.55;
  static const notifChannelId = 'dailytrack_main';
  static const notifEarlyMinutes = 5;
  static const geofenceMaxRegions = 18;
  static const geofenceDefaultRadius = 200.0;
  static const pomodoroWorkMinutes = 25;
  static const pomodoroShortBreakMinutes = 5;
  static const pomodoroLongBreakMinutes = 15;
  static const priorityLow = 0;
  static const priorityNormal = 1;
  static const priorityHigh = 2;
  static const priorityCritical = 3;
  static const priorityLabels = ['Rendah', 'Normal', 'Tinggi', 'Kritis'];
  static const defaultCategories = ['Kerja', 'Pribadi', 'Kesehatan', 'Belajar'];
  static const streakMilestones = [7, 14, 30, 60, 100, 365];
  static const prefOnboardingDone = 'onboarding_done';
  static const prefUsername = 'username';
}
