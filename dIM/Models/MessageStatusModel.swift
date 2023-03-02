//
//  MessageStatusModel.swift
//  bluetoothChat
//
//  Created by Kasper Munch on 28/09/2021.
//

import Foundation

/// Status of a message
enum MessageStatus: Int32 {
    case sent
    case delivered
    case read
    case received
    case receivedReadSent
    case unknown
    case failed
}
