//
//  RetrieveMessage.swift
//  bluetoothChat
//
//  Created by Kasper Munch on 27/08/2021.
//

import Foundation
import UserNotifications


extension ChatBrain {

    /*
    Retrieve a message from sender and handle it appropriately.
     Function is only called if the message is properly decoded.
     
     This is also where we decided if the message was meant for us
     or not. For it to be added we have to have each other added
     as a contact. If the message is not for us then relay it and
     add it to the list of seen messages.
     */
    
    func retrieveMessage(_ messageEncrypted: Message) {
        
        /*
         Return if the message has been seen before.
         */
        for seenMessageID in seenMessages {
            if seenMessageID == messageEncrypted.id {
                return
            }
        }
        
        /*
         Add message to list of previously seen messages.
         */
        seenMessages.append(messageEncrypted.id)
        
        /*
         Determine if the message is for me
         */
        let defaults = UserDefaults.standard
        let username = defaults.string(forKey: "Username")
        
        let MessageForMe: Bool = messageEncrypted.receiver == username
        
        /*
         If the message is not for me then relay it.
         */
        guard MessageForMe else {
            relayMessage(messageEncrypted)
            return
        }
        
        /*
         Check if the sender of the message is added as one of your
         contacts. If sender is not a contact then drop the message.
         */
        if let contacts = defaults.stringArray(forKey: "Contacts") {
            
            let contactKnown = contacts.contains(messageEncrypted.sender)
            
            guard contactKnown else {
                print("Message for me - but contact has not been added.")
                return
            }
            
            /*
             The message is for us. Therefore we have to decrypt it for it to be
             readable.
             */
            let messageText = messageEncrypted.text
            
            let senderPublicKeyString = defaults.string(forKey: messageEncrypted.sender)
            let senderPublicKey = try! importPublicKey(senderPublicKeyString!)
            
            let privateKey = getPrivateKey()
            
            let symmetricKey = try! deriveSymmetricKey(privateKey: privateKey, publicKey: senderPublicKey)
            
            let decryptedText = decryptMessage(text: messageText, symmetricKey: symmetricKey)
            
            
            let messageDecrypted = Message(
                id: messageEncrypted.id,
                sender: messageEncrypted.sender,
                receiver: messageEncrypted.receiver,
                text: decryptedText
            )
            
            
            var conversationFound = false
            
            for (index, conv) in conversations.enumerated() {
                
                if conv.author == messageDecrypted.sender {
                    /*
                     If the message is for us and the contact has been added.
                     */
                    
                    conversationFound = true
                    
                    /*
                     Check if the message we received was an ACK message.
                     */
                    let ack = receivedAck(messageEncrypted)
                    
                    if !ack {
                        
                        conversations[index].addMessage(add: messageDecrypted)
                        conversations[index].updateLastMessage(new: messageDecrypted)
                        
                        sendAckMessage(messageDecrypted)
                    }
                    
                }
            }
            
            // If the conversation have not been found, create it.
            if !conversationFound {
                let ack = receivedAck(messageDecrypted)
                
                if !ack {
                    conversations.append(
                        Conversation(
                            id: messageDecrypted.id,
                            author: messageDecrypted.sender,
                            lastMessage: messageDecrypted,
                            messages: [messageDecrypted]
                        )
                    )
                    sendAckMessage(messageDecrypted)
                }
                
                
            }

            
            /*
             Send a notification if app is closed.
             */
            let content = UNMutableNotificationContent()
            content.title = messageDecrypted.sender
            content.body = messageDecrypted.text
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
        } else {
            print("Message received. No contacts.")
        }
    }
    
    
    /*
     The function which handles received ACK messages.
     */
    func receivedAck(_ message: Message) -> Bool {
        
        let components = message.text.components(separatedBy: "/")
        
        /*
         Check that the message is an ACK message.
         */
        guard components.first == "ACK" && components.count == 2 else {
            return false
        }
        
        /*
         Add the ACK message to the list of previously seen messages.
         */
        deliveredMessages.append(UInt16(components.last!)!)
        return true
    }
}
