//
//  SendMessage.swift
//  bluetoothChat
//
//  Created by Kasper Munch on 27/08/2021.
//

import Foundation

extension ChatBrain {
    
    func sendMessage(for receiver: String, text message: String) {
        
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
        
        let receiverPublicKeyString = defaults.string(forKey: receiver)
        let receiverPublicKey = try! importPublicKey(receiverPublicKeyString!)
        
        let symmetricKey = try! deriveSymmetricKey(privateKey: privateKey, publicKey: receiverPublicKey)
        
        let encryptedData = try! encryptMessage(text: message, symmetricKey: symmetricKey)
        
        /*
         The unique message ID.
         */
        let messageId = UInt16.random(in: 0...UInt16.max)
        
        
        /*
         The encrypted message which is sent to other users.
         */
        let encryptedMessage = Message(
            id: messageId,
            sender: username,
            receiver: receiver,
            text: encryptedData
        )
        
        /*
         The unencrypted message is used for local storage purposes
         and has the same ID as the encrypted one.
         */
        let message = Message(
            id: messageId,
            sender: username,
            receiver: receiver,
            text: message
        )
        
        if let characteristic = self.characteristic {
    
            /*
             Append the sent message to the list of seen messages
             to avoid sending it again if it loops.
             */
            seenMessages.append(encryptedMessage.id)
            
            do {
                let messageEncoded = try JSONEncoder().encode(encryptedMessage)
                
                peripheralManager.updateValue(messageEncoded, for: characteristic, onSubscribedCentrals: nil)
            } catch {
                print("Error encoding message: \(message) -> \(error)")
            }
        }
        
        /*
         Add the message to the local conversation.
         */
        var conversationFound: Bool = false
        
        for (index, conv) in conversations.enumerated() {
            if conv.author == receiver {
                
                conversations[index].addMessage(add: message)
                conversations[index].lastMessage = message
                
                conversationFound = true
                
            }
        }
        
        // If the conversation have not been found, create it.
        if !conversationFound {
            conversations.append(
                Conversation(
                    id: message.id,
                    author: receiver,
                    lastMessage: message,
                    messages: [message]
                )
            )
        }
    }
    
    func sendAckMessage(_ message: Message) {
        print("Send ACK msg")
        let ackMessage = Message(
            id: UInt16.random(in: 0...UInt16.max),
            sender: UserDefaults.standard.string(forKey: "Username")!,
            receiver: message.sender,
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
