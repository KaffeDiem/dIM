//
//  DeviceModel.swift
//  bluetoothChat
//
//  Created by Kasper Munch on 25/08/2021.
//

import Foundation
import CoreBluetooth

/// A device is created when a new Bluetooth connection is made.
///
/// It is used to keep track of connected devices and keep a reference in memory
/// of newly connected devices since connections are dropped otherwise.
struct Device {
    /// The unique identifier of a new Bluetooth connection.
    let uuid: String
    /// RSSI is the signal strength to a device. The closer to 0 the better.
    var rssi: Int
    /// The name of a device if it is broadcasting one.
    let name: String
    /// The actual reference to the device as a `CBPeripheral`.
    let peripheral: CBPeripheral
    
    /// Updated the RSSI when a device has its connection refreshed.
    /// - Parameter RSSI: The RSSI as an Int. The closer to 0 the better the connection.
    mutating func updateRSSI(RSSI: Int) {
        self.rssi = RSSI
    }
}
