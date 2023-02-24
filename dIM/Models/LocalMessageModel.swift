//
//  LocalMessageModel.swift
//  bluetoothChat
//
//  Created by Kasper Munch on 05/09/2021.
//

import Foundation

/// The model of a message meant to be stored on the device. Local messages
/// act just like regular messages but with more detailed information not
/// needed for the actually sent and received messages.
///
/// - Note: This model differs from the ``Message`` in that it also keeps a
/// status of the message. This status is also saved to CoreData.
///
/// - Note: The text is the decrypted text message.
///
/// An example of a message being created and its status changed.
/// ```swift
/// let message = LocalMessage(
///     id: Int,
///     sender: String,
///     receiver: String,
///     text: String,
///     date: Date,
///     status: Status
///     )
///
/// message.messageDelivered()
/// ```
struct LocalMessage: Identifiable, Hashable {
    /// Some id which uniquely identifies the message.
    var id: Int32
    
    /// The author who wrote the message.
    var sender: String
    
    /// Who the message is meant for
    var receiver: String
    
    /// The actual content of the message.
    var text: String
    
    /// The time of receival
    var date: Date
    
    /// The current status of the message.
    var status: MessageStatus = .sent
    
    /// Change message status to delivered
    mutating func messageDelivered() {
        status = .delivered
    }
    
    /// Change message status to read
    mutating func messageRead() {
        status = .read
    }
    
    /// Change message status to failed
    mutating func messageFailed() {
        status = .failed
    }
    
    /// Change message status to received-read-sent.
    mutating func messageReceivedReadSent() {
        status = .receivedReadSent
    }
}
