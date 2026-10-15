
package com.example.untitled

import android.content.Context
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import org.json.JSONArray

class MainActivity : FlutterActivity() {

    companion object {
        private const val CHANNEL = "com.finova/notifications"
        private const val PREFS = "finova_pending_notifications"
        private const val KEY_TRANSACTIONS = "transactions"
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        val channel = MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL
        )

        FinovaNotificationListener.notificationChannel = channel

        channel.setMethodCallHandler { call, result ->
            when (call.method) {
                "getPendingTransactions" -> {
                    val prefs = getSharedPreferences(
                        PREFS,
                        Context.MODE_PRIVATE
                    )

                    val json = prefs.getString(KEY_TRANSACTIONS, "[]") ?: "[]"

                    result.success(json)
                }

                "clearPendingTransactions" -> {
                    val prefs = getSharedPreferences(
                        PREFS,
                        Context.MODE_PRIVATE
                    )

                    prefs.edit().putString(KEY_TRANSACTIONS, "[]").apply()
                    result.success(true)
                }

                else -> result.notImplemented()
            }
        }
    }

    override fun onDestroy() {
        FinovaNotificationListener.notificationChannel = null
        super.onDestroy()
    }
}
