package id.dailytrack.fresh

import android.app.Activity
import android.app.AlarmManager
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.media.AudioAttributes
import android.media.RingtoneManager
import android.net.Uri
import android.os.Build
import android.provider.Settings
import android.speech.RecognizerIntent
import android.speech.SpeechRecognizer
import android.widget.RemoteViews
import androidx.core.app.NotificationCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val SPEECH_CHANNEL = "id.dailytrack.fresh/speech"
    private val NOTIF_CHANNEL = "id.dailytrack.fresh/notification"
    private val SPEECH_REQUEST_CODE = 100
    private var pendingResult: MethodChannel.Result? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            SPEECH_CHANNEL
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "startListening" -> {
                    pendingResult = result
                    startSpeechRecognition()
                }
                "isAvailable" -> {
                    result.success(SpeechRecognizer.isRecognitionAvailable(this))
                }
                else -> result.notImplemented()
            }
        }

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            NOTIF_CHANNEL
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "scheduleNotification" -> {
                    val id = call.argument<Int>("id") ?: 0
                    val title = call.argument<String>("title") ?: ""
                    val body = call.argument<String>("body") ?: ""
                    val triggerMs = call.argument<Long>("triggerMs") ?: 0L
                    val activityId = call.argument<String>("activityId") ?: ""
                    scheduleNotification(id, title, body, triggerMs, activityId)
                    result.success(true)
                }
                "cancelNotification" -> {
                    val id = call.argument<Int>("id") ?: 0
                    cancelNotification(id)
                    result.success(true)
                }
                "createChannel" -> {
                    createNotificationChannel()
                    result.success(true)
                }
                "requestBatteryOptimization" -> {
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                        val pm = getSystemService(android.os.PowerManager::class.java)
                        if (!pm.isIgnoringBatteryOptimizations(packageName)) {
                            val intent = Intent(
                                Settings.ACTION_REQUEST_IGNORE_BATTERY_OPTIMIZATIONS
                            ).apply {
                                data = Uri.parse("package:$packageName")
                            }
                            runOnUiThread { startActivity(intent) }
                        }
                    }
                    result.success(true)
                }
                "requestNotificationPermission" -> {
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                        runOnUiThread {
                            requestPermissions(
                                arrayOf(android.Manifest.permission.POST_NOTIFICATIONS),
                                1001
                            )
                        }
                    }
                    result.success(true)
                }
                else -> result.notImplemented()
            }
        }

        createNotificationChannel()
    }

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val soundUri = RingtoneManager.getDefaultUri(RingtoneManager.TYPE_ALARM)
            val audioAttr = AudioAttributes.Builder()
                .setUsage(AudioAttributes.USAGE_ALARM)
                .setContentType(AudioAttributes.CONTENT_TYPE_SONIFICATION)
                .build()
            val channel = NotificationChannel(
                "dailytrack_reminders",
                "DailyTrack Reminders",
                NotificationManager.IMPORTANCE_HIGH
            ).apply {
                description = "Reminder kegiatan DailyTrack"
                enableVibration(true)
                vibrationPattern = longArrayOf(0, 300, 200, 300, 200, 300)
                setSound(soundUri, audioAttr)
                setShowBadge(true)
                lockscreenVisibility = android.app.Notification.VISIBILITY_PUBLIC
            }
            val manager = getSystemService(NotificationManager::class.java)
            manager.createNotificationChannel(channel)
        }
    }

    private fun scheduleNotification(
        id: Int, title: String, body: String,
        triggerMs: Long, activityId: String
    ) {
        val intent = Intent(this, NotificationReceiver::class.java).apply {
            putExtra("id", id)
            putExtra("title", title)
            putExtra("body", body)
            putExtra("activityId", activityId)
        }
        val pendingIntent = PendingIntent.getBroadcast(
            this, id, intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
        val launchIntent = packageManager.getLaunchIntentForPackage(packageName)
        val showIntent = PendingIntent.getActivity(
            this, 0, launchIntent,
            PendingIntent.FLAG_IMMUTABLE
        )
        val alarm = getSystemService(Context.ALARM_SERVICE) as AlarmManager
        val alarmInfo = AlarmManager.AlarmClockInfo(triggerMs, showIntent)
        alarm.setAlarmClock(alarmInfo, pendingIntent)
    }

    private fun cancelNotification(id: Int) {
        val intent = Intent(this, NotificationReceiver::class.java)
        val pendingIntent = PendingIntent.getBroadcast(
            this, id, intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
        val alarm = getSystemService(Context.ALARM_SERVICE) as AlarmManager
        alarm.cancel(pendingIntent)
        val manager = getSystemService(NotificationManager::class.java)
        manager.cancel(id)
    }

    private fun startSpeechRecognition() {
        val intent = Intent(RecognizerIntent.ACTION_RECOGNIZE_SPEECH).apply {
            putExtra(RecognizerIntent.EXTRA_LANGUAGE_MODEL,
                RecognizerIntent.LANGUAGE_MODEL_FREE_FORM)
            putExtra(RecognizerIntent.EXTRA_LANGUAGE, "id-ID")
            putExtra(RecognizerIntent.EXTRA_LANGUAGE_PREFERENCE, "id-ID")
            putExtra(RecognizerIntent.EXTRA_PROMPT, "Bicara sekarang...")
            putExtra(RecognizerIntent.EXTRA_MAX_RESULTS, 1)
        }
        try {
            startActivityForResult(intent, SPEECH_REQUEST_CODE)
        } catch (e: Exception) {
            pendingResult?.error("NOT_AVAILABLE", "Speech tidak tersedia", null)
            pendingResult = null
        }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode == SPEECH_REQUEST_CODE) {
            if (resultCode == Activity.RESULT_OK && data != null) {
                val results = data.getStringArrayListExtra(RecognizerIntent.EXTRA_RESULTS)
                pendingResult?.success(if (!results.isNullOrEmpty()) results[0] else "")
            } else {
                pendingResult?.success("")
            }
            pendingResult = null
        }
    }
}

class NotificationReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        val id = intent.getIntExtra("id", 0)
        val title = intent.getStringExtra("title") ?: "DailyTrack"
        val body = intent.getStringExtra("body") ?: "Kegiatan akan segera dimulai"
        val soundUri = RingtoneManager.getDefaultUri(RingtoneManager.TYPE_ALARM)

        val launchIntent = context.packageManager
            .getLaunchIntentForPackage(context.packageName)
        val contentPendingIntent = PendingIntent.getActivity(
            context, 0, launchIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        val doneIntent = Intent(context, ActionReceiver::class.java).apply {
            action = "id.dailytrack.fresh.ACTION_DONE"
            putExtra("notifId", id)
        }
        val donePendingIntent = PendingIntent.getBroadcast(
            context, id + 1000, doneIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        val snoozeIntent = Intent(context, ActionReceiver::class.java).apply {
            action = "id.dailytrack.fresh.ACTION_SNOOZE"
            putExtra("notifId", id)
            putExtra("title", title)
            putExtra("body", body)
        }
        val snoozePendingIntent = PendingIntent.getBroadcast(
            context, id + 2000, snoozeIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        val customView = RemoteViews(
            context.packageName,
            R.layout.notification_custom
        ).apply {
            setTextViewText(R.id.notif_title, title)
            setTextViewText(R.id.notif_body, body)
            setOnClickPendingIntent(R.id.notif_action_done, donePendingIntent)
            setOnClickPendingIntent(R.id.notif_action_snooze, snoozePendingIntent)
        }

        val notification = NotificationCompat.Builder(context, "dailytrack_reminders")
            .setSmallIcon(android.R.drawable.ic_lock_idle_alarm)
            .setCustomContentView(customView)
            .setCustomBigContentView(customView)
            .setStyle(NotificationCompat.DecoratedCustomViewStyle())
            .setPriority(NotificationCompat.PRIORITY_MAX)
            .setCategory(NotificationCompat.CATEGORY_ALARM)
            .setAutoCancel(true)
            .setContentIntent(contentPendingIntent)
            .setSound(soundUri)
            .setVibrate(longArrayOf(0, 300, 200, 300, 200, 300))
            .setVisibility(NotificationCompat.VISIBILITY_PUBLIC)
            .build()

        val manager = context.getSystemService(Context.NOTIFICATION_SERVICE)
                as NotificationManager
        manager.notify(id, notification)
    }
}

class ActionReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        val notifId = intent.getIntExtra("notifId", 0)
        val manager = context.getSystemService(Context.NOTIFICATION_SERVICE)
                as NotificationManager

        when (intent.action) {
            "id.dailytrack.fresh.ACTION_DONE" -> {
                manager.cancel(notifId)
            }
            "id.dailytrack.fresh.ACTION_SNOOZE" -> {
                manager.cancel(notifId)
                val title = intent.getStringExtra("title") ?: "DailyTrack"
                val body = intent.getStringExtra("body") ?: ""
                val snoozeIntent = Intent(context, NotificationReceiver::class.java).apply {
                    putExtra("id", notifId)
                    putExtra("title", title)
                    putExtra("body", "Ditunda 10 menit: $body")
                }
                val pendingIntent = PendingIntent.getBroadcast(
                    context, notifId + 3000, snoozeIntent,
                    PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
                )
                val alarm = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
                val triggerMs = System.currentTimeMillis() + 10 * 60 * 1000L
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                    alarm.setExactAndAllowWhileIdle(
                        AlarmManager.RTC_WAKEUP, triggerMs, pendingIntent
                    )
                } else {
                    alarm.setExact(AlarmManager.RTC_WAKEUP, triggerMs, pendingIntent)
                }
            }
        }
    }
}
