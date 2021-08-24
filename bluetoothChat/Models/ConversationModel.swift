//
//  ConversationModel.swift
//  bluetoothChat
//
//  Created by Kasper Munch on 24/08/2021.
//

import Foundation

struct Conversation: Identifiable {
    var id: Int
    var author: String
    var lastMessage: Message
    var messages: [Message]
    
    mutating func addMessage(add message: Message) {
        messages.append(message)
    }
    
    mutating func updateLastMessage(new message: Message) {
        lastMessage = message
    }
}
