package id.dailytrack.fresh

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
import android.widget.RemoteViews
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale

class DailyTrackWidget : AppWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        for (appWidgetId in appWidgetIds) {
            updateWidget(context, appWidgetManager, appWidgetId)
        }
    }

    companion object {
        fun updateWidget(
            context: Context,
            appWidgetManager: AppWidgetManager,
            appWidgetId: Int
        ) {
            val prefs = context.getSharedPreferences(
                "FlutterSharedPreferences",
                Context.MODE_PRIVATE
            )

            val activitiesJson = prefs.getString("flutter.activities_v2", null)
            val todayCount = getTodayCount(activitiesJson)
            val doneCount = getDoneCount(activitiesJson)
            val nextActivity = getNextActivity(activitiesJson)
            val nextTime = getNextTime(activitiesJson)

            val launchIntent = context.packageManager
                .getLaunchIntentForPackage(context.packageName)
            val pendingIntent = PendingIntent.getActivity(
                context, 0, launchIntent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )

            val views = RemoteViews(
                context.packageName,
                R.layout.widget_layout
            ).apply {
                setTextViewText(
                    R.id.widget_next_activity,
                    if (nextActivity.isNotEmpty()) nextActivity else "Tidak ada kegiatan"
                )
                setTextViewText(
                    R.id.widget_next_time,
                    if (nextTime.isNotEmpty()) nextTime else "Tap untuk buka app"
                )
                setTextViewText(
                    R.id.widget_count,
                    "$todayCount kegiatan"
                )
                setTextViewText(
                    R.id.widget_progress,
                    "$doneCount selesai"
                )
                setOnClickPendingIntent(R.id.widget_title, pendingIntent)
            }

            appWidgetManager.updateAppWidget(appWidgetId, views)
        }

        private fun getTodayCount(json: String?): Int {
            if (json == null) return 0
            return try {
                val today = SimpleDateFormat("yyyy-MM-dd", Locale.getDefault()).format(Date())
                json.split("\"date\":\"").drop(1).count { it.startsWith(today) }
            } catch (e: Exception) { 0 }
        }

        private fun getDoneCount(json: String?): Int {
            if (json == null) return 0
            return try {
                val today = SimpleDateFormat("yyyy-MM-dd", Locale.getDefault()).format(Date())
                json.split("\"date\":\"").drop(1)
                    .count { it.startsWith(today) && it.contains("\"isDone\":true") }
            } catch (e: Exception) { 0 }
        }

        private fun getNextActivity(json: String?): String {
            if (json == null) return ""
            return try {
                val today = SimpleDateFormat("yyyy-MM-dd", Locale.getDefault()).format(Date())
                val parts = json.split("\\{".toRegex()).drop(1)
                for (part in parts) {
                    if (part.contains("\"date\":\"$today") && !part.contains("\"isDone\":true")) {
                        val match = Regex("\"title\":\"([^\"]+)\"").find(part)
                        if (match != null) return match.groupValues[1]
                    }
                }
                ""
            } catch (e: Exception) { "" }
        }

        private fun getNextTime(json: String?): String {
            if (json == null) return ""
            return try {
                val today = SimpleDateFormat("yyyy-MM-dd", Locale.getDefault()).format(Date())
                val parts = json.split("\\{".toRegex()).drop(1)
                for (part in parts) {
                    if (part.contains("\"date\":\"$today") && !part.contains("\"isDone\":true")) {
                        val match = Regex("\"time\":\"([^\"]+)\"").find(part)
                        if (match != null) {
                            val dt = SimpleDateFormat(
                                "yyyy-MM-dd'T'HH:mm:ss.SSS",
                                Locale.getDefault()
                            ).parse(match.groupValues[1])
                            if (dt != null) {
                                return SimpleDateFormat("HH:mm", Locale.getDefault()).format(dt)
                            }
                        }
                    }
                }
                ""
            } catch (e: Exception) { "" }
        }
    }
}
