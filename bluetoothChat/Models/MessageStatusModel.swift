//
//  MessageStatusModel.swift
//  bluetoothChat
//
//  Created by Kasper Munch on 28/09/2021.
//

import Foundation

/*
 An enum which holds the status of each message.
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
