//
//  LocalMessageModel.swift
//  bluetoothChat
//
//  Created by Kasper Munch on 05/09/2021.
//

import Foundation



/**
 Local messages are messages meant to be stored on device.
 
 Local messages act just like a regular message but with more detailed information.
 This is done to limit the size of the message sent between
 devices while upholding information in a single struct on the
 receiving device.
 
 See MessageModel.swift
 */
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
    var status: Status = .sent
    
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
