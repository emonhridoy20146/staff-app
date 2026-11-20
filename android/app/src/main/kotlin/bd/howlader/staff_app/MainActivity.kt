package bd.howlader.staff_app

import android.Manifest
import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Build
import android.os.PowerManager
import android.provider.Settings
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val channel = "com.howlader.staff/permissions"
    private var pendingResult: MethodChannel.Result? = null
    private var pendingRequestCode: Int = 0

    companion object {
        private const val RC_CAMERA = 1001
        private const val RC_NOTIFICATIONS = 1002
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channel).setMethodCallHandler { call, result ->
            when (call.method) {
                "requestCamera" -> requestCamera(result)
                "requestNotifications" -> requestNotifications(result)
                "requestBatteryOptimisation" -> requestBatteryOptimisation(result)
                "isCameraGranted" -> result.success(
                    ContextCompat.checkSelfPermission(this, Manifest.permission.CAMERA) == PackageManager.PERMISSION_GRANTED
                )
                "isNotificationsGranted" -> {
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                        result.success(
                            ContextCompat.checkSelfPermission(this, Manifest.permission.POST_NOTIFICATIONS) == PackageManager.PERMISSION_GRANTED
                        )
                    } else {
                        result.success(true)
                    }
                }
                "isBatteryOptimised" -> {
                    val pm = getSystemService(POWER_SERVICE) as PowerManager
                    result.success(!pm.isIgnoringBatteryOptimizations(packageName))
                }
                "openAppSettings" -> {
                    val intent = Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS).apply {
                        data = Uri.fromParts("package", packageName, null)
                    }
                    startActivity(intent)
                    result.success(true)
                }
                "storeTrackingCredentials" -> {
                    val apiBaseUrl = call.argument<String>("apiBaseUrl") ?: ""
                    val accessToken = call.argument<String>("accessToken") ?: ""
                    val deviceId = call.argument<String>("deviceId") ?: ""
                    LocationTrackingService.storeCredentials(this, apiBaseUrl, accessToken, deviceId)
                    result.success(true)
                }
                "updateTrackingToken" -> {
                    val accessToken = call.argument<String>("accessToken") ?: ""
                    LocationTrackingService.updateToken(this, accessToken)
                    result.success(true)
                }
                // ── Native location service ──
                "startNativeTracking" -> {
                    val title = call.argument<String>("title") ?: "On duty"
                    val text = call.argument<String>("text") ?: "Location is being tracked"
                    TrackingBootReceiver.setOnDuty(this, true)
                    LocationTrackingService.start(this, title, text)
                    result.success(true)
                }
                "stopNativeTracking" -> {
                    TrackingBootReceiver.setOnDuty(this, false)
                    LocationTrackingService.stop(this)
                    result.success(true)
                }
                "isNativeTrackingRunning" -> {
                    result.success(LocationTrackingService.isRunning(this))
                }
                "readBufferedPoints" -> {
                    result.success(readAndClearBufferedPoints())
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun readAndClearBufferedPoints(): String {
        val file = java.io.File(filesDir, LocationTrackingService.POINTS_FILE)
        if (!file.exists()) return "[]"
        return try {
            val lines = file.readLines().filter { it.isNotBlank() }
            file.writeText("")
            "[${lines.joinToString(",")}]"
        } catch (_: Exception) {
            "[]"
        }
    }

    private fun requestCamera(result: MethodChannel.Result) {
        if (ContextCompat.checkSelfPermission(this, Manifest.permission.CAMERA) == PackageManager.PERMISSION_GRANTED) {
            result.success("granted")
            return
        }
        if (!ActivityCompat.shouldShowRequestPermissionRationale(this, Manifest.permission.CAMERA) &&
            ContextCompat.checkSelfPermission(this, Manifest.permission.CAMERA) == PackageManager.PERMISSION_DENIED) {
            // Check if we've asked before — if rationale is false and denied, it might be permanently denied
            // But first time it's also false, so we try requesting
        }
        pendingResult = result
        pendingRequestCode = RC_CAMERA
        ActivityCompat.requestPermissions(this, arrayOf(Manifest.permission.CAMERA), RC_CAMERA)
    }

    private fun requestNotifications(result: MethodChannel.Result) {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.TIRAMISU) {
            result.success("granted")
            return
        }
        if (ContextCompat.checkSelfPermission(this, Manifest.permission.POST_NOTIFICATIONS) == PackageManager.PERMISSION_GRANTED) {
            result.success("granted")
            return
        }
        pendingResult = result
        pendingRequestCode = RC_NOTIFICATIONS
        ActivityCompat.requestPermissions(this, arrayOf(Manifest.permission.POST_NOTIFICATIONS), RC_NOTIFICATIONS)
    }

    private fun requestBatteryOptimisation(result: MethodChannel.Result) {
        val pm = getSystemService(POWER_SERVICE) as PowerManager
        if (pm.isIgnoringBatteryOptimizations(packageName)) {
            result.success("granted")
            return
        }
        try {
            @Suppress("BatteryLife")
            val intent = Intent(Settings.ACTION_REQUEST_IGNORE_BATTERY_OPTIMIZATIONS).apply {
                data = Uri.parse("package:$packageName")
            }
            startActivity(intent)
            // Re-check after the dialog
            result.success(
                if (pm.isIgnoringBatteryOptimizations(packageName)) "granted" else "denied"
            )
        } catch (_: Exception) {
            result.success("denied")
        }
    }

    override fun onRequestPermissionsResult(requestCode: Int, permissions: Array<out String>, grantResults: IntArray) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        val result = pendingResult ?: return
        if (requestCode != pendingRequestCode) return
        pendingResult = null

        if (grantResults.isNotEmpty() && grantResults[0] == PackageManager.PERMISSION_GRANTED) {
            result.success("granted")
        } else {
            val perm = permissions.firstOrNull() ?: ""
            if (!ActivityCompat.shouldShowRequestPermissionRationale(this, perm)) {
                result.success("permanently_denied")
            } else {
                result.success("denied")
            }
        }
    }
}
