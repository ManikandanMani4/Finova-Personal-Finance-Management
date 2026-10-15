
package com.example.untitled

import android.content.ComponentName
import android.content.Context
import android.service.notification.NotificationListenerService
import android.service.notification.StatusBarNotification
import android.util.Log
import io.flutter.plugin.common.MethodChannel
import org.json.JSONArray
import org.json.JSONObject

class FinovaNotificationListener : NotificationListenerService() {

    companion object {
        private const val TAG = "FinovaListener"
        private const val PREFS = "finova_pending_notifications"
        private const val KEY_TRANSACTIONS = "transactions"
        private const val MAX_PENDING = 500

        @Volatile
        var notificationChannel: MethodChannel? = null

        private val allowedPackages = setOf(
            "com.google.android.apps.nbu.paisa.user",
            "com.google.android.apps.messaging",
            "com.truecaller"
        )

        private val amountRegex = Regex(
            """(?:₹\s*|rs\.?\s*|inr\s*)[0-9][0-9,]*(?:\.\d{1,2})?""",
            RegexOption.IGNORE_CASE
        )

        private val transactionRegex = Regex(
            """\b(credited|debit|debited|sent|received|transfer|transferred|paid|payment|withdrawn|deposit)\b""",
            RegexOption.IGNORE_CASE
        )
    }

    override fun onListenerConnected() {
        super.onListenerConnected()
        Log.d(TAG, "Notification listener connected")
    }

    override fun onNotificationPosted(sbn: StatusBarNotification) {
        if (sbn.packageName !in allowedPackages) return

        val extras = sbn.notification.extras ?: return

        val title = extras.getCharSequence("android.title")
            ?.toString()?.trim().orEmpty()

        val message = (
                extras.getCharSequence("android.bigText")
                    ?: extras.getCharSequence("android.text")
                )?.toString()?.trim().orEmpty()

        if (title.isBlank() && message.isBlank()) return

        val combinedText = "$title $message"

        if (!amountRegex.containsMatchIn(combinedText)) return
        if (!transactionRegex.containsMatchIn(combinedText)) return

        val prefs = getSharedPreferences(PREFS, Context.MODE_PRIVATE)

        // Save before notifying Flutter, so the event survives a closed UI.
        synchronized(this) {
            val existing = try {
                JSONArray(prefs.getString(KEY_TRANSACTIONS, "[]") ?: "[]")
            } catch (_: Exception) {
                JSONArray()
            }

            // Avoid duplicate delivery of the same notification.
            val notificationId =
                "${sbn.packageName}:${sbn.key}:${sbn.postTime}"

            var duplicate = false
            for (i in 0 until existing.length()) {
                if (existing.optJSONObject(i)
                        ?.optString("notificationId") == notificationId
                ) {
                    duplicate = true
                    break
                }
            }

            if (duplicate) return

            val item = JSONObject().apply {
                put("notificationId", notificationId)
                put("packageName", sbn.packageName)
                put("title", title)
                put("message", message)
                put("timestamp", sbn.postTime)
            }

            val updated = JSONArray()
            val start = maxOf(0, existing.length() - MAX_PENDING + 1)

            for (i in start until existing.length()) {
                updated.put(existing.getJSONObject(i))
            }

            updated.put(item)

            // commit() completes the local write before this callback returns.
            val saved = prefs.edit()
                .putString(KEY_TRANSACTIONS, updated.toString())
                .commit()

            if (!saved) {
                Log.e(TAG, "Could not save pending notification")
                return
            }
        }

        Log.d(TAG, "Possible transaction saved locally")

        notificationChannel?.invokeMethod(
            "onNotification",
            mapOf(
                "notificationId" to notificationIdFor(sbn),
                "packageName" to sbn.packageName,
                "title" to title,
                "message" to message,
                "timestamp" to sbn.postTime
            )
        )
    }

    private fun notificationIdFor(sbn: StatusBarNotification): String {
        return "${sbn.packageName}:${sbn.key}:${sbn.postTime}"
    }

    override fun onListenerDisconnected() {
        super.onListenerDisconnected()
        Log.d(TAG, "Notification listener disconnected")
        notificationChannel = null

        requestRebind(
            ComponentName(this, FinovaNotificationListener::class.java)
        )
    }
}
