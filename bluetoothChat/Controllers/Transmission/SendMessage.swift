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
         The unencrypted message is used for local storage purposes. It is
         of the type LocalMessage which allows for more information to be
         stored in the message. It has the same ID as the one sent.
         */
        let localMessage = LocalMessage(
            id: messageId,
            sender: username,
            receiver: receiver,
            text: message,
            status: .sent
        )
        
        if let characteristic = self.characteristic {
            do {
                let messageEncoded = try JSONEncoder().encode(encryptedMessage)
                
                /*
                 Send the message to all connected peripherals.
                 */
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
                
                conversations[index].addMessage(add: localMessage)
                conversations[index].lastMessage = localMessage
                
                conversationFound = true
                
            }
        }
        
        // If the conversation have not been found, create it.
        if !conversationFound {
            conversations.append(
                Conversation(
                    id: localMessage.id,
                    author: receiver,
                    lastMessage: localMessage,
                    messages: [localMessage]
                )
            )
        }
    }
    
    
    /*
     Send a message of IDs which confirm that we have read the
     received messages.
     This is only done if the setting has been enabled in settings.
     */
    func sendReadMessage(_ sender: String) {
        /*
         Create a list of messages which has been received but
         no read status has been sent yet.
         */
        var received: [LocalMessage] = []
        
        for (i, conversation) in conversations.enumerated() {
            if conversation.author == sender {
                for (j, message) in conversation.messages.enumerated() {
                    if message.status == .received {
                        received.append(message)
                        conversations[i].messages[j].messageReceivedReadSent()
                    }
                }
                break
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
            id: UInt16.random(in: 0...UInt16.max),
            sender: UserDefaults.standard.string(forKey: "Username")!,
            receiver: sender,
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
    
    
    func sendAckMessage(_ message: LocalMessage) {
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
