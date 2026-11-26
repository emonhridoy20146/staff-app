package bd.howlader.staff_app

import android.app.*
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.content.pm.ServiceInfo
import android.graphics.Color
import android.location.Location
import android.location.LocationListener
import android.location.LocationManager
import android.os.Build
import android.os.Handler
import android.os.IBinder
import android.os.Looper
import android.os.PowerManager
import androidx.core.app.NotificationCompat
import okhttp3.MediaType.Companion.toMediaType
import okhttp3.OkHttpClient
import okhttp3.Request
import okhttp3.RequestBody.Companion.toRequestBody
import org.json.JSONArray
import org.json.JSONObject
import java.io.File
import java.text.SimpleDateFormat
import java.util.*
import java.util.concurrent.TimeUnit

class LocationTrackingService : Service() {

    companion object {
        const val CHANNEL_ID = "duty_tracking"
        const val CHANNEL_ID_WARNING = "duty_tracking_warning"
        const val NOTIFICATION_ID = 7701
        const val POINTS_FILE = "native_location_points.jsonl"
        private const val PREFS_NAME = "tracking_prefs"
        private const val MIN_INTERVAL_MS = 15_000L
        private const val MIN_DISTANCE_M = 10f
        private const val UPLOAD_INTERVAL_MS = 120_000L
        private const val GPS_CHECK_INTERVAL_MS = 10_000L

        fun start(context: Context, title: String, text: String) {
            val intent = Intent(context, LocationTrackingService::class.java).apply {
                putExtra("title", title)
                putExtra("text", text)
            }
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                context.startForegroundService(intent)
            } else {
                context.startService(intent)
            }
        }

        fun stop(context: Context) {
            context.stopService(Intent(context, LocationTrackingService::class.java))
        }

        fun isRunning(context: Context): Boolean {
            val manager = context.getSystemService(ACTIVITY_SERVICE) as ActivityManager
            @Suppress("DEPRECATION")
            for (service in manager.getRunningServices(Int.MAX_VALUE)) {
                if (service.service.className == LocationTrackingService::class.java.name) {
                    return true
                }
            }
            return false
        }

        /** Latest running instance, so a new token can refresh the notification at once. */
        @Volatile
        private var instance: LocationTrackingService? = null

        /**
         * FR-M-077 (contract 1.49.0): the service uploads with a long-lived, points-only tracking token bound to
         * the device — never the 15-minute access token, which nothing can refresh while the app is closed.
         */
        fun storeCredentials(
            context: Context,
            apiBaseUrl: String,
            trackingToken: String,
            expiresAtMs: Long,
            deviceId: String,
            reauthText: String?,
        ) {
            val editor = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE).edit()
                .putString("api_base_url", apiBaseUrl)
                .putString("tracking_token", trackingToken)
                .putLong("tracking_token_expires_at", expiresAtMs)
                .putString("device_id", deviceId)
                .putBoolean("auth_failed", false)
                .remove("access_token") // written by builds before FR-M-077
            if (!reauthText.isNullOrBlank()) editor.putString("reauth_text", reauthText)
            editor.apply()
            instance?.refreshNotification()
        }

        /** Duty end / logout: forget the token. Buffered points stay in [POINTS_FILE]. */
        fun clearCredentials(context: Context) {
            context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE).edit()
                .remove("tracking_token")
                .remove("tracking_token_expires_at")
                .remove("access_token")
                .putBoolean("auth_failed", false)
                .apply()
        }

        fun isAuthFailed(context: Context): Boolean =
            context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE).getBoolean("auth_failed", false)
    }

    private var locationManager: LocationManager? = null
    private var wakeLock: PowerManager.WakeLock? = null
    private val handler = Handler(Looper.getMainLooper())
    private var gpsWasOn = true
    private var notifTitle = "On duty"
    private var notifText = "Location is being tracked"
    private val isoFormat = SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'", Locale.US).apply {
        timeZone = TimeZone.getTimeZone("UTC")
    }

    private val httpClient by lazy {
        OkHttpClient.Builder()
            .connectTimeout(30, TimeUnit.SECONDS)
            .writeTimeout(30, TimeUnit.SECONDS)
            .readTimeout(30, TimeUnit.SECONDS)
            .build()
    }

    private val uploadRunnable = object : Runnable {
        override fun run() {
            Thread { uploadBufferedPoints() }.start()
            handler.postDelayed(this, UPLOAD_INTERVAL_MS)
        }
    }

    private val gpsCheckRunnable = object : Runnable {
        override fun run() {
            checkGpsAndUpdateNotification()
            handler.postDelayed(this, GPS_CHECK_INTERVAL_MS)
        }
    }

    private val gpsReceiver = object : BroadcastReceiver() {
        override fun onReceive(context: Context?, intent: Intent?) {
            if (intent?.action == LocationManager.PROVIDERS_CHANGED_ACTION) {
                checkGpsAndUpdateNotification()
            }
        }
    }

    private val locationListener = object : LocationListener {
        override fun onLocationChanged(location: Location) {
            writePoint(location)
        }

        @Deprecated("Deprecated in Java")
        override fun onStatusChanged(provider: String?, status: Int, extras: android.os.Bundle?) {}
        override fun onProviderEnabled(provider: String) {
            checkGpsAndUpdateNotification()
            startLocationUpdates()
        }
        override fun onProviderDisabled(provider: String) {
            checkGpsAndUpdateNotification()
        }
    }

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onCreate() {
        super.onCreate()
        instance = this
        createNotificationChannels()
        registerReceiver(gpsReceiver, IntentFilter(LocationManager.PROVIDERS_CHANGED_ACTION))
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        notifTitle = intent?.getStringExtra("title") ?: notifTitle
        notifText = intent?.getStringExtra("text") ?: notifText

        val gpsOn = isGpsEnabled()
        gpsWasOn = gpsOn
        val notification = currentNotification()

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            startForeground(NOTIFICATION_ID, notification, ServiceInfo.FOREGROUND_SERVICE_TYPE_LOCATION)
        } else {
            startForeground(NOTIFICATION_ID, notification)
        }

        acquireWakeLock()
        startLocationUpdates()
        handler.postDelayed(uploadRunnable, UPLOAD_INTERVAL_MS)
        handler.postDelayed(gpsCheckRunnable, GPS_CHECK_INTERVAL_MS)

        return START_STICKY
    }

    override fun onDestroy() {
        super.onDestroy()
        if (instance === this) instance = null
        handler.removeCallbacks(uploadRunnable)
        handler.removeCallbacks(gpsCheckRunnable)
        try { unregisterReceiver(gpsReceiver) } catch (_: Exception) {}
        stopLocationUpdates()
        Thread { uploadBufferedPoints() }.start()
        releaseWakeLock()
    }

    override fun onTaskRemoved(rootIntent: Intent?) {
        super.onTaskRemoved(rootIntent)
    }

    private fun isGpsEnabled(): Boolean {
        val lm = locationManager ?: getSystemService(LOCATION_SERVICE) as LocationManager
        return lm.isProviderEnabled(LocationManager.GPS_PROVIDER)
    }

    private fun checkGpsAndUpdateNotification() {
        val gpsOn = isGpsEnabled()
        if (gpsOn == gpsWasOn) return
        gpsWasOn = gpsOn

        refreshNotification()

        if (gpsOn) {
            startLocationUpdates()
        }
    }

    /** GPS off wins (high-priority warning); otherwise the duty notification, with the "open the app" line
     *  while the server refuses the tracking token. */
    private fun currentNotification(): Notification =
        if (!isGpsEnabled()) buildWarningNotification() else buildOkNotification()

    fun refreshNotification() {
        try {
            getSystemService(NotificationManager::class.java).notify(NOTIFICATION_ID, currentNotification())
        } catch (_: Exception) {}
    }

    private fun setAuthFailed(failed: Boolean) {
        val prefs = getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
        if (prefs.getBoolean("auth_failed", false) == failed) return
        prefs.edit().putBoolean("auth_failed", failed).apply()
        handler.post { refreshNotification() }
    }

    private fun createNotificationChannels() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val normalChannel = NotificationChannel(
                CHANNEL_ID,
                "Duty tracking",
                NotificationManager.IMPORTANCE_LOW
            ).apply {
                description = "Shows while your location is being tracked during duty"
                setShowBadge(false)
            }

            val warningChannel = NotificationChannel(
                CHANNEL_ID_WARNING,
                "Location warning",
                NotificationManager.IMPORTANCE_HIGH
            ).apply {
                description = "Warning when GPS is turned off during duty"
                setShowBadge(true)
                enableLights(true)
                lightColor = Color.RED
                enableVibration(true)
            }

            val nm = getSystemService(NotificationManager::class.java)
            nm.createNotificationChannel(normalChannel)
            nm.createNotificationChannel(warningChannel)
        }
    }

    private fun buildOkNotification(): Notification {
        val launchIntent = packageManager.getLaunchIntentForPackage(packageName)
        val pendingIntent = PendingIntent.getActivity(
            this, 0, launchIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
        val authFailed = isAuthFailed(this)
        val reauth = getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE).getString("reauth_text", null)
            ?: "লাইভ লোকেশন পাঠানো যাচ্ছে না। অ্যাপটি একবার খুলুন। / Live location can't be sent. Please open the app once."
        val text = if (authFailed) reauth else notifText
        return NotificationCompat.Builder(this, CHANNEL_ID)
            .setContentTitle(if (authFailed) "⚠️ $notifTitle" else "✅ $notifTitle")
            .setContentText(text)
            .setStyle(NotificationCompat.BigTextStyle().bigText(if (authFailed) "$notifText\n$reauth" else notifText))
            .setSmallIcon(android.R.drawable.ic_menu_mylocation)
            .setOngoing(true)
            .setContentIntent(pendingIntent)
            .setColor(Color.parseColor(if (authFailed) "#B45309" else "#4CAF50"))
            .setColorized(true)
            .setForegroundServiceBehavior(NotificationCompat.FOREGROUND_SERVICE_IMMEDIATE)
            .build()
    }

    private fun buildWarningNotification(): Notification {
        val gpsIntent = Intent(android.provider.Settings.ACTION_LOCATION_SOURCE_SETTINGS)
        val gpsPending = PendingIntent.getActivity(
            this, 1, gpsIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
        return NotificationCompat.Builder(this, CHANNEL_ID_WARNING)
            .setContentTitle("⚠️ GPS বন্ধ আছে! / GPS is OFF!")
            .setContentText("লোকেশন ডাটা পাঠানো যাচ্ছে না। অনুগ্রহ করে GPS চালু করুন।")
            .setStyle(NotificationCompat.BigTextStyle()
                .bigText("লোকেশন ডাটা পাঠানো যাচ্ছে না। অনুগ্রহ করে GPS চালু করুন।\nLocation data cannot be sent. Please turn on GPS."))
            .setSmallIcon(android.R.drawable.ic_dialog_alert)
            .setOngoing(true)
            .setContentIntent(gpsPending)
            .setColor(Color.parseColor("#F44336"))
            .setColorized(true)
            .setPriority(NotificationCompat.PRIORITY_HIGH)
            .setForegroundServiceBehavior(NotificationCompat.FOREGROUND_SERVICE_IMMEDIATE)
            .build()
    }

    private fun acquireWakeLock() {
        val pm = getSystemService(POWER_SERVICE) as PowerManager
        wakeLock = pm.newWakeLock(PowerManager.PARTIAL_WAKE_LOCK, "howlader:tracking").apply {
            acquire()
        }
    }

    private fun releaseWakeLock() {
        wakeLock?.let {
            if (it.isHeld) it.release()
        }
        wakeLock = null
    }

    private fun startLocationUpdates() {
        try {
            locationManager = getSystemService(LOCATION_SERVICE) as LocationManager
            val providers = listOf(LocationManager.GPS_PROVIDER, LocationManager.NETWORK_PROVIDER)
            for (provider in providers) {
                if (locationManager?.isProviderEnabled(provider) == true) {
                    try {
                        @Suppress("MissingPermission")
                        locationManager?.requestLocationUpdates(
                            provider, MIN_INTERVAL_MS, MIN_DISTANCE_M, locationListener
                        )
                    } catch (_: SecurityException) {}
                }
            }
        } catch (_: Exception) {}
    }

    private fun stopLocationUpdates() {
        try {
            locationManager?.removeUpdates(locationListener)
        } catch (_: Exception) {}
        locationManager = null
    }

    private fun writePoint(location: Location) {
        try {
            val json = JSONObject().apply {
                put("t", isoFormat.format(Date(location.time)))
                put("lat", location.latitude)
                put("lng", location.longitude)
                put("acc", location.accuracy.toDouble())
                if (location.hasSpeed()) put("spd", location.speed.toDouble())
                if (location.hasBearing()) put("hdg", location.bearing.toDouble())
                if (location.hasAltitude()) put("alt", location.altitude)
                put("mock", location.isFromMockProvider)
            }
            val file = File(filesDir, POINTS_FILE)
            file.appendText(json.toString() + "\n")
        } catch (_: Exception) {}
    }

    private fun uploadBufferedPoints() {
        val prefs = getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
        val apiBaseUrl = prefs.getString("api_base_url", null) ?: return
        val deviceId = prefs.getString("device_id", null) ?: return
        // FR-M-077: points go up only with the tracking token. None, or past its expiry: keep every point
        // buffered and ask (in the notification) for the app to be opened, which renews the token.
        val trackingToken = prefs.getString("tracking_token", null)
        val expiresAt = prefs.getLong("tracking_token_expires_at", 0L)
        if (trackingToken == null || (expiresAt > 0L && System.currentTimeMillis() >= expiresAt)) {
            setAuthFailed(true)
            return
        }

        val file = File(filesDir, POINTS_FILE)
        if (!file.exists()) return

        val lines: List<String>
        synchronized(this) {
            lines = file.readLines().filter { it.isNotBlank() }
            if (lines.isEmpty()) return
            file.writeText("")
        }

        val pointsArray = JSONArray()
        for (line in lines) {
            try {
                val p = JSONObject(line)
                val point = JSONObject().apply {
                    put("t", p.getString("t"))
                    put("lat", p.getDouble("lat"))
                    put("lng", p.getDouble("lng"))
                    put("acc", p.getDouble("acc"))
                    if (p.has("spd")) put("spd", p.getDouble("spd"))
                    if (p.has("hdg")) put("hdg", p.getDouble("hdg"))
                    if (p.has("alt")) put("alt", p.getDouble("alt"))
                    if (p.has("mock")) put("mock", p.getBoolean("mock"))
                }
                pointsArray.put(point)
            } catch (_: Exception) {}
        }

        if (pointsArray.length() == 0) return

        val body = JSONObject().apply {
            put("deviceId", deviceId)
            put("points", pointsArray)
        }

        try {
            val request = Request.Builder()
                .url("$apiBaseUrl/location/points")
                // Contract 1.49.0 (field-api ADR-067): the tracking scheme, accepted only by this route.
                .addHeader("Authorization", "Tracking $trackingToken")
                .addHeader("Content-Type", "application/json")
                .post(body.toString().toRequestBody("application/json".toMediaType()))
                .build()

            val response = httpClient.newCall(request).execute()
            if (response.isSuccessful) {
                response.close()
                setAuthFailed(false)
                return
            }

            val code = response.code
            response.close()
            // Refused token (401 TRACKING_TOKEN_INVALID / _EXPIRED; never refreshed here): points stay buffered
            // (below) and the notification asks to open the app, which issues a new one.
            if (code == 401 || code == 403) setAuthFailed(true)
            synchronized(this) {
                val existing = file.readLines().filter { it.isNotBlank() }
                val restored = lines + existing
                file.writeText(restored.joinToString("\n") + "\n")
            }
        } catch (_: Exception) {
            synchronized(this) {
                val existing = file.readLines().filter { it.isNotBlank() }
                val restored = lines + existing
                file.writeText(restored.joinToString("\n") + "\n")
            }
        }
    }
}
