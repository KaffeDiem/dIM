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
     or not.
     */
    
    func retrieveMessage(_ message: Message) {
        
        /*
         Check if we have seen this message before.
         */
        for seenMessageID in seenMessages {
            if seenMessageID == message.id {
                print("Message seen before.")
                return
            }
        }
        
        seenMessages.append(message.id)
        
        /*
         Determine if the message is for me
         */
        let username = UserDefaults.standard.string(forKey: "Username")
        
        let messageIsForMe: Bool = message.receiver == username
        guard messageIsForMe else {
            relayMessage(message)
            return
        }
        
        /*
         If message is for me execute below code.
         */
        var senderIsAdded = false
        
        for (index, conv) in conversations.enumerated() {
            
            if conv.author == message.sender {
                
                senderIsAdded = true
                
                conversations[index].addMessage(add: message)
                conversations[index].updateLastMessage(new: message)
            }
        }
        
        if !senderIsAdded {
            conversations.append(
                Conversation(
                    id: message.id,
                    author: message.sender,
                    lastMessage: message,
                    messages: [message]
                )
            )
        }
        
        /*
         Send a response to the sender that the message has been received.
         */
        
        
        /*
         Send a notification if app is closed.
         */
        let content = UNMutableNotificationContent()
        content.title = message.sender
        content.body = message.text
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
