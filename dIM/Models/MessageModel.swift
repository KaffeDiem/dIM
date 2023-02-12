//
//  MessageModel.swift
//  bluetoothChat
//
//  Created by Kasper Munch on 23/08/2021.
//

import Foundation

/// Type of object sent between devices
struct Message: Codable, Identifiable {
    enum Kind: Int, Codable {
        /// Regular message
        case regular = 0
        /// Acknowledge that the message has been received. This is sent back to the sender
        /// of a message if the message was successfully delivered and decrypted.
        case acknowledgement = 1
        /// Read message kind which allows users to know that their sent message has been read.
        /// This is only used if the feature has been enabled in settings.
        case read = 2
    }
    
    var id: Int32
    var kind: Kind
    var sender: String
    var receiver: String
    var text: String // Note that text in the message struct is encrypted
}
