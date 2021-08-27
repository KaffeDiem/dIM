//
//  BluetoothManagerCentral.swift
//  bluetoothChat
//
//  Created by Kasper Munch on 23/08/2021.
//

import Foundation
import CoreBluetooth

// MARK: Bluetooth Central Manager
extension ChatBrain {
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        // MARK: TODO: Handle other states as well.
        guard central.state == .poweredOn else {return}
        
        /*
         Should handle states such that the user is prompted if Bluetooth is turned off,
         the user has not allowed bluetooth access for the app and so on ...
         
             switch central.state {
                 case .poweredOn:
                     startScan()
                 case .poweredOff:
                     // Alert user to turn on Bluetooth
                 case .resetting:
                     // Wait for next state update and consider logging interruption of Bluetooth service
                 case .unauthorized:
                     // Alert user to enable Bluetooth permission in app Settings
                 case .unsupported:
                     // Alert user their device does not support Bluetooth and app will not work as expected
                 case .unknown:
                    // Wait for next state update
              }
         */
        
        // Scan for peripherals with our unique uuid.
        centralManager.scanForPeripherals(withServices: [Service().UUID], options: nil)
    }
    
    
    /*
     Connect to peripheral devices which broadcast the chosen UUID
     for the app and add it to discovered devices.
     Callback function activated whenever a peripheral is discovered.
     */
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        
        print(peripheral.identifier.uuidString)
        
        if let safeName = advertisementData[CBAdvertisementDataLocalNameKey] as? String {
            print("Peripheral discovered: \(safeName)")
            
            // Check if we have already seen this device.
            var peripheralIsNew: Bool = true
            for device in discoveredDevices {
                if device.name == safeName {
                    peripheralIsNew = false
                }
            }
            
            guard peripheralIsNew else {
                print("\t \(safeName) is already added.")
                return
            }
            // Connect to the newly discovered peripheral.
            centralManager.connect(peripheral, options: nil)
            // Save the connected peripheral in connectedPeripherals for later use.
            discoveredDevices.append(
                Device(
                    uuid: peripheral.identifier.uuidString,
                    rssi: RSSI.intValue,
                    name: safeName,
                    peripheral: peripheral)
            )
        } else {
            print("Peripheral discovered in overflow area: \n-\t\(peripheral.name ?? "Unknown")-\n-\t\(peripheral.identifier.uuidString)")
        }
    }
    
    
    // Check to make sure that the device we are connecting to is
    // broadcasting the correct characteristics.
    // Called once connection has been fully established.
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        // Set the delegate.
        peripheral.delegate = self
        // Discover services which the peripheral has to offer.
        peripheral.discoverServices([Service().UUID])
    }
    
    
    // MARK: TODO - delegate method if a peripheral fails to connect.
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print("Peripheral failed to connect: \(peripheral.name ?? "Unknown")")
    }
    
    
    /*
     Removes peripheral devices when the lose connection to the central.
     */
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        print("Peripheral disconnected: \(peripheral.name ?? "Unknown")")
        
        central.cancelPeripheralConnection(peripheral)
        centralManager.scanForPeripherals(
            withServices: [Service().UUID],
            options: [
                CBCentralManagerScanOptionAllowDuplicatesKey: true
            ]
        )
        
        var removedDeviceCounter = 0  // Dont try to remove at an index no longer existing.
        for (index, device) in discoveredDevices.enumerated() {
            if device.peripheral == peripheral {
                discoveredDevices.remove(at: index - removedDeviceCounter)
                print("^ And removed from the list of discovered devices.")
                removedDeviceCounter += 1
            }
        }
    }
    
    /*
     Callback function if 'peripheral.readRSSI()' is called on a peripheral.
     */
    func peripheral(_ peripheral: CBPeripheral, didReadRSSI RSSI: NSNumber, error: Error?) {
        // MARK: didReadRSSI to be implemented
//        RSSI.intValue
        for (index, device) in discoveredDevices.enumerated() {
            if device.peripheral == peripheral {
                discoveredDevices[index].rssi = RSSI.intValue
            }
        }
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
            peripheral.discoverCharacteristics([Service().charUUID], for: service)
        }
    }
    
    
    // Once we discover the exptected characteristic we will be fully connected.
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        
        if let error = error {
            print("Unable to discover characteristics: \(error.localizedDescription)")
        }
        
        service.characteristics?.forEach { characteristic in
            guard characteristic.uuid == Service().charUUID else { return }
            // Subsribe to all notifications made by the characteristic.
            peripheral.setNotifyValue(true, for: characteristic)
            // Save a reference of the characteristic to send back
            self.connectedCharateristics.append(characteristic)
        }
    }
    
    
    // Error handling if we are receiving the wrong notifications.
    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        // Only receive notifications from the characteristics that we expect.
        guard characteristic.uuid == Service().charUUID else { return }
        
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
            retreiveData(message)
        } catch {
            print("Error decoding message: \(error)")
        }
    }
    
    // MARK: TODO - this function, whatever it does.
    func peripheral(_ peripheral: CBPeripheral, didModifyServices invalidatedServices: [CBService]) {
//        cleanUp(peripheral)
    }
}
