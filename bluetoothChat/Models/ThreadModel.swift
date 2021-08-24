//
//  ThreadModel.swift
//  bluetoothChat
//
//  Created by Kasper Munch on 23/08/2021.
//

import Foundation

struct Thread {
    var id: Int
    var author: String
    var lastMessage: String
    var messages: [Message]
    
    mutating func addMessage(message: Message) {
        messages.append(message)
    }
}
