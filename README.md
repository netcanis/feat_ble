# **feat_ble**

A **Swift Package** for BLE (Bluetooth Low Energy) and iBeacon scanning on iOS.

---

## **Overview**

`feat_ble` is a lightweight Swift package that enables:
- Scanning Bluetooth Low Energy (BLE) devices.
- Detecting and ranging iBeacon devices.
- Fetching details such as **RSSI**, **Advertisement Data**, and **UUID**.

This module is compatible with **iOS 16 and above** and designed for seamless integration via **Swift Package Manager (SPM)**.

---

## **Features**

- ✅ **BLE Scanning**: Discover BLE devices and retrieve device data such as name, RSSI, and advertisement information.
- ✅ **iBeacon Support**: Detect iBeacons and extract **Major** and **Minor** values.
- ✅ **Modular Integration**: Lightweight and easy-to-use Swift Package with modular architecture.

---

## **Requirements**

| Requirement     | Minimum Version         |
|------------------|-------------------------|
| **iOS**         | 16.0                    |
| **Swift**       | 5.7                     |
| **Xcode**       | 14.0                    |

---

## **Installation**

### **Swift Package Manager (SPM)**

1. Open your project in **Xcode**.
2. Navigate to **File > Add Packages...**.
3. Enter the repository URL:  https://github.com/your-username/feat_ble.git
4. Select the version and integrate the package into your project.

---

## **Usage**

### **1. Start BLE Scanning**

To start scanning for BLE devices or iBeacons:

```swift
import feat_ble

HiBleScanner.shared.start { result in
 print("Device Found:")
 print("Name: \(result.peripheral?.name ?? "Unknown")")
 print("RSSI: \(result.rssi)")
 print("UUID: \(result.peripheral?.identifier.uuidString ?? "")")
 print("Major: \(result.major), Minor: \(result.minor)")
}
```

### **2. Stop BLE Scanning**
Stop scanning when it's no longer needed:

```swift
HiBleScanner.shared.stop()
```

### **3. iBeacon Scanning**
Set a desired iBeacon UUID before starting the scan:

```swift
HiBleScanner.shared.beaconUUID = UUID(uuidString: "XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX")
HiBleScanner.shared.start { result in
    print("Beacon Found: Major: \(result.major), Minor: \(result.minor)")
}
```

---

## **HiBleResult**

The scan results are provided in the HiBleResult class. Here are its properties:

| Property          | Type           | Description                         |
|-------------------|----------------|-------------------------------------|
| rssi              | Int            | Signal strength (RSSI).             |
| peripheral        | CBPeripheral?  | The discovered BLE peripheral.      |
| advertisementData | [String: Any]? | Advertisement data from the device. |
| beaconUUID        | UUID?          | UUID for the detected iBeacon.      |
| major             | Int            | iBeacon's major value.              |
| minor             | Int            | iBeacon's minor value.              |
| error             | String         | Error message, if any.              |

---

## **Permissions**

Add the following keys to your Info.plist file to request permissions:

```swift
<key>NSBluetoothAlwaysUsageDescription</key>
<string>We use Bluetooth to discover nearby devices.</string>

<key>NSLocationWhenInUseUsageDescription</key>
<string>Location permission is required to scan for iBeacons.</string>
```

---

## **Example UI**

To display the scanned BLE devices in a SwiftUI view, you can use the following code:

```swift
import SwiftUI
import feat_ble

public struct HiBleDeviceListView: View {
    @State private var devices: [HiBleResult] = []

    public var body: some View {
        List(devices, id: \.peripheral?.identifier) { device in
            VStack(alignment: .leading) {
                Text("Device Name: \(device.peripheral?.name ?? "Unknown")")
                Text("RSSI: \(device.rssi)")
                Text("UUID: \(device.peripheral?.identifier.uuidString ?? "")")
                if device.major != -1 && device.minor != -1 {
                    Text("Beacon Major: \(device.major)")
                    Text("Beacon Minor: \(device.minor)")
                }
            }
        }
        .navigationTitle("BLE Devices")
        .onAppear(perform: startBleScan)
        .onDisappear(perform: stopBleScan)
    }

    private func startBleScan() {
        HiBleScanner.shared.start { result in
            if let index = devices.firstIndex(where: { $0.peripheral?.identifier == result.peripheral?.identifier }) {
                devices[index] = result
            } else {
                devices.append(result)
            }
        }
    }

    private func stopBleScan() {
        HiBleScanner.shared.stop()
    }
}
```

---

## **License**

feat_ble is available under the MIT License. See the LICENSE file for details.

---

## **Contributing**

Contributions are welcome! To contribute:

1. Fork this repository.
2. Create a feature branch:
```
git checkout -b feature/your-feature
```
3. Commit your changes:
```
git commit -m "Add feature: description"
```
4. Push to the branch:
```
git push origin feature/your-feature
```
5. Submit a Pull Request.

---

## **Author**

### **netcanis**
GitHub: https://github.com/netcanis

---
