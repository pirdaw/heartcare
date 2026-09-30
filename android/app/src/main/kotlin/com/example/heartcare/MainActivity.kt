package com.example.heartcare

import android.content.Intent
import android.provider.AlarmClock
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.example.heartcare/alarm"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
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
                            // Coba buka aplikasi jam / alarm langsung
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
    }
}
