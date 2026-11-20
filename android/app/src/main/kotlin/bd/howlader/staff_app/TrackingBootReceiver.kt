package bd.howlader.staff_app

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import java.io.File

/**
 * Restarts [LocationTrackingService] after a device reboot if the user was
 * on duty when the phone shut down. The "on duty" flag is a file marker
 * written by the method channel when duty starts and removed on duty end.
 */
class TrackingBootReceiver : BroadcastReceiver() {

    companion object {
        const val DUTY_FLAG_FILE = "on_duty_flag"

        fun setOnDuty(context: Context, onDuty: Boolean) {
            val file = File(context.filesDir, DUTY_FLAG_FILE)
            if (onDuty) {
                file.writeText("1")
            } else {
                file.delete()
            }
        }

        fun isOnDuty(context: Context): Boolean {
            return File(context.filesDir, DUTY_FLAG_FILE).exists()
        }
    }

    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action != Intent.ACTION_BOOT_COMPLETED &&
            intent.action != Intent.ACTION_MY_PACKAGE_REPLACED) return

        if (!isOnDuty(context)) return

        // Restart the native location service with default strings.
        // The Flutter engine will update the notification text when it starts.
        LocationTrackingService.start(context, "On duty", "Location is being tracked")
    }
}
