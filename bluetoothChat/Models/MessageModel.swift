//
//  MessageModel.swift
//  bluetoothChat
//
//  Created by Kasper Munch on 23/08/2021.
//

import Foundation

/*
 Message objects are the only things actually sent between devices.
 */
struct Message: Codable, Identifiable {
    
    /*
     Some id which uniquely identifies the message.
     */
    var id: Int
    
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
}
