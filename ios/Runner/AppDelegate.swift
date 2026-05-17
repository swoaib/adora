import Flutter
import UIKit
import CoreLocation

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate, CLLocationManagerDelegate {
    
    var locationManager: CLLocationManager?
    
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.allowsBackgroundLocationUpdates = true
        locationManager?.pausesLocationUpdatesAutomatically = false
        
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
        GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
        
        let locationChannel = FlutterMethodChannel(
            name: "samples.flutter.dev/location",
            binaryMessenger: engineBridge.applicationRegistrar.messenger()
        )
        
        locationChannel.setMethodCallHandler({
            [weak self] (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
            if call.method == "startBackgroundTracking" {
                self?.startLocationTracking()
                result(true)
            } else if call.method == "stopBackgroundTracking" {
                self?.stopLocationTracking()
                result(true)
            } else {
                result(FlutterMethodNotImplemented)
            }
        })
    }

    override func applicationDidEnterBackground(_ application: UIApplication) {
        startLocationTracking()
    }

    override func applicationWillEnterForeground(_ application: UIApplication) {
        stopLocationTracking()
    }

    private func startLocationTracking() {
        locationManager?.requestAlwaysAuthorization()
        locationManager?.startMonitoringSignificantLocationChanges()
    }

    private func stopLocationTracking() {
        locationManager?.stopMonitoringSignificantLocationChanges()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        saveLocation(location: location)
    }
    
    private func saveLocation(location: CLLocation) {
        let defaults = UserDefaults.standard
        let key = "flutter.native_location_history"
        
        var historyStr = defaults.string(forKey: key) ?? "[]"
        if historyStr.isEmpty {
            historyStr = "[]"
        }
        
        do {
            guard let data = historyStr.data(using: .utf8) else { return }
            var array = try JSONSerialization.jsonObject(with: data, options: []) as? [[String: Double]] ?? []
            
            array.append([
                "lat": location.coordinate.latitude,
                "lng": location.coordinate.longitude
            ])
            
            let newData = try JSONSerialization.data(withJSONObject: array, options: [])
            if let newString = String(data: newData, encoding: .utf8) {
                defaults.set(newString, forKey: key)
            }
        } catch {
            print("Error saving location: \(error)")
        }
    }
}
