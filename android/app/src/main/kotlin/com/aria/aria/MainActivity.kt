package com.aria.aria

import android.app.AppOpsManager
import android.app.usage.UsageEvents
import android.app.usage.UsageStatsManager
import android.content.Context
import android.content.Intent
import android.os.Build
import android.os.PowerManager
import android.provider.Settings
import android.net.Uri
import android.Manifest
import android.content.pm.PackageManager
import android.graphics.Bitmap
import android.graphics.Canvas
import java.io.ByteArrayOutputStream
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val channelName = "com.aria.aria/usage_stats"
    private var notificationResult: MethodChannel.Result? = null

    override fun getInitialRoute(): String = intent.getStringExtra(SpotCheckAlarm.EXTRA_ROUTE) ?: "/beranda"

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        intent.getStringExtra(SpotCheckAlarm.EXTRA_ROUTE)?.let { route ->
            MethodChannel(flutterEngine?.dartExecutor?.binaryMessenger ?: return, "com.aria.aria/check_ins")
                .invokeMethod("openRoute", route)
        }
    }

    override fun configureFlutterEngine(flutterEngine: io.flutter.embedding.engine.FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "hasUsageAccess" -> result.success(hasUsageAccess())
                    "scrollCount" -> result.success(scrollCount(range(call).first))
                    "openUsageAccessSettings" -> {
                        startActivity(Intent(Settings.ACTION_USAGE_ACCESS_SETTINGS))
                        result.success(null)
                    }
                    "screenTimeByApp" -> guarded(result) {
                        val range = range(call)
                        val manager = getSystemService(Context.USAGE_STATS_SERVICE) as UsageStatsManager
                        val values = manager.queryUsageStats(UsageStatsManager.INTERVAL_DAILY, range.first, range.second)
                            .filter { it.totalTimeInForeground > 0 }
                            .associate { it.packageName to it.totalTimeInForeground }
                        result.success(values)
                    }
                    "launchCounts" -> guarded(result) {
                        val range = range(call)
                        val events = events(range)
                        val counts = mutableMapOf<String, Int>()
                        while (events.hasNextEvent()) {
                            val event = UsageEvents.Event()
                            events.getNextEvent(event)
                            if (isResumed(event.eventType)) {
                                counts[event.packageName] = (counts[event.packageName] ?: 0) + 1
                            }
                        }
                        result.success(counts)
                    }
                    "sessions" -> guarded(result) {
                        val range = range(call)
                        val events = events(range)
                        val starts = mutableMapOf<String, Long>()
                        val sessions = mutableListOf<Map<String, Any>>()
                        while (events.hasNextEvent()) {
                            val event = UsageEvents.Event()
                            events.getNextEvent(event)
                            val packageName = event.packageName ?: continue
                            when {
                                isResumed(event.eventType) -> starts[packageName] = event.timeStamp
                                isPaused(event.eventType) -> starts.remove(packageName)?.let { start ->
                                    if (event.timeStamp > start) sessions += mapOf(
                                        "packageName" to packageName,
                                        "start" to start,
                                        "end" to event.timeStamp,
                                    )
                                }
                            }
                        }
                        result.success(sessions)
                    }
                    else -> result.notImplemented()
                }
            }
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "com.aria.aria/app_catalogue")
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "installedSocialApps" -> try {
                        result.success(installedSocialApps())
                    } catch (error: Exception) {
                        result.error("APP_CATALOGUE", "Daftar aplikasi tidak dapat dimuat.", error.message)
                    }
                    else -> result.notImplemented()
                }
            }
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "com.aria.aria/permissions")
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "states" -> result.success(permissionStates())
                    "request" -> requestPermission(call.argument<String>("permission"), result)
                    else -> result.notImplemented()
                }
            }

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "com.aria.aria/check_ins")
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "schedule" -> {
                        val days = call.argument<Int>("intervalDays")?.coerceIn(3, 7) ?: 7
                        getSharedPreferences("FlutterSharedPreferences", MODE_PRIVATE).edit()
                            .putBoolean("flutter.aria.check_ins.enabled", true)
                            .putInt("flutter.aria.check_ins.interval_days", days)
                            .apply()
                        SpotCheckAlarm.schedule(this, days)
                        result.success(null)
                    }
                    "cancel" -> {
                        getSharedPreferences("FlutterSharedPreferences", MODE_PRIVATE).edit()
                            .putBoolean("flutter.aria.check_ins.enabled", false).apply()
                        SpotCheckAlarm.cancel(this)
                        result.success(null)
                    }
                    "notificationsGranted" -> result.success(
                        Build.VERSION.SDK_INT < 33 ||
                            checkSelfPermission(Manifest.permission.POST_NOTIFICATIONS) == PackageManager.PERMISSION_GRANTED,
                    )
                    else -> result.notImplemented()
                }
            }

        val secureStore = AriaSecureStore(this)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "com.aria.aria/secure_store")
            .setMethodCallHandler { call, result ->
                try {
                    when (call.method) {
                        "saveSession" -> { secureStore.saveSession(call.argument<String>("value") ?: ""); result.success(null) }
                        "readSession" -> result.success(secureStore.readSession())
                        "clearSession" -> { secureStore.clear(); result.success(null) }
                        else -> result.notImplemented()
                    }
                } catch (error: Exception) {
                    result.error("SECURE_STORE", "Tidak dapat mengakses penyimpanan aman", error.message)
                }
            }

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "com.aria.aria/proactive")
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "schedule" -> {
                        val message = call.argument<String>("message")?.take(500) ?: ""
                        val atMillis = call.argument<Number>("atMillis")?.toLong() ?: 0L
                        if (message.isBlank() || atMillis <= System.currentTimeMillis()) {
                            result.error("INVALID_REMINDER", "Waktu atau pesan tidak valid", null)
                        } else {
                            getSharedPreferences("FlutterSharedPreferences", MODE_PRIVATE).edit()
                                .putBoolean("flutter.aria.ai.proactive", true)
                                .putString("flutter.aria.ai.proactive_message", message)
                                .putLong("flutter.aria.ai.proactive_at", atMillis)
                                .apply()
                            AriaProactiveAlarm.schedule(this, message, atMillis)
                            result.success(null)
                        }
                    }
                    "cancel" -> { AriaProactiveAlarm.cancel(this); result.success(null) }
                    else -> result.notImplemented()
                }
            }
    }

    private fun permissionStates(): Map<String, String> = mapOf(
        "usageAccess" to if (hasUsageAccess()) "granted" else "denied",
        "scrollDetection" to if (isAccessibilityEnabled()) "granted" else "denied",
        "overlay" to if (Settings.canDrawOverlays(this)) "granted" else "denied",
        "notifications" to if (Build.VERSION.SDK_INT < 33 || checkSelfPermission(Manifest.permission.POST_NOTIFICATIONS) == PackageManager.PERMISSION_GRANTED) "granted" else "denied",
        "batteryExemption" to if ((getSystemService(Context.POWER_SERVICE) as PowerManager).isIgnoringBatteryOptimizations(packageName)) "granted" else "denied",
    )

    /** Queries a small, declared set of social apps and returns local launcher icons. */
    private fun installedSocialApps(): List<Map<String, Any>> {
        val socialPackages = listOf(
            "com.zhiliaoapp.musically",
            "com.ss.android.ugc.trill",
            "com.instagram.android",
            "com.instagram.barcelona",
            "com.google.android.youtube",
            "com.facebook.katana",
            "com.twitter.android",
            "com.reddit.frontpage",
            "com.snapchat.android",
            "com.pinterest",
        )
        return socialPackages.mapNotNull { appPackage ->
            val appInfo = try {
                @Suppress("DEPRECATION")
                packageManager.getApplicationInfo(appPackage, 0)
            } catch (_: PackageManager.NameNotFoundException) {
                return@mapNotNull null
            }
            val drawable = packageManager.getApplicationIcon(appInfo)
            val size = (48 * resources.displayMetrics.density).toInt().coerceAtLeast(96)
            val bitmap = Bitmap.createBitmap(size, size, Bitmap.Config.ARGB_8888)
            val canvas = Canvas(bitmap)
            drawable.setBounds(0, 0, size, size)
            drawable.draw(canvas)
            val bytes = ByteArrayOutputStream().use { output ->
                bitmap.compress(Bitmap.CompressFormat.PNG, 100, output)
                bitmap.recycle()
                output.toByteArray()
            }
            mapOf(
                "packageName" to appPackage,
                "appName" to packageManager.getApplicationLabel(appInfo).toString(),
                "iconPng" to bytes,
            )
        }
    }

    private fun requestPermission(permission: String?, result: MethodChannel.Result) {
        when (permission) {
            "usageAccess" -> startActivity(Intent(Settings.ACTION_USAGE_ACCESS_SETTINGS))
            "scrollDetection" -> startActivity(Intent(Settings.ACTION_ACCESSIBILITY_SETTINGS))
            "overlay" -> startActivity(Intent(Settings.ACTION_MANAGE_OVERLAY_PERMISSION, Uri.parse("package:$packageName")))
            "batteryExemption" -> startActivity(Intent(Settings.ACTION_REQUEST_IGNORE_BATTERY_OPTIMIZATIONS, Uri.parse("package:$packageName")))
            "notifications" -> if (Build.VERSION.SDK_INT >= 33) {
                notificationResult = result
                requestPermissions(arrayOf(Manifest.permission.POST_NOTIFICATIONS), 901)
                return
            }
            else -> { result.error("UNKNOWN_PERMISSION", "Izin tidak dikenali.", null); return }
        }
        result.success(null)
    }

    override fun onRequestPermissionsResult(requestCode: Int, permissions: Array<out String>, grantResults: IntArray) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        if (requestCode == 901) {
            notificationResult?.success(null)
            notificationResult = null
        }
    }

    private fun isAccessibilityEnabled(): Boolean {
        val enabled = Settings.Secure.getString(contentResolver, Settings.Secure.ENABLED_ACCESSIBILITY_SERVICES) ?: return false
        return enabled.split(':').any { flattened ->
            val normalized = flattened.replace('/', '.')
            normalized.equals("$packageName.com.aria.aria.AriaScrollAccessibilityService", ignoreCase = true) ||
                flattened.equals("$packageName/.AriaScrollAccessibilityService", ignoreCase = true)
        }
    }

    private fun guarded(result: MethodChannel.Result, body: () -> Unit) {
        if (!hasUsageAccess()) {
            result.error("USAGE_ACCESS_DENIED", "Aktifkan Usage Access untuk ARIA di Pengaturan.", null)
            return
        }
        body()
    }

    private fun range(call: io.flutter.plugin.common.MethodCall): Pair<Long, Long> {
        val start = call.argument<Number>("startMillis")?.toLong() ?: 0L
        val end = call.argument<Number>("endMillis")?.toLong() ?: System.currentTimeMillis()
        return Pair(start, end)
    }

    private fun events(range: Pair<Long, Long>): UsageEvents {
        val manager = getSystemService(Context.USAGE_STATS_SERVICE) as UsageStatsManager
        return manager.queryEvents(range.first, range.second)
    }

    private fun scrollCount(startMillis: Long): Int {
        val day = java.text.SimpleDateFormat("yyyy-MM-dd", java.util.Locale.US)
            .format(java.util.Date(startMillis))
        return getSharedPreferences("aria_scroll_counts", MODE_PRIVATE).all
            .filterKeys { it.endsWith(":$day") }
            .values.sumOf { (it as? Int) ?: 0 }
    }

    private fun hasUsageAccess(): Boolean {
        val appOps = getSystemService(Context.APP_OPS_SERVICE) as AppOpsManager
        @Suppress("DEPRECATION")
        val mode = appOps.checkOpNoThrow(AppOpsManager.OPSTR_GET_USAGE_STATS, android.os.Process.myUid(), packageName)
        return mode == AppOpsManager.MODE_ALLOWED
    }

    private fun isResumed(type: Int): Boolean = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
        type == UsageEvents.Event.ACTIVITY_RESUMED
    } else type == UsageEvents.Event.MOVE_TO_FOREGROUND

    private fun isPaused(type: Int): Boolean = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
        type == UsageEvents.Event.ACTIVITY_PAUSED
    } else type == UsageEvents.Event.MOVE_TO_BACKGROUND
}
