//
//  SendMessage.swift
//  bluetoothChat
//
//  Created by Kasper Munch on 27/08/2021.
//

import Foundation

extension ChatBrain {
    
    func sendMessage(for receiver: String, text message: String) {
        /*
         Send a string to all connected devices.
         */
        guard message != "" else { return }
        
        let username = UserDefaults.standard.string(forKey: "Username")!
        
        let message = Message(
            id: Int.random(in: 0...10000),
            sender: username,
            receiver: receiver,
            text: message
        )
        
        if let characteristic = self.characteristic {
    
            seenMessages.append(message.id)
            
            do {
                let messageEncoded = try JSONEncoder().encode(message)
                
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
}
