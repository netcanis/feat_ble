//
//  HiBleResult.swift
//  feat_ble
//
//  Created by netcanis on 12/17/24.
//

import CoreBluetooth

/// Represents the result of a BLE scan or Beacon detection.
public class HiBleResult {
    /// Signal strength (RSSI) in dBm.
    public var rssi: Int

    /// The discovered BLE device as a `CBPeripheral` object.
    public var peripheral: CBPeripheral?

    /// Advertisement data provided during BLE discovery.
    public var advertisementData: [String: Any]?

    /// The UUID of the detected beacon.
    public var beaconUUID: UUID?

    /// The Major value of the beacon.
    public var major: Int

    /// The Minor value of the beacon.
    public var minor: Int

    /// Error description, if any.
    public let error: String

    /// Initializes a `HiBleResult` object with BLE and beacon scan information.
    /// - Parameters:
    ///   - rssi: Signal strength (RSSI) of the detected device or beacon.
    ///   - peripheral: The BLE device (`CBPeripheral`), optional.
    ///   - advertisementData: Advertisement data in key-value format.
    ///   - beaconUUID: The UUID of the beacon, optional.
    ///   - major: The Major value of the beacon (default: `-1` if not applicable).
    ///   - minor: The Minor value of the beacon (default: `-1` if not applicable).
    ///   - error: An error description if there is any issue (default: empty string).
    public init(
        rssi: Int,
        peripheral: CBPeripheral?,
        advertisementData: [String: Any]?,
        beaconUUID: UUID?,
        major: Int = -1,
        minor: Int = -1,
        error: String = ""
    ) {
        self.rssi = rssi
        self.peripheral = peripheral
        self.advertisementData = advertisementData
        self.beaconUUID = beaconUUID
        self.major = major
        self.minor = minor
        self.error = error
    }
}
