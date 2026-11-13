package com.aria.aria

import android.accessibilityservice.AccessibilityService
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.usage.UsageStatsManager
import android.content.Context
import android.graphics.Color
import android.graphics.PixelFormat
import android.graphics.Typeface
import android.graphics.drawable.GradientDrawable
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.os.SystemClock
import android.provider.Settings
import android.view.Gravity
import android.view.View
import android.view.WindowManager
import android.view.accessibility.AccessibilityEvent
import android.widget.LinearLayout
import android.widget.TextView
import org.json.JSONObject
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale

/** Local-only counter with a non-touchable island, active only after opt-in. */
class AriaScrollAccessibilityService : AccessibilityService() {
    private companion object {
        const val OPEN_REMINDER_COOLDOWN_MS = 2 * 60 * 60 * 1000L
    }
    // TikTok uses different application IDs in different regions/build tracks.
    private val supportedPackages = setOf(
        "com.instagram.android",
        "com.google.android.youtube",
        "com.zhiliaoapp.musically",
        "com.ss.android.ugc.trill",
    )
    private val socialPackages = setOf(
        "com.instagram.android",
        "com.google.android.youtube",
        "com.zhiliaoapp.musically",
        "com.ss.android.ugc.trill",
        "com.facebook.katana",
        "com.twitter.android",
        "com.reddit.frontpage",
        "com.snapchat.android",
        "com.pinterest",
    )
    private val transientSystemPackages = setOf(
        "com.android.systemui",
        "com.android.permissioncontroller",
        "com.google.android.inputmethod.latin",
        "com.aria.aria",
    )
    private val handler = Handler(Looper.getMainLooper())
    private val limitPoll = object : Runnable {
        override fun run() {
            val target = foregroundPackage ?: return
            if (target != packageName) enforceLimit(target)
            handler.postDelayed(this, 3_000L)
        }
    }
    private val sessionCounts = mutableMapOf<String, Int>()
    private val lastCountedScrollAt = mutableMapOf<String, Long>()
    private val lastScrollY = mutableMapOf<String, Int>()
    private val lastPagerIndex = mutableMapOf<String, Int>()
    private val shownMilestones = mutableMapOf<String, MutableSet<Int>>()
    private val reminderUntil = mutableMapOf<String, Long>()
    private var islandReminderReset: Runnable? = null
    private var windowManager: WindowManager? = null
    private var island: View? = null
    private var islandText: TextView? = null
    private var intervention: View? = null
    private var interventionDismissButton: TextView? = null
    private var interventionDeadlineElapsed = 0L
    private var openReminderMode = false
    private var foregroundPackage: String? = null
    private var blockRedirectAt = 0L
    private var socialSessionStartedAt = 0L
    private val pauseTicker = object : Runnable {
        override fun run() {
            val button = interventionDismissButton ?: return
            val view = intervention
            if (view == null || !view.isAttachedToWindow) {
                intervention = null
                interventionDismissButton = null
                interventionDeadlineElapsed = 0L
                openReminderMode = false
                return
            }
            val remainingMs = interventionDeadlineElapsed - SystemClock.elapsedRealtime()
            if (remainingMs <= 0L) {
                button.isEnabled = true
                button.text = if (openReminderMode) "Lanjutkan" else "Tutup jeda"
                return
            }
            val remainingSeconds = ((remainingMs + 999L) / 1_000L).toInt()
            button.isEnabled = false
            button.text = if (openReminderMode) {
                "Lanjutkan dalam ${remainingSeconds} dtk"
            } else {
                "Tutup jeda dalam ${remainingSeconds} dtk"
            }
            handler.postDelayed(this, minOf(250L, remainingMs))
        }
    }
    private val interventionTimeout = Runnable { removeIntervention() }

    override fun onAccessibilityEvent(event: AccessibilityEvent) {
        val packageName = event.packageName?.toString() ?: return
        when (event.eventType) {
            AccessibilityEvent.TYPE_WINDOW_STATE_CHANGED -> {
                // IME, launcher, permission UI, and ARIA's own overlay produce
                // window events too. They are not evidence that the user left
                // the limited app, so they must not dismiss a block overlay.
                if (packageName == applicationContext.packageName) {
                    val activityName = event.className?.toString().orEmpty()
                    if (activityName.contains("MainActivity")) {
                        trackQuickSocialReturn(foregroundPackage, packageName)
                        foregroundPackage = packageName
                        removeIsland()
                        removeIntervention()
                        handler.removeCallbacks(limitPoll)
                        blockRedirectAt = 0L
                    }
                    return
                }
                if (transientSystemPackages.contains(packageName)) {
                    removeIntervention()
                    return
                }
                val previous = foregroundPackage
                trackQuickSocialReturn(previous, packageName)
                if (previous != packageName && previous != null && supportedPackages.contains(previous)) {
                    sessionCounts.remove(previous)
                    shownMilestones.remove(previous)
                    reminderUntil.remove(previous)
                    clearIslandReminderReset()
                    lastScrollY.remove(previous)
                    lastPagerIndex.remove(previous)
                }
                foregroundPackage = packageName
                if (supportedPackages.contains(packageName)) {
                    if (previous != packageName) {
                        sessionCounts[packageName] = 0
                        shownMilestones.remove(packageName)
                        reminderUntil.remove(packageName)
                        clearIslandReminderReset()
                    }
                    showIsland(packageName)
                } else {
                    removeIsland()
                    removeIntervention()
                    blockRedirectAt = 0L
                }
                handler.removeCallbacks(limitPoll)
                val limit = limitFor(packageName)
                if (limit?.enabled == true) {
                    enforceLimit(packageName)
                    handler.postDelayed(limitPoll, 3_000L)
                } else {
                    removeIntervention()
                }
                if (previous != packageName && limit?.remindOnOpen == true && intervention == null) {
                    showOpenReminder(packageName)
                }
            }
            AccessibilityEvent.TYPE_VIEW_SCROLLED -> {
                if (!supportedPackages.contains(packageName) || !isDistinctScroll(event, packageName)) return
                if (foregroundPackage == null || !socialPackages.contains(foregroundPackage)) {
                    socialSessionStartedAt = System.currentTimeMillis()
                }
                foregroundPackage = packageName
                val session = (sessionCounts[packageName] ?: 0) + 1
                sessionCounts[packageName] = session
                incrementDaily(packageName)
                showIsland(packageName)
                maybeShowReminder(packageName, session)
                enforceLimit(packageName)
            }
        }
    }

    /**
     * Self-control proxy: a social-app visit followed by leaving the social
     * app group within a minute. We store only a cumulative count, never the
     * app sequence or screen contents.
     */
    private fun trackQuickSocialReturn(previous: String?, current: String) {
        val wasSocial = previous != null && socialPackages.contains(previous)
        val isSocial = socialPackages.contains(current)
        val now = System.currentTimeMillis()
        if (!wasSocial && isSocial) {
            socialSessionStartedAt = now
            return
        }
        if (wasSocial && !isSocial) {
            val elapsed = now - socialSessionStartedAt
            if (socialSessionStartedAt > 0L && elapsed in 1..60_000L) {
                val prefs = getSharedPreferences("FlutterSharedPreferences", MODE_PRIVATE)
                val key = "flutter.aria.achievements.quick_social_returns"
                prefs.edit().putInt(key, prefs.getInt(key, 0) + 1).apply()
            }
            socialSessionStartedAt = 0L
        }
    }

    private data class Limit(val quotaMinutes: Int, val enforcement: String, val enabled: Boolean, val remindOnOpen: Boolean)

    /** Reads only the app limits selected by the person in ARIA. */
    private fun limitFor(packageName: String): Limit? = try {
        val prefs = getSharedPreferences("FlutterSharedPreferences", MODE_PRIVATE)
        // shared_preferences' Android backend stores legacy keys with the
        // `flutter.` prefix. Keep the unprefixed fallback for older builds.
        val raw = prefs.getString("flutter.aria.app_manager.limits",
            prefs.getString("aria.app_manager.limits", "{}")) ?: "{}"
        val root = JSONObject(raw)
        val key = when {
            root.has(packageName) -> packageName
            packageName == "com.ss.android.ugc.trill" && root.has("com.zhiliaoapp.musically") -> "com.zhiliaoapp.musically"
            else -> return null
        }
        val item = root.getJSONObject(key)
        Limit(item.optInt("quota_minutes"), item.optString("enforcement", "breathe"), item.optBoolean("enabled", true), item.optBoolean("remind_on_open", false))
    } catch (_: Exception) { null }

    private fun enforceLimit(packageName: String) {
        val limit = limitFor(packageName) ?: return
        if (!limit.enabled || limit.enforcement == "trackOnly" || limit.enforcement == "track_only") {
            removeIntervention()
            return
        }
        if (!hasReachedLimit(packageName, limit)) {
            removeIntervention()
            return
        }
        when (limit.enforcement) {
            "warn" -> {
                removeIntervention()
                notifyLimit(packageName, limit.quotaMinutes)
            }
            "breathe" -> showPause(packageName, limit.quotaMinutes)
            "block" -> {
                removeIntervention()
                redirectHomeForLimit(packageName, limit.quotaMinutes)
            }
        }
    }

    private fun hasReachedLimit(packageName: String, limit: Limit): Boolean {
        val usage = getSystemService(Context.USAGE_STATS_SERVICE) as UsageStatsManager
        val start = java.util.Calendar.getInstance().apply { set(java.util.Calendar.HOUR_OF_DAY, 0); set(java.util.Calendar.MINUTE, 0); set(java.util.Calendar.SECOND, 0); set(java.util.Calendar.MILLISECOND, 0) }.timeInMillis
        val used = usage.queryUsageStats(UsageStatsManager.INTERVAL_DAILY, start, System.currentTimeMillis())
            .firstOrNull { it.packageName == packageName }?.totalTimeInForeground ?: 0L
        return used >= limit.quotaMinutes * 60_000L
    }

    private fun notifyLimit(packageName: String, minutes: Int) {
        val delivery = getSharedPreferences("aria_limit_actions", MODE_PRIVATE)
        val deliveredKey = "warned:$packageName:${today()}:$minutes"
        if (delivery.getBoolean(deliveredKey, false)) return
        val manager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) manager.createNotificationChannel(NotificationChannel("aria_limits", "Batas ARIA", NotificationManager.IMPORTANCE_DEFAULT))
        val app = packageName.substringAfterLast('.').replaceFirstChar { it.uppercase() }
        val notification = android.app.Notification.Builder(this, "aria_limits")
            .setSmallIcon(android.R.drawable.ic_dialog_info).setContentTitle("Batas $app tercapai")
            .setContentText("Kamu sudah memakai $minutes menit hari ini.").setAutoCancel(true).build()
        manager.notify((packageName + today()).hashCode(), notification)
        delivery.edit().putBoolean(deliveredKey, true).apply()
    }

    private fun showPause(packageName: String, quotaMinutes: Int) {
        val delivery = getSharedPreferences("aria_limit_actions", MODE_PRIVATE)
        val shownKey = "pause:$packageName:${today()}:$quotaMinutes"
        if (delivery.getBoolean(shownKey, false)) return
        if (intervention != null && openReminderMode) removeIntervention()
        if (showIntervention(packageName, quotaMinutes)) {
            delivery.edit().putBoolean(shownKey, true).apply()
        }
    }

    private fun redirectHomeForLimit(packageName: String, minutes: Int) {
        val now = System.currentTimeMillis()
        if (now - blockRedirectAt < 5_000L) return
        blockRedirectAt = now
        notifyBlocked(packageName, minutes)
        performGlobalAction(GLOBAL_ACTION_HOME)
    }

    private fun notifyBlocked(packageName: String, minutes: Int) {
        val manager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) manager.createNotificationChannel(NotificationChannel("aria_limits", "Batas ARIA", NotificationManager.IMPORTANCE_DEFAULT))
        val app = appName(packageName)
        val notification = android.app.Notification.Builder(this, "aria_limits")
            .setSmallIcon(android.R.drawable.ic_dialog_info).setContentTitle("Jeda dari $app")
            .setContentText("Batas $minutes menit hari ini tercapai. ARIA mengembalikanmu ke layar utama; batas akan diperbarui besok.")
            .setAutoCancel(true).build()
        manager.notify(("blocked:" + packageName + today()).hashCode(), notification)
    }

    private fun showIntervention(packageName: String, quotaMinutes: Int): Boolean {
        if (!Settings.canDrawOverlays(this) || intervention != null) return false
        val density = resources.displayMetrics.density
        val card = LinearLayout(this).apply {
            orientation = LinearLayout.VERTICAL
            gravity = Gravity.START
            setPadding((22 * density).toInt(), (20 * density).toInt(), (22 * density).toInt(), (18 * density).toInt())
            background = GradientDrawable().apply {
                setColor(Color.rgb(28, 27, 25))
                cornerRadius = 24 * density
                setStroke((1.2f * density).toInt(), Color.rgb(154, 120, 62))
            }
            elevation = 14 * density
        }
        val title = TextView(this).apply {
            setTextColor(Color.rgb(250, 248, 244))
            textSize = 21f
            typeface = Typeface.DEFAULT_BOLD
            text = "Batas ${appName(packageName)} tercapai"
            setPadding(0, (7 * density).toInt(), 0, 0)
        }
        val body = TextView(this).apply {
            setTextColor(Color.rgb(232, 229, 222))
            textSize = 15f
            setLineSpacing(2 * density, 1f)
            text = pauseMessage(packageName, quotaMinutes)
            setPadding(0, (10 * density).toInt(), 0, (16 * density).toInt())
        }
        val dismiss = TextView(this).apply {
            setTextColor(Color.rgb(28, 27, 25))
            textSize = 14f
            typeface = Typeface.DEFAULT_BOLD
            gravity = Gravity.CENTER
            isEnabled = false
            isClickable = true
            text = "Tutup jeda dalam 15 dtk"
            setPadding((16 * density).toInt(), (13 * density).toInt(), (16 * density).toInt(), (13 * density).toInt())
            background = GradientDrawable().apply {
                setColor(Color.rgb(225, 203, 156))
                cornerRadius = 16 * density
            }
            setOnClickListener {
                if (isEnabled) {
                    incrementAchievementCounter("aria.achievements.completed_pauses")
                    removeIntervention()
                }
            }
        }
        val buttonParams = LinearLayout.LayoutParams(
            LinearLayout.LayoutParams.MATCH_PARENT,
            LinearLayout.LayoutParams.WRAP_CONTENT,
        ).apply { topMargin = (12 * density).toInt() }
        card.addView(title)
        card.addView(body)
        card.addView(dismiss, buttonParams)
        val type = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY else @Suppress("DEPRECATION") WindowManager.LayoutParams.TYPE_PHONE
        val flags = WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE or WindowManager.LayoutParams.FLAG_NOT_TOUCH_MODAL
        val width = (resources.displayMetrics.widthPixels - 36 * density).toInt()
        val params = WindowManager.LayoutParams(width, WindowManager.LayoutParams.WRAP_CONTENT, type, flags, PixelFormat.TRANSLUCENT).apply { gravity = Gravity.CENTER }
        return try {
            windowManager = getSystemService(Context.WINDOW_SERVICE) as WindowManager
            windowManager?.addView(card, params)
            intervention = card
            interventionDismissButton = dismiss
            interventionDeadlineElapsed = SystemClock.elapsedRealtime() + 15_000L
            openReminderMode = false
            handler.removeCallbacks(pauseTicker)
            handler.removeCallbacks(interventionTimeout)
            handler.post(pauseTicker)
            handler.postDelayed(interventionTimeout, 45_000L)
            true
        } catch (_: Exception) {
            removeIntervention()
            false
        }
    }

    private fun showOpenReminder(packageName: String) {
        if (!Settings.canDrawOverlays(this) || intervention != null) return
        val limit = limitFor(packageName)
        if (limit?.enabled == true && hasReachedLimit(packageName, limit)) return

        val delivery = getSharedPreferences("aria_limit_actions", MODE_PRIVATE)
        val cooldownKey = "open-reminder:$packageName"
        val now = System.currentTimeMillis()
        val lastShownAt = delivery.getLong(cooldownKey, 0L)
        if (lastShownAt > 0L && now < lastShownAt + OPEN_REMINDER_COOLDOWN_MS) return

        val density = resources.displayMetrics.density
        val card = LinearLayout(this).apply {
            orientation = LinearLayout.VERTICAL
            gravity = Gravity.START
            setPadding((22 * density).toInt(), (20 * density).toInt(), (22 * density).toInt(), (18 * density).toInt())
            background = GradientDrawable().apply {
                setColor(Color.rgb(28, 27, 25)); cornerRadius = 24 * density
                setStroke((1.2f * density).toInt(), Color.rgb(154, 120, 62))
            }
            elevation = 14 * density
        }
        val prompt = listOf(
            "Kamu membuka ${appName(packageName)} dengan tujuan tertentu?",
            "Apakah kamu sedang mencari hiburan, atau hanya membuka tanpa sadar?",
            "Sebelum mulai, apa yang ingin kamu temukan di sini?",
            "Hai, apa kabar—ada hal tertentu yang ingin kamu cek?",
            "Apakah ini waktu istirahat yang memang kamu pilih?",
            "Adakah tugas yang ingin kamu tuntaskan sebelum membuka ${appName(packageName)}?",
        ).random()
        val title = TextView(this).apply {
            setTextColor(Color.rgb(250, 248, 244)); textSize = 20f
            typeface = Typeface.DEFAULT_BOLD; text = "Sebelum mulai"
            setPadding(0, (8 * density).toInt(), 0, 0)
        }
        val body = TextView(this).apply {
            setTextColor(Color.rgb(232, 229, 222)); textSize = 15f
            setLineSpacing(2 * density, 1f); text = prompt
            setPadding(0, (10 * density).toInt(), 0, (12 * density).toInt())
        }
        val closeApp = TextView(this).apply {
            setTextColor(Color.rgb(250, 248, 244)); textSize = 14f
            typeface = Typeface.DEFAULT_BOLD; gravity = Gravity.CENTER
            text = "Tutup aplikasi"
            setPadding((16 * density).toInt(), (13 * density).toInt(), (16 * density).toInt(), (13 * density).toInt())
            background = GradientDrawable().apply { setColor(Color.rgb(105, 63, 48)); cornerRadius = 16 * density }
            setOnClickListener {
                incrementAchievementCounter("aria.achievements.intentional_exits")
                removeIntervention()
                performGlobalAction(GLOBAL_ACTION_HOME)
            }
        }
        val dismiss = TextView(this).apply {
            setTextColor(Color.rgb(28, 27, 25)); textSize = 14f
            typeface = Typeface.DEFAULT_BOLD; gravity = Gravity.CENTER
            isEnabled = false; isClickable = true; text = "Lanjutkan dalam 8 dtk"
            setPadding((16 * density).toInt(), (13 * density).toInt(), (16 * density).toInt(), (13 * density).toInt())
            background = GradientDrawable().apply { setColor(Color.rgb(225, 203, 156)); cornerRadius = 16 * density }
            setOnClickListener {
                if (isEnabled) {
                    removeIntervention()
                }
            }
        }
        val buttonParams = LinearLayout.LayoutParams(LinearLayout.LayoutParams.MATCH_PARENT, LinearLayout.LayoutParams.WRAP_CONTENT).apply { topMargin = (10 * density).toInt() }
        card.addView(title); card.addView(body)
        card.addView(closeApp, buttonParams); card.addView(dismiss, buttonParams)
        val type = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY else @Suppress("DEPRECATION") WindowManager.LayoutParams.TYPE_PHONE
        val width = (resources.displayMetrics.widthPixels - 36 * density).toInt()
        val params = WindowManager.LayoutParams(width, WindowManager.LayoutParams.WRAP_CONTENT, type,
            WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE or WindowManager.LayoutParams.FLAG_NOT_TOUCH_MODAL,
            PixelFormat.TRANSLUCENT).apply { gravity = Gravity.CENTER }
        try {
            windowManager = getSystemService(Context.WINDOW_SERVICE) as WindowManager
            windowManager?.addView(card, params)
            intervention = card; interventionDismissButton = dismiss
            interventionDeadlineElapsed = SystemClock.elapsedRealtime() + 8_000L
            openReminderMode = true
            handler.removeCallbacks(pauseTicker); handler.removeCallbacks(interventionTimeout)
            handler.post(pauseTicker)
            handler.postDelayed(interventionTimeout, 30_000L)
            delivery.edit().putLong(cooldownKey, now).apply()
        } catch (_: Exception) { removeIntervention() }
    }

    private fun pauseMessage(packageName: String, quotaMinutes: Int): String {
        val app = appName(packageName)
        val messages = listOf(
            "Batas $quotaMinutes menit untuk $app tercapai; ambil napas dan pilih apa yang kamu butuhkan sekarang.",
            "Apakah ada satu hal yang ingin kamu selesaikan sebelum kembali ke $app?",
            "Jika kamu sedang beristirahat, lanjutkan setelah jeda singkat ini dengan lebih sadar.",
            "Kamu boleh berhenti sejenak dan kembali ketika memang sudah siap.",
            "Apa yang paling kamu butuhkan sekarang: menyelesaikan sesuatu atau beristirahat?",
            "Beri dirimu jeda singkat, lalu tentukan apakah ingin kembali ke $app.",
        )
        val seed = (today() + packageName + quotaMinutes).hashCode()
        return messages[kotlin.math.abs(seed % messages.size)]
    }

    private fun removeIntervention() {
        handler.removeCallbacks(pauseTicker)
        handler.removeCallbacks(interventionTimeout)
        val view = intervention
        intervention = null
        interventionDismissButton = null
        interventionDeadlineElapsed = 0L
        openReminderMode = false
        if (view != null && view.isAttachedToWindow) {
            try { windowManager?.removeViewImmediate(view) } catch (_: Exception) { }
        }
    }

    /**
     * Use movement metadata only; ARIA never reads labels, captions, comments,
     * or video content. YouTube Shorts may report pager indices or scroll
     * positions while leaving scrollDeltaY at zero, so those signals are used
     * as a YouTube-only fallback.
     */
    private fun isDistinctScroll(event: AccessibilityEvent, packageName: String): Boolean {
        val now = System.currentTimeMillis()
        var delta = if (Build.VERSION.SDK_INT >= 28) kotlin.math.abs(event.scrollDeltaY) else 0
        var pageChanged = false

        if (packageName == "com.google.android.youtube" && delta == 0) {
            val className = event.className?.toString().orEmpty()
            val isPager = className.contains("ViewPager", ignoreCase = true) ||
                className.contains("RecyclerView", ignoreCase = true)
            val hasDiscretePageChange = event.fromIndex >= 0 &&
                event.toIndex >= 0 && event.fromIndex != event.toIndex &&
                (className.contains("ViewPager", ignoreCase = true) || event.itemCount in 1..2)
            if (hasDiscretePageChange) {
                lastPagerIndex[packageName] = event.toIndex
                pageChanged = true
            }

            // A scroll-position fallback is limited to pager-like containers;
            // counting every YouTube scrollable view would include comments.
            if (!pageChanged && isPager && event.maxScrollY > 0) {
                val previousY = lastScrollY.put(packageName, event.scrollY)
                if (previousY != null) delta = kotlin.math.abs(event.scrollY - previousY)
            }
        }

        val density = resources.displayMetrics.density
        val minimum = if (packageName == "com.google.android.youtube") {
            (resources.displayMetrics.heightPixels * 0.012f).toInt().coerceAtLeast((28 * density).toInt())
        } else {
            (resources.displayMetrics.heightPixels * 0.012f).toInt().coerceAtLeast((28 * density).toInt())
        }
        if (!pageChanged && delta < minimum) return false
        if (now - (lastCountedScrollAt[packageName] ?: 0L) < 260L) return false
        lastCountedScrollAt[packageName] = now
        return true
    }

    private fun incrementAchievementCounter(key: String) {
        val prefs = getSharedPreferences("FlutterSharedPreferences", MODE_PRIVATE)
        val flutterKey = "flutter.$key"
        val value = prefs.getInt(flutterKey, prefs.getInt(key, 0))
        prefs.edit().putInt(flutterKey, value + 1).apply()
    }

    private fun incrementDaily(packageName: String): Int {
        val prefs = getSharedPreferences("aria_scroll_counts", MODE_PRIVATE)
        val key = "$packageName:${today()}"
        val next = prefs.getInt(key, 0) + 1
        prefs.edit().putInt(key, next).apply()
        return next
    }

    private fun showIsland(packageName: String) {
        if (!Settings.canDrawOverlays(this)) return
        ensureIsland()
        if (SystemClock.elapsedRealtime() < (reminderUntil[packageName] ?: 0L)) return
        islandText?.text = "${sessionCounts[packageName] ?: 0}x"
        islandText?.setTextColor(Color.rgb(250, 248, 244))
        island?.visibility = View.VISIBLE
    }

    private fun maybeShowReminder(packageName: String, count: Int) {
        val milestones = listOf(20, 40, 60, 100, 150, 200)
        val milestone = milestones.lastOrNull { count >= it } ?: return
        val shown = shownMilestones.getOrPut(packageName) { mutableSetOf() }
        if (!shown.add(milestone)) return
        val messages = listOf(
            "Sudah $count video. Mau rehat sebentar?",
            "Kamu sudah menonton $count video. Cek dulu, masih ingin lanjut?",
            "$count video berlalu. Ambil jeda kecil kalau kamu membutuhkannya.",
            "Sesi ini sudah $count video. Waktunya kembali ke hal yang penting bagimu?",
        )
        val daySeed = today().hashCode() xor packageName.hashCode() xor milestone
        islandText?.text = messages[kotlin.math.abs(daySeed % messages.size)]
        islandText?.setTextColor(Color.rgb(225, 203, 156))
        reminderUntil[packageName] = SystemClock.elapsedRealtime() + 8_000L
        clearIslandReminderReset()
        islandReminderReset = Runnable {
            reminderUntil.remove(packageName)
            if (foregroundPackage == packageName) showIsland(packageName)
            islandReminderReset = null
        }.also { handler.postDelayed(it, 8_000L) }
    }

    private fun ensureIsland() {
        if (island != null) return
        val density = resources.displayMetrics.density
        val container = LinearLayout(this).apply {
            orientation = LinearLayout.VERTICAL
            setPadding((16 * density).toInt(), (10 * density).toInt(), (16 * density).toInt(), (10 * density).toInt())
            background = GradientDrawable().apply {
                setColor(Color.rgb(28, 27, 25)); cornerRadius = 22 * density
                setStroke((1 * density).toInt(), Color.rgb(154, 120, 62))
            }
            elevation = 12 * density
            importantForAccessibility = View.IMPORTANT_FOR_ACCESSIBILITY_NO
        }
        islandText = TextView(this).apply {
            setTextColor(Color.rgb(250, 248, 244)); textSize = 14f
            typeface = Typeface.create(Typeface.DEFAULT, Typeface.BOLD); includeFontPadding = false
        }
        container.addView(islandText)
        val type = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY else @Suppress("DEPRECATION") WindowManager.LayoutParams.TYPE_PHONE
        val params = WindowManager.LayoutParams(WindowManager.LayoutParams.WRAP_CONTENT, WindowManager.LayoutParams.WRAP_CONTENT, type,
            WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE or WindowManager.LayoutParams.FLAG_NOT_TOUCHABLE,
            PixelFormat.TRANSLUCENT).apply { gravity = Gravity.TOP or Gravity.CENTER_HORIZONTAL; y = (6 * density).toInt() }
        try {
            windowManager = getSystemService(Context.WINDOW_SERVICE) as WindowManager
            windowManager?.addView(container, params)
            island = container
        } catch (_: Exception) { removeIsland() }
    }

    private fun removeIsland() {
        val view = island ?: return
        island = null
        islandText = null
        if (view.isAttachedToWindow) {
            try { windowManager?.removeViewImmediate(view) } catch (_: Exception) { }
        }
    }

    private fun clearIslandReminderReset() {
        islandReminderReset?.let(handler::removeCallbacks)
        islandReminderReset = null
    }

    override fun onInterrupt() {
        handler.removeCallbacks(limitPoll)
        clearIslandReminderReset()
        removeIsland()
        removeIntervention()
    }

    override fun onDestroy() {
        handler.removeCallbacks(limitPoll)
        clearIslandReminderReset()
        removeIsland()
        removeIntervention()
        windowManager = null
        super.onDestroy()
    }
    private fun appName(packageName: String) = when (packageName) {
        "com.instagram.android" -> "Instagram"
        "com.google.android.youtube" -> "YouTube"
        "com.zhiliaoapp.musically", "com.ss.android.ugc.trill" -> "TikTok"
        else -> packageName.substringAfterLast('.')
    }
    private fun today(): String = SimpleDateFormat("yyyy-MM-dd", Locale.US).format(Date())
}
