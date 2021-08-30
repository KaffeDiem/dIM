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
     as a contact.
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
        let defaults = UserDefaults.standard
        let username = defaults.string(forKey: "Username")
        
        let messageIsForMe: Bool = message.receiver == username
        guard messageIsForMe else { // If not for me, relay the message.
            relayMessage(message)
            return
        }
        
        /*
         If message is for me execute below code.
         */
        
        // Check if you have added the person as a contact.
        if let contacts = defaults.stringArray(forKey: "Contacts") {
            let contactKnown = contacts.contains(message.sender)
            
            guard contactKnown else {
                print("Message for me - but contact has not been added.")
                return
            }
            
            for (index, conv) in conversations.enumerated() {
                
                if conv.author == message.sender {
                    
                    conversations[index].addMessage(add: message)
                    conversations[index].updateLastMessage(new: message)
                }
            }
            
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
        } else {
            print("Message for me - but NO contacts have been added.")
        }
    }
}
