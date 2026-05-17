package x.example.adora

import io.flutter.embedding.android.FlutterActivity
import androidx.annotation.NonNull
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.content.Context
import android.content.ContextWrapper
import android.content.Intent
import android.content.IntentFilter
import android.os.BatteryManager
import android.os.Build.VERSION
import android.os.Build.VERSION_CODES
import androidx.core.content.ContextCompat

class MainActivity : FlutterActivity() {
    private val CHANNEL = "samples.flutter.dev/location"

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "startBackgroundTracking" -> {
                    startLocationService()
                    result.success(true)
                }
                "stopBackgroundTracking" -> {
                    stopLocationService()
                    result.success(true)
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    override fun onPause() {
        super.onPause()
        startLocationService()
    }

    override fun onResume() {
        super.onResume()
        stopLocationService()
    }

    private fun startLocationService() {
        val hasFineLocation = ContextCompat.checkSelfPermission(this, android.Manifest.permission.ACCESS_FINE_LOCATION) == android.content.pm.PackageManager.PERMISSION_GRANTED
        val hasCoarseLocation = ContextCompat.checkSelfPermission(this, android.Manifest.permission.ACCESS_COARSE_LOCATION) == android.content.pm.PackageManager.PERMISSION_GRANTED
        
        if (!hasFineLocation && !hasCoarseLocation) {
            return
        }

        val serviceIntent = Intent(this, LocationTrackingService::class.java)
        if (VERSION.SDK_INT >= VERSION_CODES.O) {
            try {
                startForegroundService(serviceIntent)
            } catch (e: Exception) {
                e.printStackTrace()
            }
        } else {
            startService(serviceIntent)
        }
    }

    private fun stopLocationService() {
        val serviceIntent = Intent(this, LocationTrackingService::class.java)
        stopService(serviceIntent)
    }
}
