//
//  BluetoothManager.swift
//  bluetoothChat
//
//  Created by Kasper Munch on 23/08/2021.
//

import Foundation
import CoreBluetooth

// The Bluetooth Manager handles all searching for, creating connection to
// and sending/receiving messages to/from other Bluetooth devices.

class ChatBrain: NSObject, ObservableObject, CBCentralManagerDelegate, CBPeripheralManagerDelegate, CBPeripheralDelegate {
    /*
     Hacky solution to solve a problem with ObservableObjects.
     TO BE IMPLEMENTED.
     */
    private var isPaused: Bool = false
    private var hasPendingUpdates: Bool = false
        
    var discoveredDevices: [Device] = []
    var connectedCharateristics: [CBCharacteristic] = []
    
    // Holds all messages received from all peripherals.
    @Published var conversations: [Conversation] = []
    var routedMessagesCounter: Int = 0
    
    
    var centralManager: CBCentralManager!
    
    var peripheralManager: CBPeripheralManager!

    var characteristic: CBMutableCharacteristic?
    
    var seenMessages: [UInt16] = []
    
    override init() {
        super.init()
        
        // Set up the central and peripheral manager objects to be used across the app.
        centralManager = CBCentralManager(delegate: self, queue: nil)
        peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
        
        centralManager.delegate = self
    }
    
    
    /*
     Get the exchanged messages with a given user.
     Used when loading the ChatView()
     */
    func getConversation(sender author: String) -> [Message] {
        for conversation in conversations {
            if conversation.author == author {
                return conversation.messages
            }
        }
        
        return []
    }
    
    
    /*
     Get the last message of a conversation if there are any.
     */
    func getLastMessage(_ user: String) -> String? {
        for conversation in conversations {
            if conversation.author == user {
                return conversation.lastMessage.text
            }
        }
        
        return nil
    }
    
    
    /*
     Remove a device from discoveredDevices and drop connection to it.
     */
    func cleanUpPeripheral(_ peripheral: CBPeripheral) {
        print("Clean up: \(peripheral.name ?? "Unknown")")
        
        let connected = centralManager.retrieveConnectedPeripherals(withServices: [Service().UUID])
        
        for device in connected {
            if device == peripheral {
                centralManager.cancelPeripheralConnection(peripheral)
            }
        }
        
        for (index, device) in discoveredDevices.enumerated() {
            
            if device.peripheral == peripheral {
                
        
                
                discoveredDevices.remove(at: index)
                return
            }
        }
    }
}





