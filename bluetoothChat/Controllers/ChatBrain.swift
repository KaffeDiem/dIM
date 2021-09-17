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
     Holds all messages in conversations. Thus a conversation also
     consist of a list of messages.
     See: ConversationModel and MessageModel
     */
    @Published var conversations: [Conversation] = []
    
    
    /*
     A simple counter for showing statistics in the Settings View.
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
    var seenMessages: [UInt16] = []
    
    override init() {
        super.init()
        
        // Set up the central and peripheral manager objects to be used across the app.
        centralManager = CBCentralManager(delegate: self, queue: nil)
        peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
        
        centralManager.delegate = self
    }
    
    
    func CheckQueueNewConnection() {
        
    }
    
    /*
     Get the exchanged messages with a given user.
     Used when loading the ChatView()
     */
    func getConversation(sender author: String) -> [LocalMessage] {
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





