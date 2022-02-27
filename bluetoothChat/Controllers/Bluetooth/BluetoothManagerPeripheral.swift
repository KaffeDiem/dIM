//
//  BluetoothManagerPeripheral.swift
//  bluetoothChat
//
//  Created by Kasper Munch on 23/08/2021.
//

import Foundation
import CoreBluetooth

extension ChatHandler {
    
    // MARK: PeripheralManager callback functions. Handles the client side of Bluetooth.

    /// Start advertisting that we are here to nearby Bluetooth central managers.
    /// This is a callback function and called automatically.
    ///
    /// We also set our devices name here.
    /// - Note: The devices name is not avaiable when the app is backgrounded due to API restrictions.
    /// - Parameter peripheralManager: The peripheral manager to start advertising for.
    func startAdvertising(peripheralManager: CBPeripheralManager) {
        peripheralManager.startAdvertising([
            CBAdvertisementDataServiceUUIDsKey: [Session.UUID],
            //  Advertise either the set username or the default name of the device.
            CBAdvertisementDataLocalNameKey: UserDefaults.standard.string(forKey: "Username") ?? "Unknown"
        ])
    }
    
    
    /// Callback function which is called when the peripheral manager updates its state.
    ///
    /// This could be due to Bluetooth being turned off by the user.
    /// In the future we may notify the user that the wont be able to receive messages
    /// when they turned off Bluetooth.
    ///
    /// When the peripheral updates its state to `poweredOn` we add the Bluetooth functionality
    /// to it as a characteristic.
    /// - Parameter peripheral: The peripheral which updates its state.
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        // Check that we only advertise if the state is on.
        guard peripheral.state == .poweredOn else {
            return
        }
        
        let characteristic = CBMutableCharacteristic(
            type: Session.characteristicsUUID,
            properties: [.write, .notify],
            value: nil,
            permissions: [.writeable, .readable]
        )
        self.characteristic = characteristic
        
        let service = CBMutableService(type: Session.UUID, primary: true)
        service.characteristics = [characteristic]
        
        // Add the service to the peripheral manager and start advertising
        // the apps unique UUID together with the name of the phone.
        // This allows for centrals to discover the peripheral device.
        peripheralManager.add(service)
        startAdvertising(peripheralManager: peripheralManager)
    }
    
    
    /// Called when a new central subscribes to our peripheral manager.
    /// This means that we have someone to send messages to other than ourselves.
    /// - Parameters:
    ///   - peripheral: The peripheral which has a new subscription.
    ///   - central: The central which subscribes to the peripheral.
    ///   - characteristic: The characteristic which it subscribes to.
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
    
    
    /// Callback function activated when a central unsubscribes from us.
    ///
    /// Nothing is done at the minute but error handling should be done in the
    /// future.
    /// - Parameters:
    ///   - peripheral: The peripheral which is unsubscribed from.
    ///   - central: The central which unsubscribed from us.
    ///   - characteristic: The characteristic (functionality) which the central unsubscribes from.
    func peripheralManager(_ peripheral: CBPeripheralManager, central: CBCentral, didUnsubscribeFrom characteristic: CBCharacteristic) {
        
        print("Central unsubscribed from characteristic: Nothing is done yet")
    }
}

