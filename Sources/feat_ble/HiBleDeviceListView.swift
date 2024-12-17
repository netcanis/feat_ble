//
//  HiBleDeviceListView.swift
//  feat_ble
//
//  Created by netcanis on 11/19/24.
//

import SwiftUI
import CoreBluetooth

/// A SwiftUI view that displays a list of BLE devices.
/// - It scans for nearby BLE devices and displays their details in a list.
public struct HiBleDeviceListView: View {
    /// A state property to store scanned BLE devices.
    @State private var devices: [HiBleResult] = []

    /// The dismiss environment to close the current view.
    @Environment(\.dismiss) private var dismiss

    /// Initializes the view with an optional beacon UUID.
    /// - Parameter uuidString: A string representation of the UUID for beacon scanning.
    public init(_ uuidString: String = "") {
        HiBleScanner.shared.beaconUUID = UUID(uuidString: uuidString)
    }

    public var body: some View {
        List(devices, id: \.self.peripheral?.identifier) { device in
            VStack(alignment: .leading, spacing: 8) {
                // Device Name
                Text("Device Name: \(device.peripheral?.name ?? "Unknown")")
                    .font(.headline)

                // RSSI (Signal Strength)
                Text("RSSI: \(device.rssi)")
                    .font(.subheadline)
                    .foregroundColor(.gray)

                // UUID of the Peripheral
                Text("UUID: \(device.peripheral?.identifier.uuidString ?? "N/A")")
                    .font(.caption)
                    .foregroundColor(.secondary)

                // Advertisement Data
                if let advertisementData = device.advertisementData {
                    Text("Advertisement Data: \(advertisementData.description)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                // Beacon Major/Minor Values (if applicable)
                if device.major != -1 && device.minor != -1 {
                    Text("Beacon Major: \(device.major)")
                        .font(.caption)
                        .foregroundColor(.blue)
                    Text("Beacon Minor: \(device.minor)")
                        .font(.caption)
                        .foregroundColor(.blue)
                }
            }
            .padding(4)
        }
        .navigationTitle("BLE Devices")
        .navigationBarTitleDisplayMode(.inline) // Centered navigation title
        .onAppear(perform: startBleScan)        // Start scanning when the view appears
        .onDisappear(perform: stopBleScan)      // Stop scanning when the view disappears
    }

    /// Starts scanning for BLE devices.
    private func startBleScan() {
        HiBleScanner.shared.start { result in
            DispatchQueue.main.async {
                // Check if the device already exists in the list
                if let index = devices.firstIndex(where: { $0.peripheral?.identifier == result.peripheral?.identifier }) {
                    devices[index] = result // Update the existing device information
                } else {
                    devices.append(result) // Append the new device to the list
                }
            }
        }
    }

    /// Stops the BLE scanning process.
    private func stopBleScan() {
        HiBleScanner.shared.stop()
        print("BLE scan has been stopped.")
    }
}

#Preview {
    HiBleDeviceListView()
}
