//
//  BluetoothManagerPeripheral.swift
//  bluetoothChat
//
//  Created by Kasper Munch on 23/08/2021.
//

import Foundation
import CoreBluetooth

// MARK: Bluetooth Peripheral Manager
extension BluetoothManager {
    // Called whenever the status of the peripheral local device changes.
    // Once it is turned on we start advertising as to allow for discovery
    // by other devices.
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        // Check that we only advertise if the state is on.
        guard peripheral.state == .poweredOn else {
            return
        }
        
        let characteristic = CBMutableCharacteristic(
            type: service.charUUID,
            properties: [.write, .notify],
            value: nil,
            permissions: [.writeable, .readable]
        )
        self.characteristic = characteristic
        
        let service = CBMutableService(type: service.UUID, primary: true)
        service.characteristics = [characteristic]
        
        // Add the service to the peripheral manager and start advertising
        // the apps unique UUID together with the name of the phone.
        // This allows for centrals to discover the peripheral device.
        peripheralManager.add(service)
        peripheralManager.startAdvertising([
            CBAdvertisementDataServiceUUIDsKey: [self.service.UUID],
            //  Advertise either the set username or the default name of the device.
            CBAdvertisementDataLocalNameKey: UserDefaults.standard.string(forKey: "Username") ?? self.service.deviceName
        ])
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, central: CBCentral, didUnsubscribeFrom characteristic: CBCharacteristic) {
        print("Central unsubscribed from characteristic")
    }
    
    
}

