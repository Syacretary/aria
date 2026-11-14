package com.aria.aria

import android.app.AlarmManager
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.os.Build
import android.provider.Settings

internal object SpotCheckAlarm {
    const val ACTION_REMIND = "com.aria.aria.SPOT_CHECK_REMIND"
    const val ACTION_OPEN = "com.aria.aria.SPOT_CHECK_OPEN"
    const val EXTRA_ROUTE = "aria_route"
    const val ROUTE = "/refleksi"
    private const val REQUEST_CODE = 68421
    private const val CHANNEL_ID = "aria_spot_checks"
    private const val PREFS = "FlutterSharedPreferences"
    private const val ENABLED_KEY = "flutter.aria.check_ins.enabled"
    private const val INTERVAL_KEY = "flutter.aria.check_ins.interval_days"

    fun schedule(context: Context, days: Int) {
        val intent = Intent(context, SpotCheckAlarmReceiver::class.java).setAction(ACTION_REMIND)
        val pending = PendingIntent.getBroadcast(
            context, REQUEST_CODE, intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
        )
        val alarm = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
        val triggerAt = System.currentTimeMillis() + days.coerceIn(3, 7) * 24L * 60L * 60L * 1000L
        alarm.setAndAllowWhileIdle(AlarmManager.RTC_WAKEUP, triggerAt, pending)
    }

    fun cancel(context: Context) {
        val intent = Intent(context, SpotCheckAlarmReceiver::class.java).setAction(ACTION_REMIND)
        val pending = PendingIntent.getBroadcast(
            context, REQUEST_CODE, intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
        )
        (context.getSystemService(Context.ALARM_SERVICE) as AlarmManager).cancel(pending)
        pending.cancel()
    }

    fun onReminder(context: Context) {
        val preferences = context.getSharedPreferences(PREFS, Context.MODE_PRIVATE)
        if (!preferences.getBoolean(ENABLED_KEY, false)) return
        postNotification(context)
        schedule(context, preferences.getInt(INTERVAL_KEY, 7))
    }

    fun rescheduleAfterBoot(context: Context) {
        val preferences = context.getSharedPreferences(PREFS, Context.MODE_PRIVATE)
        if (preferences.getBoolean(ENABLED_KEY, false)) {
            schedule(context, preferences.getInt(INTERVAL_KEY, 7))
        }
    }

    private fun postNotification(context: Context) {
        if (Build.VERSION.SDK_INT >= 33 &&
            context.checkSelfPermission(android.Manifest.permission.POST_NOTIFICATIONS) != PackageManager.PERMISSION_GRANTED
        ) return

        val manager = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            manager.createNotificationChannel(
                NotificationChannel(CHANNEL_ID, "Refleksi ARIA", NotificationManager.IMPORTANCE_DEFAULT)
                    .apply { description = "Pengingat refleksi singkat tentang kebiasaan digital" },
            )
        }
        val openIntent = Intent(context, MainActivity::class.java)
            .setAction(ACTION_OPEN)
            .putExtra(EXTRA_ROUTE, ROUTE)
            .addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP or Intent.FLAG_ACTIVITY_SINGLE_TOP)
        val content = PendingIntent.getActivity(
            context, REQUEST_CODE, openIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
        )
        val notification = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            android.app.Notification.Builder(context, CHANNEL_ID)
        } else {
            @Suppress("DEPRECATION") android.app.Notification.Builder(context)
        }.setSmallIcon(android.R.drawable.ic_dialog_info)
            .setContentTitle("Waktunya check-in singkat")
            .setContentText("Luangkan sebentar untuk melihat bagaimana perasaanmu beberapa hari terakhir.")
            .setContentIntent(content)
            .setAutoCancel(true)
            .build()
        manager.notify(REQUEST_CODE, notification)
    }
}

class SpotCheckAlarmReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent?) {
        if (intent?.action == SpotCheckAlarm.ACTION_REMIND) SpotCheckAlarm.onReminder(context)
    }
}

class SpotCheckBootReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent?) {
        if (intent?.action == Intent.ACTION_BOOT_COMPLETED) {
            SpotCheckAlarm.rescheduleAfterBoot(context)
            AriaProactiveAlarm.rescheduleAfterBoot(context)
        }
    }
}

internal object AriaProactiveAlarm {
    private const val ACTION = "com.aria.aria.ARIA_PROACTIVE"
    private const val REQUEST = 68422
    private const val CHANNEL = "aria_proactive"
    private const val PREFS = "FlutterSharedPreferences"

    fun schedule(context: Context, message: String, atMillis: Long) {
        val intent = Intent(context, AriaProactiveReceiver::class.java).setAction(ACTION)
        val pending = PendingIntent.getBroadcast(context, REQUEST, intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE)
        val alarms = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
        alarms.setAndAllowWhileIdle(AlarmManager.RTC_WAKEUP, atMillis, pending)
        context.getSharedPreferences(PREFS, Context.MODE_PRIVATE).edit()
            .putBoolean("flutter.aria.ai.proactive", true)
            .putString("flutter.aria.ai.proactive_message", message)
            .putLong("flutter.aria.ai.proactive_at", atMillis).apply()
    }

    fun cancel(context: Context) {
        val intent = Intent(context, AriaProactiveReceiver::class.java).setAction(ACTION)
        val pending = PendingIntent.getBroadcast(context, REQUEST, intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE)
        (context.getSystemService(Context.ALARM_SERVICE) as AlarmManager).cancel(pending)
        pending.cancel()
        context.getSharedPreferences(PREFS, Context.MODE_PRIVATE).edit()
            .putBoolean("flutter.aria.ai.proactive", false).remove("flutter.aria.ai.proactive_at").apply()
    }

    fun rescheduleAfterBoot(context: Context) {
        val prefs = context.getSharedPreferences(PREFS, Context.MODE_PRIVATE)
        if (!prefs.getBoolean("flutter.aria.ai.proactive", true)) return
        val message = prefs.getString("flutter.aria.ai.proactive_message", null) ?: return
        val savedTime = prefs.getLong("flutter.aria.ai.proactive_at", 0L)
        val trigger = if (savedTime > System.currentTimeMillis()) savedTime
            else System.currentTimeMillis() + 60L * 60L * 1000L
        schedule(context, message, trigger)
    }

    fun deliver(context: Context) {
        val prefs = context.getSharedPreferences(PREFS, Context.MODE_PRIVATE)
        val message = prefs.getString("flutter.aria.ai.proactive_message", null) ?: return
        if (!prefs.getBoolean("flutter.aria.ai.proactive", true)) return
        if (Build.VERSION.SDK_INT >= 33 &&
            context.checkSelfPermission(android.Manifest.permission.POST_NOTIFICATIONS) != PackageManager.PERMISSION_GRANTED) return
        val manager = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            manager.createNotificationChannel(NotificationChannel(CHANNEL, "Pesan ARIA", NotificationManager.IMPORTANCE_DEFAULT)
                .apply { description = "Pengingat personal dari ARIA" })
        }
        val open = Intent(context, MainActivity::class.java)
            .putExtra(SpotCheckAlarm.EXTRA_ROUTE, "/beranda/ngobrol")
            .addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP or Intent.FLAG_ACTIVITY_SINGLE_TOP)
        val content = PendingIntent.getActivity(context, REQUEST, open,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE)
        val notification = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O)
            android.app.Notification.Builder(context, CHANNEL) else @Suppress("DEPRECATION") android.app.Notification.Builder(context)
        val conciseMessage = message.lineSequence().firstOrNull()?.let { line ->
            val sentenceEnd = Regex("[.!?](?:\\s|$)").find(line)
            sentenceEnd?.let { line.substring(0, it.range.last + 1) } ?: line
        }?.take(180).orEmpty()
        manager.notify(REQUEST, notification.setSmallIcon(android.R.drawable.ic_dialog_info)
            .setContentTitle("Pesan kecil dari ARIA")
            .setContentText(conciseMessage)
            .setVisibility(android.app.Notification.VISIBILITY_PRIVATE)
            .setContentIntent(content).setAutoCancel(true).build())
        // The app refreshes this message and schedules the next one when it is
        // opened again. Avoid repeating stale personal advice indefinitely.
        prefs.edit().remove("flutter.aria.ai.proactive_at").apply()
    }
}

class AriaProactiveReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent?) {
        if (intent?.action == "com.aria.aria.ARIA_PROACTIVE") AriaProactiveAlarm.deliver(context)
    }
}
