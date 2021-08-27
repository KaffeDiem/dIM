//
//  BluetoothManager.swift
//  bluetoothChat
//
//  Created by Kasper Munch on 23/08/2021.
//

import Foundation
import CoreBluetooth
import UserNotifications

// The Bluetooth Manager handles all searching for, creating connection to
// and sending/receiving messages to/from other Bluetooth devices.

class ChatBrain: NSObject, ObservableObject, CBCentralManagerDelegate, CBPeripheralManagerDelegate, CBPeripheralDelegate {
    
        
    var discoveredDevices: [Device] = []
    var connectedCharateristics: [CBCharacteristic] = []
    
    // Holds all messages received from all peripherals.
    @Published var conversations: [Conversation] = []
    
    var centralManager: CBCentralManager!
    var peripheralManager: CBPeripheralManager!

    var characteristic: CBMutableCharacteristic?
    
    override init() {
        super.init()
        
        // Set up the central and peripheral manager objects to be used across the app.
        centralManager = CBCentralManager(delegate: self, queue: nil)
        peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
        
        centralManager.delegate = self
    }
    
    
    /*
     Send a string to all connected devices.
     */
    func sendData(message: String) {
        
        guard message != "" else { return }
        
        if let characteristic = self.characteristic {
            
            let username = UserDefaults.standard.string(forKey: "Username")!
            let packet = Message(
                id: Int.random(in: 1...1000),
                text: message,
                // If no username has been saved in UserDefaults then use the name of the device.
                author: username
            )
            
            let encoder = JSONEncoder()
            
            do {
                let messageEncoded = try encoder.encode(packet)
                print("-")
                peripheralManager.updateValue(messageEncoded, for: characteristic, onSubscribedCentrals: nil)
            } catch {
                print("Error encoding message: \(message) -> \(error)")
            }
        }
    }
    
    
    /*
     Get the exchanged messages with a given user.
     Used when loading the ChatView()
     */
    func getConversation(author: String) -> [Message] {
        for conversation in conversations {
            if conversation.author == author {
                return conversation.messages
            }
        }
        print("There was an error fetching conversation from \(author)")
        return []
    }
    
    
    /*
     Add a sent message to the conversation. Used when sending a device a
     new message.
     */
    func addMessage(receipent: String, messageText: String) {
        guard messageText != "" else { return } // Do not add empty messages.
        
        // Check which conversation to add the message to.
        for (index, conv) in conversations.enumerated() {
            if conv.author == receipent {
                let message = Message(
                    id: Int.random(in: 0...1000),
                    text: messageText,
                    author: UserDefaults.standard.string(forKey: "Username")!)
                conversations[index].addMessage(add: message)
            }
        }
    }
    
    
    /*
     Add messages to the correct conversation or create a new one if the
     sender has not been seen before.
     */
    func retreiveData(_ message: Message) {
        var authorFound = false
        //  Loop trough conversations to find a match if possible.
        for (index, conv) in conversations.enumerated() {
            if conv.author == message.author {
                authorFound = true
                conversations[index].addMessage(add: message)
                conversations[index].updateLastMessage(new: message)
            }
        }
        //  Create a new conversation if the sender has not been seen.
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
        
        /* Send a notification when we receive a message */
        let content = UNMutableNotificationContent()
        content.title = message.author
        content.body = message.text
        content.sound = UNNotificationSound.default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.5, repeats: false)

        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request)
    }
}





