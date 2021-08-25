//
//  DeviceModel.swift
//  bluetoothChat
//
//  Created by Kasper Munch on 25/08/2021.
//

import Foundation
import CoreBluetooth

struct Device {
    let uuid: String
    let rssi: Int
    let name: String
    let peripheral: CBPeripheral
}
