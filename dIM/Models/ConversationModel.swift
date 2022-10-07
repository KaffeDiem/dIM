//
//  ConversationModel.swift
//  bluetoothChat
//
//  Created by Kasper Munch on 24/08/2021.
//

import Foundation

/// A conversation is a thread of messages with some user that you have added.
///
/// Conversations have an unique id and holds all the messages in that conversation.
/// This includes the messages that you have sent as well.
struct Conversation: Identifiable {
    /// An unique identifier for the conversation
    var id: Int32
    /// The author - or the username of the person who is not you.
    var author: String
    /// The last message sent in the conversation. This includes yours and the authors last message.
    var lastMessage: LocalMessage
    /// A list of all messages sent in the conversation.
    var messages: [LocalMessage]
    
    /// Add a message to the end of a conversation thread.
    /// - Parameter message: The message to append to the array of messages.
    mutating func addMessage(add message: LocalMessage) {
        messages.append(message)
    }
    
    /// Update the last message in the thread.
    ///
    /// This is the message shown on the `ContentView`.
    /// - Parameter message: The message to set last message to.
    mutating func updateLastMessage(new message: LocalMessage) {
        lastMessage = message
    }
}
