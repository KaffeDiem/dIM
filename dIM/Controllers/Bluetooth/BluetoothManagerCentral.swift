//
//  BluetoothManagerCentral.swift
//  bluetoothChat
//
//  Created by Kasper Munch on 23/08/2021.
//

import Foundation
import CoreBluetooth

extension ChatHandler {
    
    // MARK: CentralManager callback functions. Handles the server side of Bluetooth.
    
    /// Callback function which gets the Bluetooth state of this device.
    ///
    /// If Bluetooth is turned on and functions correctly we will start scanning
    /// for peripherals.
    /// - Note: Cases such as .poweredOff are not handled right now. In the future they should be.
    /// - Parameter central: The Central Manager which has its state updated. Given by Apple APIs.
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
            case .poweredOn:
                centralManager.scanForPeripherals(withServices: [Session.UUID], options: nil)
            case .poweredOff:
                discoveredDevices = []
            default:
                print("A default case was triggerd.")
        }
    }
    
    /// Callback function which is activated if a peripheral is discovered.
    ///
    /// This means that if this function is called a new device is nearby and ready
    /// to broadcast messages for us.
    /// - Note: Converts the peripheral to a Device() and stores it in memory. Otherwise the connection would be dropped.
    /// - Parameters:
    ///   - central: The central manager which discovers the peripheral.
    ///   - peripheral: The peripheral which is discovered.
    ///   - advertisementData: Holds information such as the name of the peripheral. See more in Apples docs.
    ///   - RSSI: The signal strength to the peripheral device.
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
    
    /// Callback function if the central manager connected successfully to the peripheral.
    ///
    /// Afterwards we discover what services it has to offer, and checks that it
    /// supports the dIM identifier. Otherwise it could be all other Bluetooth devices.
    /// - Parameters:
    ///   - central: The central manager which connects to the peripheral.
    ///   - peripheral: The peripheral which we connected successfully to.
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        // Set the delegate.
        peripheral.delegate = self
        // Discover services which the peripheral has to offer.
        peripheral.discoverServices([Session.UUID])
    }
    
    /// Callback function if we fail to connect to some peripheral.
    ///
    /// - Note: No error handling has been implemented yet.
    /// - Parameters:
    ///   - central: The central manager which fails to connect.
    ///   - peripheral: The peripheral which we fail to connect to.
    ///   - error: The error description of the failed connection.
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print("Peripheral failed to connect: \(peripheral.name ?? "Unknown")")
    }
    
    /// Callback function called when we lose connection to a peripheral.
    ///
    /// This function cleans up the peripheral and removes it from memory.
    /// - Note: Should remove the device from the `connectedDevices` array as well (in the future).
    /// - Parameters:
    ///   - central: The central which loses its connection to a peripheral.
    ///   - peripheral: The peripheral device which we lose connection to.
    ///   - error: The error description of the lost connection. (out-of-range for example)
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        print("Peripheral disconnected: \(peripheral.name ?? "Unknown")")
        
        central.cancelPeripheralConnection(peripheral)
        centralManager.scanForPeripherals(
            withServices: [Session.UUID],
            options: [
                CBCentralManagerScanOptionAllowDuplicatesKey: true
            ]
        )
        
        cleanUpPeripheral(peripheral)
    }
    
    /// Callback function whenever a peripheral updates its RSSI.
    ///
    /// - Note: RSSI is the signal strength.
    /// - Parameters:
    ///   - peripheral: The peripheral which updates its RSSI.
    ///   - RSSI: The new RSSI value for said peripheral.
    ///   - error: The error description if there are any. Printed to console.
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
    
    /// Callback function if we discover the dIM UUID on a peripheral device.
    ///
    /// Afterwards we look for the specific characteristic which defines our
    /// chat functionality.
    /// - Parameters:
    ///   - peripheral: The peripheral in which we discover a service.
    ///   - error: The error description if there are any. Printed to the console.
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let error = error {
            print("Unable to discover services: \(error.localizedDescription)")
            // TODO: Should probably clean up here.
            return
        }

        // Loop trough services in case there are multiple and
        // connect to our characteristic if it is found.
        peripheral.services?.forEach {service in
            peripheral.discoverCharacteristics([Session.characteristicsUUID], for: service)
        }
    }
    
    
    /// Callback function if we discover the characteristic which defines the chat functionality.
    ///
    /// - Note: This means that we are fully connected and ready to receive messages.
    /// - Parameters:
    ///   - peripheral: The now fully connected peripheral.
    ///   - service: The service which we have discovered, only chat functionality is provided.
    ///   - error: The error description if there are any. Printed to the console.
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        
        if let error = error {
            print("Unable to discover characteristics: \(error.localizedDescription)")
        }
        
        service.characteristics?.forEach { characteristic in
            guard characteristic.uuid == Session.characteristicsUUID else { return }
            // Subsribe to all notifications made by the characteristic.
            peripheral.setNotifyValue(true, for: characteristic)
            // Save a reference of the characteristic to send back
            self.connectedCharateristics.append(characteristic)
        }
    }
    
    
    /// Callback function which does error handling if we receive the wrong notifications.
    ///
    /// Notifications are new messages.
    /// - Parameters:
    ///   - peripheral: The peripheral which send the notification.
    ///   - characteristic: The characteristic which it sends notification for (chat functionality).
    ///   - error: Error description if any. Printed to the console.
    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        // Only receive notifications from the characteristics that we expect.
        guard characteristic.uuid == Session.characteristicsUUID else { return }
        
        if let error = error {
            print("Unable to get new notification: \(error.localizedDescription)")
        }
        
        // Cancel subs if they are not for us.
        if !characteristic.isNotifying {
            print("Cancel subsribtions from: \(peripheral.name ?? "Unknown")")
            centralManager.cancelPeripheralConnection(peripheral)
        }
    }
    
    
    /// Callback function which is called whenever we receive a new message.
    ///
    /// Checks that we are not receiving too many messages from this particular device
    /// and that we are not getting DOS attacked.
    ///
    /// The message is then decoded from JSON and passed to our `receivedMessage`.
    /// - Parameters:
    ///   - peripheral: The peripheral which we receive a new message from.
    ///   - characteristic: The chateristic which we receive a new message from.
    ///   - error: Error description if there are any. Also printed to the console.
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if let error {
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
        
        // Decode the message received from a connected peripheral and save it.
        do {
            let message = try JSONDecoder().decode(Message.self, from: data)
            // Handle decoded messages.
            retrieveMessage(message)
            
            // If we use the DSR algorithm then save message id and sender.
            if useDSRAlgorithm {
                // Only save normal messages as these are the only ones
                // we are interested in.
                if message.type == 0 {
                    addMessageToDSRTable(
                        messageID: message.id,
                        bluetoothID: peripheral.identifier.uuidString
                    )
                }
            }
        } catch {
            print("JSON Error decoding message: \(error)")
        }
    }
    
    /// Callback function if a peripheral modifies its services. This is not allowed
    /// and we therefore drop our connection to it.
    /// - Parameters:
    ///   - peripheral: The peripheral modifying its services.
    ///   - invalidatedServices: The service which it invalidates.
    func peripheral(_ peripheral: CBPeripheral, didModifyServices invalidatedServices: [CBService]) {
        print("Peripheral modified services: \(peripheral.name!) \n^ and is cleaned")
        cleanUpPeripheral(peripheral)
    }
}
