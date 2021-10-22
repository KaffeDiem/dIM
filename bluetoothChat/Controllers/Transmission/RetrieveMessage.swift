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
        
        // MARK: Check for concatted bits to check type of message.
        
        /*
         Check if the message has been seen before
         */
        guard !seenMessages.contains(messageEncrypted.id) else { return }
        
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
                localMessage.receiver = username
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
                self.sendAckMessage(localMessage)
                
                self.sendNotification(what: localMessage)
                
                try? self.context.save()
            } catch let error as NSError {
                print("Error fetching conversations from CoreData: \(error)")
            }
        }
    }
    
    
    func receivedRead(message: Message, conversation: ConversationEntity) -> Bool {
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
        
        try? context.save()
        
        return true
    }
    
    
    /*
     Handle received ACK messages.
     */
    func receivedAck(message: Message, conversation: ConversationEntity) -> Bool {
        
        let components = message.text.components(separatedBy: "/")
        
        /*
         Check that the message is an ACK message.
         */
        guard components.first == "ACK" && components.count == 2 else {
            return false
        }
        
        let messages = conversation.messages?.allObjects as! [MessageEntity]
        
        for message in messages {
            if message.id == Int(components[1])! {
                message.status = Status.delivered.rawValue
            }
        }
        
        try? context.save()
        
        return true
    }
    
    
    // MARK: Helper functions
    
    /*
     Given a message and a conversation, decrypt the text and send it back.
     */
    func decryptRetrievedMessageToString(message: Message, conversation: ConversationEntity) -> String? {
        
        let senderPublicKey = try! importPublicKey(conversation.publicKey!)
        let symmetricKey = try! deriveSymmetricKey(privateKey: getPrivateKey(), publicKey: senderPublicKey)
        
        return decryptMessage(text: message.text, symmetricKey: symmetricKey)
    }
    
    /*
     Send a notification if app is closed.
     */
    func sendNotification(what message: MessageEntity) {
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
