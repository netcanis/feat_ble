//
//  HiBleScanner.swift
//  feat_ble
//
//  Created by netcanis on 12/17/24.
//

import CoreBluetooth
import CoreLocation
import UIKit

/// Singleton class to handle BLE and Beacon scanning
public class HiBleScanner: NSObject, @unchecked Sendable {
    public static let shared = HiBleScanner()

    private var isScanning: Bool = false
    private var scanCallback: ((HiBleResult) -> Void)? // Callback function for scan results

    private var centralManager: CBCentralManager? // For BLE peripheral scanning
    private var locationManager: CLLocationManager? // For beacon scanning

    public var beaconUUID: UUID? = nil
    private var beacons: [CLBeacon] = [] // Sorted list of beacons by RSSI (descending)
    private var nearestBeaconMajor: Int = -1
    private var nearestBeaconMinor: Int = -1


    // MARK: - Initialization
    public override init() {
        super.init()

    }

    // MARK: - Start BLE and Beacon Scanning
    public func start(withCallback callback: @escaping (HiBleResult) -> Void) {
        guard !isScanning else {
            print("BLE scanning is already in progress.")
            return
        }
        scanCallback = callback
        isScanning = true

        beacons.removeAll()
        nearestBeaconMajor = -1
        nearestBeaconMinor = -1

        // Initialize CBCentralManager for BLE
        centralManager = CBCentralManager(delegate: self, queue: nil)

        // Initialize CLLocationManager for Beacon ranging
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.requestWhenInUseAuthorization()

        // Check permissions and start scanning
        checkPermissionsAndStartScanning()
    }

    // MARK: - Stop Scanning
    public func stop() {
        guard isScanning else { return }
        isScanning = false
        centralManager?.stopScan() // Stop BLE scanning

        if let beaconUUID = beaconUUID {
            // Stop ranging for beacons
            locationManager?.stopRangingBeacons(satisfying: CLBeaconIdentityConstraint(uuid: beaconUUID))
        }

        self.beacons.removeAll()
        self.nearestBeaconMajor = -1
        self.nearestBeaconMinor = -1
    }

    // MARK: - Check Permissions and Start Scanning
    private func checkPermissionsAndStartScanning() {
        if hasRequiredPermissions() {
            startBleScanning() // Start BLE scanning
            startBeaconScanning() // Start Beacon ranging
        }
    }

    /// Check if required permissions for BLE and Location are granted
    public func hasRequiredPermissions() -> Bool {
        let locationAuthorized = locationManager?.authorizationStatus == .authorizedWhenInUse || locationManager?.authorizationStatus == .authorizedAlways
        let bluetoothOn = centralManager?.state == .poweredOn
        return locationAuthorized && bluetoothOn
    }

    // MARK: - Start BLE Scanning
    private func startBleScanning() {
        print("Starting BLE scan...")
        centralManager?.scanForPeripherals(
            withServices: nil, // Discover all peripherals
            options: [CBCentralManagerScanOptionAllowDuplicatesKey: true] // Allow duplicate discoveries
        )
    }

    // MARK: - Start Beacon Scanning
    private func startBeaconScanning() {
        guard let beaconUUID = beaconUUID else { return }
        let beaconConstraint = CLBeaconIdentityConstraint(uuid: beaconUUID)
        locationManager?.startRangingBeacons(satisfying: beaconConstraint)
    }

    // MARK: - Helper Method for Alerts
    private func showAlert(title: String, message: String) {
        Task { @MainActor in
            if let topViewController = UIViewController.hiTopMostViewController() {
                let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                topViewController.present(alert, animated: true)
            }
        }
    }

    // MARK: - Check Beacon Scanning Status
    public func isBeaconScanningInProgress() -> Bool {
        guard let locationManager = locationManager else { return false }
        return !locationManager.rangedBeaconConstraints.isEmpty
    }
}

// MARK: - CBCentralManagerDelegate
extension HiBleScanner: CBCentralManagerDelegate {
    /// Callback for Bluetooth state changes
    public func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .poweredOn:
            print("Bluetooth is now powered on.")
            checkPermissionsAndStartScanning()
        case .poweredOff:
            print("Bluetooth is turned off.")
        case .unauthorized:
            print("Bluetooth permission is not granted.")
        case .unsupported:
            print("This device does not support Bluetooth.")
        default:
            print("Bluetooth state: \(central.state.rawValue)")
        }
    }

    /// Callback when a BLE peripheral is discovered
    public func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String: Any], rssi RSSI: NSNumber) {
        guard isScanning else { return }

        // Include nearest beacon information if available
        var major: Int = -1
        var minor: Int = -1
        if isBeaconScanningInProgress() && nearestBeaconMajor >= 0 && nearestBeaconMinor >= 0 {
            major = nearestBeaconMajor
            minor = nearestBeaconMinor
        }

        let bleResult = HiBleResult(
            rssi: RSSI.intValue,
            peripheral: peripheral,
            advertisementData: advertisementData,
            beaconUUID: beaconUUID,
            major: major,
            minor: minor
        )

        self.scanCallback?(bleResult)
    }
}

// MARK: - CLLocationManagerDelegate
extension HiBleScanner: CLLocationManagerDelegate {
    /// Callback for ranging beacons
    public func locationManager(_ manager: CLLocationManager, didRange beacons: [CLBeacon], satisfying beaconConstraint: CLBeaconIdentityConstraint) {
        guard !beacons.isEmpty else { return }

        // Sort beacons by signal strength (RSSI, descending order)
        let sortedBeacons = beacons.sorted { $0.rssi > $1.rssi }
        self.beacons = sortedBeacons
        self.nearestBeaconMajor = sortedBeacons.first?.major.intValue ?? -1
        self.nearestBeaconMinor = sortedBeacons.first?.minor.intValue ?? -1

        for beacon in sortedBeacons {
            let beaconResult = HiBleResult(
                rssi: beacon.rssi,
                peripheral: nil,
                advertisementData: nil,
                beaconUUID: beacon.uuid,
                major: beacon.major.intValue,
                minor: beacon.minor.intValue
            )

            Task { @MainActor [weak self] in
                guard let self = self, self.isScanning else { return }
                self.scanCallback?(beaconResult)
            }
        }
    }

    /// Callback for location authorization status changes
    public func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .notDetermined:
            print("Location permission: Not determined")
        case .restricted:
            showAlert(title: "Location Restricted", message: "Access to location services is restricted.")
        case .denied:
            showAlert(title: "Location Permission Needed", message: "Location permission is required for beacon scanning.")
        case .authorizedWhenInUse, .authorizedAlways:
            checkPermissionsAndStartScanning()
        @unknown default:
            print("Location permission: Unknown state")
        }
    }
}



// MARK: - Top ViewController Finder
extension UIViewController {
    /// Returns the top-most ViewController in the app
    static func hiTopMostViewController() -> UIViewController? {
        guard let keyWindow = UIApplication.shared
            .connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .flatMap({ $0.windows })
            .first(where: { $0.isKeyWindow }),
              let rootViewController = keyWindow.rootViewController else {
            return nil
        }
        return hiGetTopViewController(from: rootViewController)
    }

    private static func hiGetTopViewController(from viewController: UIViewController) -> UIViewController {
        if let presentedViewController = viewController.presentedViewController {
            return hiGetTopViewController(from: presentedViewController)
        }
        if let navigationController = viewController as? UINavigationController,
           let visibleViewController = navigationController.visibleViewController {
            return hiGetTopViewController(from: visibleViewController)
        }
        if let tabBarController = viewController as? UITabBarController,
           let selectedViewController = tabBarController.selectedViewController {
            return hiGetTopViewController(from: selectedViewController)
        }
        return viewController
    }
}
