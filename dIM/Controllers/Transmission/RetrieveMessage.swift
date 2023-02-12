//
//  RetrieveMessage.swift
//  bluetoothChat
//
//  Created by Kasper Munch on 27/08/2021.
//

import Foundation
import UserNotifications
import SwiftUI
import CoreData


extension AppSession {
    
    // MARK: Receiving messages.

    /// Retrieve a message from a sender and handle it accordingly.
    ///
    /// If the message is not for us we relay it to connected Bluetooth
    /// centrals. Otherwise, if it is for us, we start decrypting it and
    /// adding it to the correct conversation. Then we send an `ACK` message
    /// to confirm that we have received it.
    /// - Parameter messageEncrypted: The message that we have received. Then we determine if it is for us.
    func retrieveMessage(_ messageEncrypted: Message) {
        // Do nothing if the message has been seen already
        guard !seenMessages.contains(messageEncrypted.id) else {
            return
        }
        // Add message to list of previously seen messages
        seenMessages.append(messageEncrypted.id)
        
        let validator = UsernameValidator()
        let usernameWithDigits = validator.userInfo?.asString
        let messageIsForMe: Bool = messageEncrypted.receiver == usernameWithDigits
        
        // If message is not for me relay it
        guard messageIsForMe else {
            if useDSRAlgorithm {
                // If the message type is an ACK message.
                if messageEncrypted.kind == .acknowledgement {
                    // Get the ID from the ACK message
                    let components = messageEncrypted.text.components(separatedBy: "/")
                    let messageID = Int32(components[1])!
                    
                    if checkMessageSeenBefore(messageID: messageID) {
                        /*
                         The Bluetooth UUID of the original sender of the message.
                         */
                        let senderBluetoothID = getSenderOfMessage(messageID: messageID)
                        relayMessage(messageEncrypted, senderBluetoothID)
                        return
                    }
                }
            }
            relayMessage(messageEncrypted)
            return
        }
        
        var conversations: [ConversationEntity] = []
        
        /*
         Fetch conversations from CoreData and save them to the conversations
         variable such that we can add and save the received message.
         */
        context.perform {
            do {
                let fetchRequest: NSFetchRequest<ConversationEntity> = ConversationEntity.fetchRequest()
                conversations = try fetchRequest.execute()
               
                var currentConversation: ConversationEntity? = nil
                
                // Get the conversation where this message belong
                for c in conversations {
                    if c.author == messageEncrypted.sender {
                        currentConversation = c
                        break
                    }
                }
                
                guard currentConversation != nil else {
                    print("Error: Received message but could not find sender in contacts.");
                    return
                }
                
                let decryptedText = self.decryptRetrievedMessageToString(
                    message: messageEncrypted,
                    conversation: currentConversation!
                )
                
                let localMessage = MessageEntity(context: self.context)
                localMessage.id = messageEncrypted.id
                localMessage.receiver = usernameWithDigits
                localMessage.sender = messageEncrypted.sender
                localMessage.status = Status.received.rawValue
                localMessage.text = decryptedText
                localMessage.date = Date()
                    
                let ack = self.receivedAck(message: messageEncrypted, conversation: currentConversation!)
                guard !ack else {
                    try? self.context.save()
                    return
                }
                
                let read = self.receivedRead(message: messageEncrypted, conversation: currentConversation!)
                guard !read else {
                    try? self.context.save()
                    return
                }
                    
                currentConversation!.addToMessages(localMessage)
                currentConversation!.lastMessage = localMessage.text!
                currentConversation!.date = Date()
                self.sendAckMessage(localMessage)
                
                self.sendNotification(what: localMessage)
                
                try? self.context.save()
            } catch let error as NSError {
                print("Error fetching conversations from CoreData: \(error)")
            }
        }
    }
    
    
    /// Called if we have received a `READ` message type. This is to handle
    /// that type of messages correctly.
    ///
    /// Also confirms that the message is formatted correctly.
    /// - Parameters:
    ///   - message: The `READ` message that we have received.
    ///   - conversation: The conversation in which the message is to be handled.
    /// - Returns: A boolean that confirms that the type of message is a `READ` type.
    func receivedRead(message: Message, conversation: ConversationEntity) -> Bool {
        // Check if message is a READ type
        var components = message.text.components(separatedBy: "/")
        guard components.first == "READ" && components.count > 1 else {
            return false
        }
        
        /*
         Remove first element as it is then just an array of
         message IDs which has been read.
         */
        components.removeFirst()
        components.removeLast()
        
        let intComponents = components.map {Int32($0)!}
        
        let messages = conversation.messages?.allObjects as! [MessageEntity]
        
        for message in messages {
            if intComponents.contains(message.id) {
                message.status = Status.read.rawValue
            }
        }
      
        self.refreshID = UUID()
        try? context.save()
        
        return true
    }
    
    /// Handles `ACK` message types. Also confirms that the message is correctly
    /// formatted and updates the conversation.
    /// - Parameters:
    ///   - message: The `ACK` message we have received.
    ///   - conversation: The conversation in which it is handled.
    /// - Returns: A boolean confirming that it is or is not an `ACK` message.
    func receivedAck(message: Message, conversation: ConversationEntity) -> Bool {
        // Check if message is of ACK type
        let components = message.text.components(separatedBy: "/")
        guard components.first == "ACK" && components.count == 2 else {
            return false
        }
        
        let messages = conversation.messages?.allObjects as! [MessageEntity]
        for message in messages {
            if message.id == Int(components[1])! {
                message.status = Status.delivered.rawValue
            }
        }
        
        self.refreshID = UUID()
        try? self.context.save()
        return true
    }
    
    /// Decrypt a message to a string.
    /// - Parameters:
    ///   - message: The message to decrypt.
    ///   - conversation: The conversation to decrypt the message for.
    /// - Returns: The decrypted content of the message or nil if it cannot be decrypted.
    func decryptRetrievedMessageToString(message: Message, conversation: ConversationEntity) -> String? {
        
        let senderPublicKey = try! CryptoHandler.importPublicKey(conversation.publicKey!)
        let symmetricKey = try! CryptoHandler.deriveSymmetricKey(privateKey: CryptoHandler.getPrivateKey(), publicKey: senderPublicKey)
        
        return CryptoHandler.decryptMessage(text: message.text, symmetricKey: symmetricKey)
    }
    
    /// Send a notification to the user if the app is closed and and we retrieve a message.
    /// - Parameter message: The message that the user has received.
    private func sendNotification(what message: MessageEntity) {
        let content = UNMutableNotificationContent()
        content.title = message.sender!.components(separatedBy: "#").first ?? "Unknown"
        content.body = message.text!
        content.sound = UNNotificationSound.default

        let trigger = UNTimeIntervalNotificationTrigger(
            timeInterval: 0.1,
            repeats: false
        )
        
        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request)
    }
    
}
