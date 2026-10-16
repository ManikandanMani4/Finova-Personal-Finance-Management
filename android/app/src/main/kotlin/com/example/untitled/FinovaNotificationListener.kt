
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

        // Matches ₹1, ₹1,500.00, Rs. 250, and INR 100.
        private val amountRegex = Regex(
            """(?:₹\s*|rs\.?\s*|inr\s*)[0-9][0-9,]*(?:\.\d{1,2})?""",
            RegexOption.IGNORE_CASE
        )

        private val transactionRegex = Regex(
            """\b(credited|debit|debited|sent|received|transfer|transferred|paid|payment|withdrawn|deposit|deposited)\b""",
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
            ?.toString()
            ?.trim()
            .orEmpty()

        val message = (
                extras.getCharSequence("android.bigText")
                    ?: extras.getCharSequence("android.text")
                )
            ?.toString()
            ?.trim()
            .orEmpty()

        if (title.isBlank() && message.isBlank()) return

        val combinedText = "$title $message"

        if (!amountRegex.containsMatchIn(combinedText)) return
        if (!transactionRegex.containsMatchIn(combinedText)) return

        val notificationId = notificationIdFor(sbn)
        val prefs = getSharedPreferences(PREFS, Context.MODE_PRIVATE)

        synchronized(this) {
            val existing = try {
                JSONArray(
                    prefs.getString(KEY_TRANSACTIONS, "[]") ?: "[]"
                )
            } catch (e: Exception) {
                Log.e(TAG, "Could not read pending notifications", e)
                JSONArray()
            }

            // Avoid storing the same notification twice.
            for (i in 0 until existing.length()) {
                if (
                    existing.optJSONObject(i)
                        ?.optString("notificationId") == notificationId
                ) {
                    Log.d(TAG, "Duplicate notification ignored")
                    return
                }
            }

            val item = JSONObject().apply {
                put("notificationId", notificationId)
                put("packageName", sbn.packageName)
                put("title", title)
                put("message", message)
                put("timestamp", sbn.postTime)
            }

            // Keep the newest MAX_PENDING notifications.
            val updated = JSONArray()
            val start = maxOf(0, existing.length() - MAX_PENDING + 1)

            for (i in start until existing.length()) {
                val oldItem = existing.optJSONObject(i) ?: continue
                updated.put(oldItem)
            }

            updated.put(item)

            // Persist locally before notifying Flutter.
            val saved = prefs.edit()
                .putString(KEY_TRANSACTIONS, updated.toString())
                .commit()

            if (!saved) {
                Log.e(TAG, "Could not save pending notification")
                return
            }
        }

        Log.d(TAG, "Possible transaction saved locally: $notificationId")

        // Flutter may not be running. The local copy remains available
        // for a later sync when the app opens.
        try {
            notificationChannel?.invokeMethod(
                "onNotification",
                mapOf(
                    "notificationId" to notificationId,
                    "packageName" to sbn.packageName,
                    "title" to title,
                    "message" to message,
                    "timestamp" to sbn.postTime
                )
            )
        } catch (e: Exception) {
            Log.e(TAG, "Could not notify Flutter", e)
        }
    }

    private fun notificationIdFor(sbn: StatusBarNotification): String {
        return "${sbn.packageName}:${sbn.key}:${sbn.postTime}"
    }

    override fun onListenerDisconnected() {
        super.onListenerDisconnected()
        Log.d(TAG, "Notification listener disconnected")

        notificationChannel = null

        requestRebind(
            ComponentName(
                this,
                FinovaNotificationListener::class.java
            )
        )
    }
}
