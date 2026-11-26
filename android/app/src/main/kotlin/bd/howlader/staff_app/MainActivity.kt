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
        private const val RC_BATTERY = 1003
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
                    if (Build.VERSION.SDK_INT < Build.VERSION_CODES.M) {
                        result.success(false)
                    } else {
                        val pm = getSystemService(POWER_SERVICE) as PowerManager
                        result.success(!pm.isIgnoringBatteryOptimizations(packageName))
                    }
                }
                "openBatterySettings" -> result.success(openBatterySettings())
                // FR-M-060: survives an app reinstall (same signing key, same phone), so the device stays approved.
                "androidId" -> result.success(Settings.Secure.getString(contentResolver, Settings.Secure.ANDROID_ID))
                "openAppSettings" -> {
                    val intent = Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS).apply {
                        data = Uri.fromParts("package", packageName, null)
                    }
                    startActivity(intent)
                    result.success(true)
                }
                "storeTrackingCredentials" -> {
                    // FR-M-076: the points-only tracking token (contract 1.49.0), not the access token.
                    LocationTrackingService.storeCredentials(
                        this,
                        call.argument<String>("apiBaseUrl") ?: "",
                        call.argument<String>("trackingToken") ?: "",
                        call.argument<Number>("expiresAtMs")?.toLong() ?: 0L,
                        call.argument<String>("deviceId") ?: "",
                        call.argument<String>("reauthText"),
                    )
                    result.success(true)
                }
                "clearTrackingCredentials" -> {
                    LocationTrackingService.clearCredentials(this)
                    result.success(true)
                }
                "isTrackingAuthFailed" -> result.success(LocationTrackingService.isAuthFailed(this))
                "manufacturer" -> result.success(Build.MANUFACTURER ?: "")
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

    private fun component(pkg: String, cls: String) =
        Intent().setClassName(pkg, if (cls.startsWith(".")) pkg + cls else cls)

    // Brand screens that hold the real "run in background / autostart" switch.
    private fun oemBatteryIntents(): List<Intent> {
        val m = Build.MANUFACTURER.lowercase()
        return when {
            m.contains("xiaomi") || m.contains("redmi") || m.contains("poco") -> listOf(
                component("com.miui.powerkeeper", "com.miui.powerkeeper.ui.HiddenAppsConfigActivity")
                    .putExtra("package_name", packageName).putExtra("package_label", "Howlader"),
                component("com.miui.securitycenter", "com.miui.permcenter.autostart.AutoStartManagementActivity"),
            )
            m.contains("oppo") || m.contains("realme") -> listOf(
                component("com.coloros.safecenter", "com.coloros.safecenter.permission.startup.StartupAppListActivity"),
                component("com.coloros.safecenter", "com.coloros.safecenter.startupapp.StartupAppListActivity"),
                component("com.oppo.safe", "com.oppo.safe.permission.startup.StartupAppListActivity"),
                component("com.coloros.oppoguardelf", "com.coloros.powermanager.fuelgaue.PowerUsageModelActivity"),
            )
            m.contains("vivo") || m.contains("iqoo") -> listOf(
                component("com.vivo.permissionmanager", "com.vivo.permissionmanager.activity.BgStartUpManagerActivity"),
                component("com.iqoo.secure", "com.iqoo.secure.ui.phoneoptimize.AddWhiteListActivity"),
                component("com.iqoo.secure", "com.iqoo.secure.ui.phoneoptimize.BgStartUpManager"),
            )
            m.contains("huawei") || m.contains("honor") -> listOf(
                component("com.huawei.systemmanager", "com.huawei.systemmanager.startupmgr.ui.StartupNormalAppListActivity"),
                component("com.huawei.systemmanager", "com.huawei.systemmanager.optimize.process.ProtectActivity"),
            )
            m.contains("samsung") -> listOf(
                component("com.samsung.android.lool", "com.samsung.android.sm.battery.ui.BatteryActivity"),
                component("com.samsung.android.lool", "com.samsung.android.sm.ui.battery.BatteryActivity"),
            )
            m.contains("oneplus") -> listOf(
                component("com.oneplus.security", "com.oneplus.security.chainlaunch.view.ChainLaunchAppListActivity"),
            )
            m.contains("tecno") || m.contains("infinix") || m.contains("itel") -> listOf(
                component("com.transsion.phonemaster", "com.cyin.himgr.autostart.AutoStartActivity"),
                component("com.transsion.phonemaster", "com.cyin.himgr.whitelist.view.WhiteListActivity"),
            )
            m.contains("asus") -> listOf(
                component("com.asus.mobilemanager", "com.asus.mobilemanager.autostart.AutoStartActivity"),
            )
            m.contains("nokia") || m.contains("hmd") -> listOf(
                component("com.evenwell.powersaving.g3", "com.evenwell.powersaving.g3.exception.PowerSaverExceptionActivity"),
            )
            else -> emptyList()
        }
    }

    // Opens the best settings screen we can find for turning battery optimisation off.
    private fun openBatterySettings(): Boolean {
        val oem = oemBatteryIntents()
        val m = Build.MANUFACTURER.lowercase()
        // Brands that hide or ignore the stock screen get their own screen first.
        val oemFirst = listOf("xiaomi", "redmi", "poco", "oppo", "realme", "vivo", "iqoo", "huawei", "honor", "tecno", "infinix", "itel")
            .any { m.contains(it) }
        val stock = buildList {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                add(Intent(Settings.ACTION_IGNORE_BATTERY_OPTIMIZATION_SETTINGS))
            }
            add(Intent(Settings.ACTION_BATTERY_SAVER_SETTINGS))
        }
        val appInfo = Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS).apply {
            data = Uri.fromParts("package", packageName, null)
        }
        val chain = (if (oemFirst) oem + stock else stock + oem) + appInfo
        return chain.any {
            try {
                startActivity(it.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK))
                true
            } catch (_: Exception) {
                false
            }
        }
    }

    private fun requestBatteryOptimisation(result: MethodChannel.Result) {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.M) {
            result.success("granted")
            return
        }
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
            pendingResult = result
            pendingRequestCode = RC_BATTERY
            @Suppress("DEPRECATION")
            startActivityForResult(intent, RC_BATTERY)
        } catch (_: Exception) {
            pendingResult = null
            try {
                startActivity(Intent(Settings.ACTION_IGNORE_BATTERY_OPTIMIZATION_SETTINGS))
            } catch (_: Exception) {
            }
            result.success("denied")
        }
    }

    @Suppress("DEPRECATION")
    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode != RC_BATTERY) return
        val result = pendingResult ?: return
        pendingResult = null
        val pm = getSystemService(POWER_SERVICE) as PowerManager
        result.success(if (pm.isIgnoringBatteryOptimizations(packageName)) "granted" else "denied")
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
