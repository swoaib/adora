package x.example.adora

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.Service
import android.content.Context
import android.content.Intent
import android.location.Location
import android.location.LocationListener
import android.location.LocationManager
import android.os.Build
import android.os.IBinder
import android.os.Bundle
import org.json.JSONArray
import org.json.JSONObject

class LocationTrackingService : Service() {

    private lateinit var locationManager: LocationManager
    private val CHANNEL_ID = "LocationServiceChannel"

    override fun onCreate() {
        super.onCreate()
        locationManager = getSystemService(Context.LOCATION_SERVICE) as LocationManager
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        createNotificationChannel()
        val notification: Notification = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            Notification.Builder(this, CHANNEL_ID)
                .setContentTitle("Adora")
                .setContentText("Tracking Location")
                .setSmallIcon(android.R.drawable.ic_menu_mylocation)
                .build()
        } else {
            @Suppress("DEPRECATION")
            Notification.Builder(this)
                .setContentTitle("Adora")
                .setContentText("Tracking Location")
                .setSmallIcon(android.R.drawable.ic_menu_mylocation)
                .build()
        }

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            startForeground(1, notification, android.content.pm.ServiceInfo.FOREGROUND_SERVICE_TYPE_LOCATION)
        } else {
            startForeground(1, notification)
        }

        try {
            locationManager.requestLocationUpdates(
                LocationManager.GPS_PROVIDER,
                15 * 60 * 1000L, // 15 minutes
                100f, // 100 meters
                locationListener
            )
            locationManager.requestLocationUpdates(
                LocationManager.NETWORK_PROVIDER,
                15 * 60 * 1000L,
                100f,
                locationListener
            )
        } catch (e: SecurityException) {
            e.printStackTrace()
        }

        return START_STICKY
    }

    override fun onDestroy() {
        super.onDestroy()
        locationManager.removeUpdates(locationListener)
    }

    override fun onBind(intent: Intent?): IBinder? {
        return null
    }

    override fun onTaskRemoved(rootIntent: Intent?) {
        super.onTaskRemoved(rootIntent)
        
        // When the user swipes the app away, restart the service to ensure background tracking continues
        val restartServiceIntent = Intent(applicationContext, this.javaClass)
        restartServiceIntent.setPackage(packageName)
        
        val restartServicePendingIntent = android.app.PendingIntent.getService(
            applicationContext,
            1,
            restartServiceIntent,
            android.app.PendingIntent.FLAG_ONE_SHOT or android.app.PendingIntent.FLAG_IMMUTABLE
        )
        
        val alarmService = getSystemService(Context.ALARM_SERVICE) as android.app.AlarmManager
        alarmService.set(
            android.app.AlarmManager.ELAPSED_REALTIME,
            android.os.SystemClock.elapsedRealtime() + 1000,
            restartServicePendingIntent
        )
    }

    private val locationListener: LocationListener = object : LocationListener {
        override fun onLocationChanged(location: Location) {
            saveLocation(location)
        }
        override fun onStatusChanged(provider: String?, status: Int, extras: Bundle?) {}
        override fun onProviderEnabled(provider: String) {}
        override fun onProviderDisabled(provider: String) {}
    }

    private fun saveLocation(location: Location) {
        val prefs = getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
        val historyJsonStr = prefs.getString("flutter.native_location_history", "[]")
        
        try {
            val jsonArray = JSONArray(historyJsonStr)
            val locObj = JSONObject()
            locObj.put("lat", location.latitude)
            locObj.put("lng", location.longitude)
            jsonArray.put(locObj)
            
            prefs.edit().putString("flutter.native_location_history", jsonArray.toString()).apply()
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val serviceChannel = NotificationChannel(
                CHANNEL_ID,
                "Location Service Channel",
                NotificationManager.IMPORTANCE_LOW
            )
            val manager = getSystemService(NotificationManager::class.java)
            manager.createNotificationChannel(serviceChannel)
        }
    }
}
