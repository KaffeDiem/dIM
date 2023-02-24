//
//  SendMessage.swift
//  bluetoothChat
//
//  Created by Kasper Munch on 27/08/2021.
//

import Foundation
import CoreData

extension AppSession {
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
            if MessageStatus(rawValue: message.status) == .received {
                received.append(message)
                message.status = MessageStatus.receivedReadSent.rawValue
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
            kind: .read,
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
            kind: .acknowledgement,
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
