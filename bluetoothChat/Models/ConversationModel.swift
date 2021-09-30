//
//  ConversationModel.swift
//  bluetoothChat
//
//  Created by Kasper Munch on 24/08/2021.
//

import Foundation

struct Conversation: Identifiable {
    var id: Int32
    var author: String
    var lastMessage: LocalMessage
    var messages: [LocalMessage]
    
    mutating func addMessage(add message: LocalMessage) {
        messages.append(message)
    }
    
    mutating func updateLastMessage(new message: LocalMessage) {
        lastMessage = message
    }
}
