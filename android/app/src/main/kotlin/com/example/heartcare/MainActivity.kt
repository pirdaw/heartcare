package com.example.heartcare

import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.os.Build
import android.provider.AlarmClock
import androidx.core.app.NotificationCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val ALARM_CHANNEL = "com.example.heartcare/alarm"
    private val NOTIF_CHANNEL = "com.example.heartcare/notifications"
    private val SYSTEM_NOTIF_CHANNEL_ID = "heartcare_alerts_v2"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // 1. Channel Alarm Obat
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, ALARM_CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "setAlarm" -> {
                    val hour = call.argument<Int>("hour") ?: 0
                    val minute = call.argument<Int>("minute") ?: 0
                    val title = call.argument<String>("title") ?: "Pengingat Minum Obat"
                    val skipUi = call.argument<Boolean>("skipUi") ?: false

                    try {
                        val intent = Intent(AlarmClock.ACTION_SET_ALARM).apply {
                            putExtra(AlarmClock.EXTRA_HOUR, hour)
                            putExtra(AlarmClock.EXTRA_MINUTES, minute)
                            putExtra(AlarmClock.EXTRA_MESSAGE, title)
                            putExtra(AlarmClock.EXTRA_SKIP_UI, skipUi)
                            putExtra(AlarmClock.EXTRA_VIBRATE, true)
                            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                        }

                        if (intent.resolveActivity(packageManager) != null) {
                            startActivity(intent)
                            result.success(true)
                        } else {
                            val openClockIntent = Intent(AlarmClock.ACTION_SHOW_ALARMS).apply {
                                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                            }
                            if (openClockIntent.resolveActivity(packageManager) != null) {
                                startActivity(openClockIntent)
                                result.success(true)
                            } else {
                                result.error("UNAVAILABLE", "Aplikasi jam/alarm tidak tersedia di perangkat", null)
                            }
                        }
                    } catch (e: Exception) {
                        result.error("ALARM_ERROR", e.localizedMessage, null)
                    }
                }
                "openAlarms" -> {
                    try {
                        val intent = Intent(AlarmClock.ACTION_SHOW_ALARMS).apply {
                            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                        }
                        if (intent.resolveActivity(packageManager) != null) {
                            startActivity(intent)
                            result.success(true)
                        } else {
                            result.error("UNAVAILABLE", "Aplikasi jam/alarm tidak tersedia di perangkat", null)
                        }
                    } catch (e: Exception) {
                        result.error("OPEN_ERROR", e.localizedMessage, null)
                    }
                }
                else -> {
                    result.notImplemented()
                }
            }
        }

        // 2. Channel Notifikasi Sistem Android (Bilah Status & Heads-Up Banner saat app ditutup/di-background)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, NOTIF_CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "showSystemNotification" -> {
                    val id = call.argument<Int>("id") ?: System.currentTimeMillis().toInt()
                    val title = call.argument<String>("title") ?: "HeartCare"
                    val message = call.argument<String>("message") ?: ""
                    val isCall = call.argument<Boolean>("isCall") ?: false

                    try {
                        showSystemNotification(id, title, message, isCall)
                        result.success(true)
                    } catch (e: Exception) {
                        result.error("NOTIF_ERROR", e.localizedMessage, null)
                    }
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    private fun showSystemNotification(id: Int, title: String, message: String, isCall: Boolean) {
        val notificationManager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                SYSTEM_NOTIF_CHANNEL_ID,
                "HeartCare Notifikasi & Panggilan",
                NotificationManager.IMPORTANCE_HIGH
            ).apply {
                description = "Notifikasi chat, panggilan video, konsultasi, dan pengingat HeartCare"
                enableVibration(true)
                vibrationPattern = longArrayOf(0, 500, 200, 500)
                setShowBadge(true)
                lockscreenVisibility = NotificationCompat.VISIBILITY_PUBLIC
            }
            notificationManager.createNotificationChannel(channel)
        }

        val launchIntent = packageManager.getLaunchIntentForPackage(packageName)?.apply {
            flags = Intent.FLAG_ACTIVITY_SINGLE_TOP or Intent.FLAG_ACTIVITY_CLEAR_TOP
        }
        val pendingIntent = PendingIntent.getActivity(
            this,
            id,
            launchIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or (if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) PendingIntent.FLAG_IMMUTABLE else 0)
        )

        val builder = NotificationCompat.Builder(this, SYSTEM_NOTIF_CHANNEL_ID)
            .setSmallIcon(R.mipmap.ic_launcher)
            .setContentTitle(title)
            .setContentText(message)
            .setStyle(NotificationCompat.BigTextStyle().bigText(message))
            .setPriority(NotificationCompat.PRIORITY_MAX)
            .setCategory(if (isCall) NotificationCompat.CATEGORY_CALL else NotificationCompat.CATEGORY_MESSAGE)
            .setVisibility(NotificationCompat.VISIBILITY_PUBLIC)
            .setAutoCancel(true)
            .setContentIntent(pendingIntent)
            .setDefaults(NotificationCompat.DEFAULT_ALL)
            .setVibrate(longArrayOf(0, 500, 200, 500))

        if (isCall) {
            builder.setFullScreenIntent(pendingIntent, true)
        }

        notificationManager.notify(id, builder.build())
    }
}
