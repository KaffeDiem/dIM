//
//  MessageStatus.swift
//  bluetoothChat
//
//  Created by Kasper Munch on 23/09/2021.
//

import SwiftUI

/// The small status image of a message. An eye for example means that the
/// receiver of the message has seen it.
struct MessageStatus: View {
    /// The message entity to add a status image to.
    let message: MessageEntity
    
    /// Get the `enum` status type of a message.
    ///
    /// This is done by convertung the raw value of a `message.status` to a
    /// `Status` type.
    /// - Parameter message: The message to get the status from.
    /// - Returns: The actual status of the message. `Status.unknown` if it fails.
    func messageStatusEnum(message: MessageEntity) -> Status {
        return Status(rawValue: message.status) ?? Status.unknown
    }
    
    var body: some View {
        if messageStatusEnum(message: message) == .sent {
            Image(systemName: "arrow.up.arrow.down.circle")
        } else if messageStatusEnum(message: message) == .delivered {
            Image(systemName: "arrow.up.arrow.down.circle.fill")
        } else if messageStatusEnum(message: message) == .read {
            Image(systemName: "eye.circle.fill")
        } else if messageStatusEnum(message: message) == .failed {
            Image(systemName: "wifi.slash")
        } else {
            Image(systemName: "exclamationmark.bubble.fill")
        }
    }
}
