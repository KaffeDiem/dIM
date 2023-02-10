//
//  SendMessage.swift
//  bluetoothChat
//
//  Created by Kasper Munch on 27/08/2021.
//

import Foundation
import CoreData

extension ChatHandler {
    
    // MARK: Sending messages.
    
    /// Sends a message to a specific user.
    ///
    /// This is done by encrypting the content of the message, generating new id's
    /// and passing it along to the peripheral manager to send out to connected
    /// central managers.
    /// - Parameters:
    ///   - conversation: The conversation for whom we want to send a message.
    ///   - message: The message that we want to send. It is encrypted in this function.
    ///   - context: The context which we save the message. Used for persistent storage to CoreData.
    func sendMessage(for conversation: ConversationEntity, text message: String, context: NSManagedObjectContext) {
        guard !message.isEmpty else { return }
        let validator = UsernameValidator()
        guard let username = validator.userInfo?.asString else {
            fatalError("Could not find username while sending a message")
        }
        
        /*
         Encrypt the message text.
         */
        let privateKey = CryptoHandler.getPrivateKey()
        let receiverPublicKey = try! CryptoHandler.importPublicKey(conversation.publicKey!)
        let symmetricKey = try! CryptoHandler.deriveSymmetricKey(privateKey: privateKey, publicKey: receiverPublicKey)
        let encryptedData = try! CryptoHandler.encryptMessage(text: message, symmetricKey: symmetricKey)
        
        /*
         The unique message ID.
         */
        let messageId = Int32.random(in: 0...Int32.max)
        
        /*
         The encrypted message which is sent to other users.
         */
        let encryptedMessage = Message(
            id: messageId,
            type: 0,
            sender: username,
            receiver: conversation.author!,
            text: encryptedData
        )
        
        if let characteristic {
            do {
                let messageEncoded = try JSONEncoder().encode(encryptedMessage)
                // Send message to all connected devices
                peripheralManager.updateValue(messageEncoded, for: characteristic, onSubscribedCentrals: nil)
                messageQueueAdd(encryptedMessage)
            } catch {
                print("Error encoding message: \(message) -> \(error)")
            }
        }
        
        // Save the message to local storage
        let localMessage = MessageEntity(context: context)
        
        localMessage.receiver = conversation.author
        localMessage.status = Status.sent.rawValue
        localMessage.text = message
        localMessage.date = Date()
        localMessage.id = messageId
        localMessage.sender = username
        
        conversation.lastMessage = "You: " + message
        conversation.date = Date()
        conversation.addToMessages(localMessage)
        
        try? context.save()
    }
    
    
    /*
     Send a message of IDs which confirm that we have read the
     received messages.
     This is only done if the setting has been enabled in settings.
     */
    /// Sends a message of id's which confirms that we have read the
    /// received messages.
    ///
    /// This function is only called if we have enabled the `read` functionality
    /// in the settings menu.
    ///
    /// We send a message with all the id's of the messages that we have read
    /// formatted as `READ/id1/id2/id2...`.
    /// - Parameter conversation: The conversation which we have recently opened.
    func sendReadMessage(_ conversation: ConversationEntity) {
        guard conversation.messages != nil else { return }
        /*
         Create a list of messages which has been received but
         no read status has been sent yet.
         */
        var received: [MessageEntity] = []
        let messages: [MessageEntity] = conversation.messages!.allObjects as! [MessageEntity]
        
        for message in messages {
            if Status(rawValue: message.status) == Status.received {
                received.append(message)
                message.status = Status.receivedReadSent.rawValue
            }
        }
        
        // Return if there are no messages to send
        guard received.count > 0 else {
            return
        }
        
        // Create one single READ message for all the messages ids
        var text: String = "READ/"
        for message in received {
            text = text + String(message.id) + "/"
        }
        
        let validator = UsernameValidator()
        guard let usernameWithDigits = validator.userInfo?.asString else {
            fatalError("A READ message was sent but no username has been set")
        }
        
        let readMessage = Message(
            id: Int32.random(in: 0...Int32.max),
            type: 2,
            sender: usernameWithDigits,
            receiver: conversation.author ?? "Unknown",
            text: text
        )
        
        if let characteristic = self.characteristic {
            seenMessages.append(readMessage.id)
            do {
                let readMessageEncoded = try JSONEncoder().encode(readMessage)
                peripheralManager.updateValue(readMessageEncoded, for: characteristic, onSubscribedCentrals: nil)
            } catch {
                print("Error encoding message: \(readMessage) -> \(error)")
            }
        }
    }
    
    
    /// Sends an `ACK` message to confirm that we have received a message.
    /// If we use DSR (Dynamic Source Routing) this messages is sent on the
    /// shortest route possible.
    /// - Parameter message: The message which we want to send an ACK message for.
    func sendAckMessage(_ message: MessageEntity) {
        let validator = UsernameValidator()
        guard let usernameWithDigits = validator.userInfo?.asString else {
            fatalError("An ACK message was sent but no username has been set")
        }
        let ackMessage = Message(
            id: Int32.random(in: 0...Int32.max),
            type: 1,
            sender: usernameWithDigits,
            receiver: message.sender!,
            text: "ACK/\(message.id)"
        )
        
        if let characteristic = self.characteristic {
            seenMessages.append(ackMessage.id)
            do {
                let ackMessageEncoded = try JSONEncoder().encode(ackMessage)
                
                peripheralManager.updateValue(ackMessageEncoded, for: characteristic, onSubscribedCentrals: nil)
            } catch {
                print("Error encoding message: \(ackMessage) -> \(error)")
            }
        }
    }
}
