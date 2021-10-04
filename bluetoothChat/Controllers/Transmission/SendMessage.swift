//
//  SendMessage.swift
//  bluetoothChat
//
//  Created by Kasper Munch on 27/08/2021.
//

import Foundation
import CoreData

extension ChatBrain {
    
    func sendMessage(for conversation: ConversationEntity, text message: String, context: NSManagedObjectContext) {
        
        let defaults = UserDefaults.standard
        
        /*
         Send a string to all connected devices.
         */
        guard message != "" else { return }
        
        let username = defaults.string(forKey: "Username")!
        
        /*
         Encrypt the message text.
         */
        let privateKey = getPrivateKey()
        let receiverPublicKey = try! importPublicKey(conversation.publicKey!)
        let symmetricKey = try! deriveSymmetricKey(privateKey: privateKey, publicKey: receiverPublicKey)
        let encryptedData = try! encryptMessage(text: message, symmetricKey: symmetricKey)
        
        /*
         The unique message ID.
         */
        let messageId = Int32.random(in: 0...Int32.max)
        
        
        /*
         The encrypted message which is sent to other users.
         */
        let encryptedMessage = Message(
            id: messageId,
            sender: username,
            receiver: conversation.author!,
            text: encryptedData
        )
        
        if let characteristic = self.characteristic {
            do {
                let messageEncoded = try JSONEncoder().encode(encryptedMessage)
                
                /*
                 Send the message to all connected peripherals.
                 */
                peripheralManager.updateValue(messageEncoded, for: characteristic, onSubscribedCentrals: nil)
                messageQueueAdd(encryptedMessage)
            } catch {
                print("Error encoding message: \(message) -> \(error)")
            }
        }
        
        /*
         Add the message to local storage
         */
        let localMessage = MessageEntity(context: context)
        
        localMessage.receiver = conversation.author
        localMessage.status = Status.sent.rawValue
        localMessage.text = message
        localMessage.date = Date()
        localMessage.id = messageId
        localMessage.sender = username
        
        conversation.lastMessage = message
        conversation.addToMessages(localMessage)
        
        try? context.save()
    }
    
    
    /*
     Send a message of IDs which confirm that we have read the
     received messages.
     This is only done if the setting has been enabled in settings.
     */
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
        
        /*
         Return if there are no messages to send.
         */
        guard received.count > 0 else {
            return
        }
        
        /*
         Compose a single READ message to send.
         */
        var text: String = "READ/"
        
        for message in received {
            text = text + String(message.id) + "/"
        }
        
        let readMessage = Message(
            id: Int32.random(in: 0...Int32.max),
            sender: UserDefaults.standard.string(forKey: "Username")!,
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
    
    
    func sendAckMessage(_ message: MessageEntity) {
        let ackMessage = Message(
            id: Int32.random(in: 0...Int32.max),
            sender: UserDefaults.standard.string(forKey: "Username")!,
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
