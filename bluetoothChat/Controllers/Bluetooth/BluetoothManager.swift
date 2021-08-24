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

class BluetoothManager: NSObject, ObservableObject, CBCentralManagerDelegate, CBPeripheralManagerDelegate, CBPeripheralDelegate {
    
    
    // Published variables are used outside of this class.
    @Published var isReady: Bool = false
    
    var connectedPeripherals: [CBPeripheral] = []
    var connectedCharateristics: [CBCharacteristic] = []
    
    // Holds all messages received from all peripherals.
    @Published var conversations: [Conversation] = []
    @Published var messages: [Message] = []
    
    let service = Service()
    
    var centralManager: CBCentralManager!
    var peripheralManager: CBPeripheralManager!

    var characteristic: CBMutableCharacteristic?
    
    override init() {
        super.init()
        
        centralManager = CBCentralManager(delegate: self, queue: nil)
        peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
        
        centralManager.delegate = self
    }
    
    // MARK: Public functions.
    
    // Return amount of connected devices.
    func getConnectedDevices() -> Int {
        return connectedCharateristics.count
    }
    
    // Get a given conversation
    func getConversation(author: String) -> [Message] {
        for conversation in conversations {
            if conversation.author == author {
                return conversation.messages
            }
        }
        print("There was an error fetching conversation from \(author)")
        return []
    }
    
    
    // MARK: Helper functions.
    
    // Retreive a message from a connected peripheral.
    func retreiveData(_ message: Message) {
        /* Loop trough all conversations. If a conversation exists with the author
         then add the message to said conversation. Otherwise create a new one. */
        var authorFound = false
        
        for (index, conv) in conversations.enumerated() {
            if conv.author == message.author {
                authorFound = true
                conversations[index].addMessage(add: message)
                conversations[index].updateLastMessage(new: message)
            }
        }
        
        // Append a new conversation if none was found.
        if !authorFound {
            conversations.append(
                Conversation(
                    id: message.id,
                    author: message.author,
                    lastMessage: message,
                    messages: [message]
                )
            )
        }
        
        print("\(message.author): \(message.text)")
    }
    
    // Remove a device from connected devices.
    // MARK: DOES NOT DO PROPER CLEANUP YET
    func cleanUp(_ peripheral: CBPeripheral) {
        connectedPeripherals.removeAll() { device in
            return device == peripheral
        }
        
        centralManager.cancelPeripheralConnection(peripheral)
        print(centralManager.retrieveConnectedPeripherals(withServices: [self.service.UUID]))
        print("Cleanup (on device: \(peripheral.name ?? "Unknown")")
    }
}





