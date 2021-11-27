//
//  BluetoothManager.swift
//  bluetoothChat
//
//  Created by Kasper Munch on 23/08/2021.
//

import Foundation
import CoreBluetooth
import SwiftUI
import CoreData

// The Bluetooth Manager handles all searching for, creating connection to
// and sending/receiving messages to/from other Bluetooth devices.

class ChatBrain: NSObject, ObservableObject, CBCentralManagerDelegate, CBPeripheralManagerDelegate, CBPeripheralDelegate {
    
    /*
     Context for CoreData storage
     */
    var context: NSManagedObjectContext
    
    /*
     A simple counter to show amount of relayed messages this session.
     */
    @Published var routedCounter: Int = 0
    
    
    /*
     Holds an array of messages to be delivered at a later point.
     */
    @Published var messageQueue: [queuedMessage] = []
    
    
    /*
     Holds a reference to all devices discovered. If no reference
     is held then the Bluetooth connection may be dropped.
     */
    @Published var discoveredDevices: [Device] = []
    
    var connectedCharateristics: [CBCharacteristic] = []
    
    /*
     The central and peripheral managers act as a client/server on the
     device. Therefore all devices act as clients and servers
     simutaniously.
     */
    var centralManager: CBCentralManager!
    var peripheralManager: CBPeripheralManager!

    var characteristic: CBMutableCharacteristic?
    
    /*
     A list which holds message IDs which we have seen before.
     This prevents looping them in the network for ages.
     */
    var seenMessages: [Int32] = []
    
    var peripheralMessages: [String : [Date]] = [:]
    
    /*
     A dict which holds the ids of messages relayed and the corresponding sender
     of said messages. This is used for DSR.
     */
    var senderOfMessageID: [Int32 : String] = [:]
    
    /*
     Seen CBCentrals / This is used for DSR algorithm.
     */
    var seenCBCentral: [CBCentral] = []
    
    init(context: NSManagedObjectContext) {
        self.context = context
        
        super.init()
        
        // Set up the central and peripheral manager objects to be used across the app.
        centralManager = CBCentralManager(delegate: self, queue: nil)
        peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
        
        centralManager.delegate = self
    }
    
    
    /*
     Remove a device from discoveredDevices and drop connection to it.
     */
    func cleanUpPeripheral(_ peripheral: CBPeripheral) {
        
        let connected = centralManager.retrieveConnectedPeripherals(withServices: [Service().UUID])
        
        /*
         Cancel the connection from the central manager.
         */
        for device in connected {
            if device == peripheral {
                centralManager.cancelPeripheralConnection(peripheral)
            }
        }
        
        /*
         Remove all references to the the peripheral.
         */
        for (index, device) in discoveredDevices.enumerated() {
            
            if device.peripheral == peripheral {
                discoveredDevices.remove(at: index)
                return
            }
        }
    }
}





