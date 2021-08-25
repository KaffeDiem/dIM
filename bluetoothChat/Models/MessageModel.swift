//
//  MessageModel.swift
//  bluetoothChat
//
//  Created by Kasper Munch on 23/08/2021.
//

import Foundation

/*
 Messages are the only thing actually sent between devices.
*/
struct Message: Codable, Identifiable {
    var id: Int
    var text: String
    var author: String
}
