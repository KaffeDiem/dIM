//
//  BluetoothManagerCentral.swift
//  bluetoothChat
//
//  Created by Kasper Munch on 23/08/2021.
//

import Foundation
import CoreBluetooth

// MARK: Bluetooth Central Manager
extension BluetoothManager {
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        // TODO: Handle other states as well.
        guard central.state == .poweredOn else {return}
        
        isReady = true
        // Start scanning for devices as soon as the state is on.
        centralManager.scanForPeripherals(withServices: [self.service.UUID], options: nil)
    }
    
    
    // Connect to peripherals when they are discovered.
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        // Print the name of discovered peripherals.
        if let name = advertisementData[CBAdvertisementDataLocalNameKey] {
            print("Peripheral discovered: \(name)")
        }
        // Connect to the newly discovered peripheral.
        centralManager.connect(peripheral, options: nil)
        // Save the connected peripheral in connectedPeripherals for later use.
        connectedPeripherals.append(peripheral)
    }
    
    
    // Check to make sure that the device we are connecting to is
    // broadcasting the correct characteristics.
    // Called once connection has been fully established.
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        // Set the delegate.
        peripheral.delegate = self
        // Discover services which the peripheral has to offer.
        peripheral.discoverServices([self.service.UUID])
    }
    
    
    // MARK: TODO - this function, whatever it does.
    // Whenever a peripheral disconnects we got to remove it from the
    // list of connected peripherals.
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        cleanUp(peripheral)
    }
    
    
    // Discover characteristics if the correct service has been found.
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {

        if let error = error {
            print("Unable to discover services: \(error.localizedDescription)")
            // TODO: Should probably clean up here.
            return
        }

        // Loop trough services in case there are multiple and
        // connect to our characteristic if it is found.
        peripheral.services?.forEach {service in
            peripheral.discoverCharacteristics([self.service.charUUID], for: service)
        }
    }
    
    
    // Once we discover the exptected characteristic we will be fully connected.
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        
        if let error = error {
            print("Unable to discover characteristics: \(error.localizedDescription)")
        }
        
        service.characteristics?.forEach { characteristic in
            guard characteristic.uuid == self.service.charUUID else { return }
            // Subsribe to all notifications made by the characteristic.
            peripheral.setNotifyValue(true, for: characteristic)
            // Save a reference of the characteristic to send back
            self.connectedCharateristics.append(characteristic)
        }
    }
    
    
    // Error handling if we are receiving the wrong notifications.
    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        // Only receive notifications from the characteristics that we expect.
        guard characteristic.uuid == self.service.charUUID else { return }
        
        if let error = error {
            print("Unable to get new notification: \(error.localizedDescription)")
        }
        
        // Cancel subs if they are not for us.
        if !characteristic.isNotifying {
            print("Cancel subsribtions from: \(peripheral.name ?? "Unknown")")
            centralManager.cancelPeripheralConnection(peripheral)
        }
    }
    
    
    // Receive messages from connected peripherals and decode it from JSON.
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        
        if let error = error {
            print("Error receiving data: \(error.localizedDescription)")
        }
        
        guard let data = characteristic.value else { return }
        
        let decoder = JSONDecoder()
        // Decode the message received from a connected peripheral and save it.
        do {
            let message = try decoder.decode(Message.self, from: data)
            
            print("\(message.author): \(message.text)")
            
            messages.append(message)
        } catch {
            print("Error decoding message: \(error)")
        }
    }
    
    // MARK: TODO - this function, whatever it does.
    func peripheral(_ peripheral: CBPeripheral, didModifyServices invalidatedServices: [CBService]) {
        cleanUp(peripheral)
    }
}
