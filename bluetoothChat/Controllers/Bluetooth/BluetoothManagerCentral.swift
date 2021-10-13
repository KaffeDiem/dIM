//
//  BluetoothManagerCentral.swift
//  bluetoothChat
//
//  Created by Kasper Munch on 23/08/2021.
//

import Foundation
import CoreBluetooth

/*
 Check the Bluetooth state of the device. If it is powered on and ready
 then start searching for peripherals to connect to. 
 */
extension ChatBrain {
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        
            case .poweredOn:
                centralManager.scanForPeripherals(withServices: [Service().UUID], options: nil)
            default:
                print("A default case was triggerd.")
        }
    }
    
    
    /*
     Connect to peripheral devices which broadcast the chosen UUID
     for the app and add it to discovered devices.
     Callback function activated whenever a peripheral is discovered.
     */
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        
        let name = advertisementData[CBAdvertisementDataLocalNameKey] as? String ?? "Unknown"
        
        // Check if we have already seen this device.
        var peripheralIsNew: Bool = true
        
        for device in discoveredDevices {
            /*
             Check if devices are still connected at the same time.
             */
            if device.peripheral.state != .connected && device.peripheral.state != .connecting {
                cleanUpPeripheral(device.peripheral)
            }
            
            if device.uuid == peripheral.identifier.uuidString {
                peripheralIsNew = false
            }
        }
        
        
        guard peripheralIsNew else {
            return
        }
        
        // Connect to the newly discovered peripheral.
        centralManager.connect(peripheral, options: nil)
        
        print("Connecting to: \(name)")
        
    
        // Save the connected peripheral in connectedPeripherals for later use.
        discoveredDevices.append(
            Device(
                uuid: peripheral.identifier.uuidString,
                rssi: RSSI.intValue,
                name: name,
                peripheral: peripheral)
        )
    }
    
    
    /*
     If connection to peripheral was successfull then discover its services.
     */
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
     Removes peripheral devices when they lose connection to the central.
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
        
        cleanUpPeripheral(peripheral)
    }
    
    
    /*
     Read RSSI from a peripheral and save it to device list.
     Callback function if 'peripheral.readRSSI()' is called on a peripheral.
     */
    func peripheral(_ peripheral: CBPeripheral, didReadRSSI RSSI: NSNumber, error: Error?) {

        if let error = error {
            print("Error reading RSSI: \(error.localizedDescription)")
        }
        
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
        
        /*
         Check that no more than 60 messages have been received
         by this peripheral in the last minute. If more than 60 messages
         are received in the last minute then block messages for now.
         */
        let uuid = peripheral.identifier.uuidString
        if let safeDates = peripheralMessages[uuid] {
            if safeDates.count > 60 {
                //cleanup
                var newDates: [Date] = []
                
                for date in safeDates {
                    print("\(date.timeIntervalSinceNow) date")
                    if date.timeIntervalSinceNow > -60 {
                        newDates.append(date)
                    }
                }
                
                guard newDates.count < 60 else {
                    print("Error: More than 60 messages received this past minute.")
                    return
                }
                
                peripheralMessages[uuid] = newDates
            }
        } else {
            peripheralMessages[uuid] = [Date()]
        }
        
        peripheralMessages[uuid]!.append(Date())
        print(peripheralMessages[uuid]!.count, peripheral.identifier.uuidString)
        
        
        let decoder = JSONDecoder()
        // Decode the message received from a connected peripheral and save it.
        do {
            let message = try decoder.decode(Message.self, from: data)
            // Handle decoded messages.
            retrieveMessage(message)
        } catch {
            print("JSON Error decoding message: \(error)")
        }
    }
    
    
    // MARK: TODO - this function, whatever it does.
    func peripheral(_ peripheral: CBPeripheral, didModifyServices invalidatedServices: [CBService]) {
        print("Peripheral modified services: \(peripheral.name!) \n^ and is cleaned")
        cleanUpPeripheral(peripheral)
    }
}
