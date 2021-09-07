//
//  LocalMessageModel.swift
//  bluetoothChat
//
//  Created by Kasper Munch on 05/09/2021.
//

import Foundation

enum Status {
    case sent
    case delivered
    case read
    case received
    case receivedReadSent
    case failed
}

/*
 Local messages are messages meant to be stored on device.
 They act just like a regular message but with more detailed information.
 This is done to limit the size of the message sent between
 devices while upholding information in a single struct on the
 receiving device.
 
 See MessageModel.swift
 */
struct LocalMessage: Identifiable {
    /*
     Some id which uniquely identifies the message.
     */
    var id: UInt16
    
    /*
     The author who wrote the message.
     */
    var sender: String
    
    /*
     Who the message is meant for
     */
    var receiver: String
    
    /*
     The actual content of the message.
     */
    var text: String
    
    /*
     The current status of the message.
     */
    var status: Status = .sent
    
    /*
     Below functions are used to change the current status
     of a message.
     */
    mutating func messageDelivered() {
        status = .delivered
    }
    
    mutating func messageRead() {
        status = .read
    }
    
    mutating func messageFailed() {
        status = .failed
    }
    
    mutating func messageReceivedReadSent() {
        status = .receivedReadSent
    }
}
