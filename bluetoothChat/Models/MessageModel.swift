//
//  MessageModel.swift
//  bluetoothChat
//
//  Created by Kasper Munch on 23/08/2021.
//

import Foundation

struct Message: Codable, Identifiable {
    var id: Int
    var text: String
    var author: String
}
