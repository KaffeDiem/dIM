//
//  MessageStatusModel.swift
//  bluetoothChat
//
//  Created by Kasper Munch on 28/09/2021.
//

import Foundation

/**
 An enum used to represent the status of a message locally.
 This is used to keep track of of the status of local messages.
 */
enum Status: Int32 {
    case sent
    case delivered
    case read
    case received
    case receivedReadSent
    case unknown
    case failed
}
