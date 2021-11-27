//
//  BluetoothManagerPeripheral.swift
//  bluetoothChat
//
//  Created by Kasper Munch on 23/08/2021.
//

import Foundation
import CoreBluetooth

// MARK: Bluetooth Peripheral Manager
extension ChatBrain {
    // Called whenever the status of the peripheral local device changes.
    // Once it is turned on we start advertising as to allow for discovery
    // by other devices.
    
    func startAdvertising(peripheralManager: CBPeripheralManager) {
        peripheralManager.startAdvertising([
            CBAdvertisementDataServiceUUIDsKey: [Service().UUID],
            //  Advertise either the set username or the default name of the device.
            CBAdvertisementDataLocalNameKey: UserDefaults.standard.string(forKey: "Username") ?? "Unknown"
        ])
    }
    
    
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        // Check that we only advertise if the state is on.
        guard peripheral.state == .poweredOn else {
            return
        }
        
        let characteristic = CBMutableCharacteristic(
            type: Service().charUUID,
            properties: [.write, .notify],
            value: nil,
            permissions: [.writeable, .readable]
        )
        self.characteristic = characteristic
        
        let service = CBMutableService(type: Service().UUID, primary: true)
        service.characteristics = [characteristic]
        
        // Add the service to the peripheral manager and start advertising
        // the apps unique UUID together with the name of the phone.
        // This allows for centrals to discover the peripheral device.
        peripheralManager.add(service)
        startAdvertising(peripheralManager: peripheralManager)
    }
    
    
    /*
     Called when a new central subscribes to our peripheral manager.
     */
    func peripheralManager(_ peripheral: CBPeripheralManager, central: CBCentral, didSubscribeTo characteristic: CBCharacteristic) {
        
        /*
         Make sure that the central manager subscribed to the correct peripheral.
         */
        guard characteristic == self.characteristic else {
            print("Error: \(central.identifier.uuidString) subscribed to wrong charateristic")
            return
        }
        
        print("A new central subscribed")
        
        /*
         Send the messages in the message queue to newly connected device.
         */
        if enableMessageQueue { messageQueueNewConnection(central) }
        
        if useDSRAlgorithm {
            seenCBCentral.append(central)
        }
    }
    
    
    func peripheralManager(_ peripheral: CBPeripheralManager, central: CBCentral, didUnsubscribeFrom characteristic: CBCharacteristic) {
        
        print("Central unsubscribed from characteristic: Nothing is done yet")
    }
}

