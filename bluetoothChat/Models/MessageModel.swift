//
//  MessageModel.swift
//  bluetoothChat
//
//  Created by Kasper Munch on 23/08/2021.
//

import Foundation

/// Message objects are the objects sent between devices.
///
/// We fill in the message struct and send it off formatted as JSON. 
struct Message: Codable, Identifiable {
    
    /**
     Some id which uniquely identifies the message.
     */
    var id: Int32
    
    /**
     Some type of message.
     0: A normal message
     1: An ACK message
     2: A READ message
     */
    var type: Int
    
    /**
     The author who wrote the message.
     */
    var sender: String
    
    /**
     Who the message is meant for
     */
    var receiver: String
    
    /**
     The actual content of the message.
     */
    var text: String
}
