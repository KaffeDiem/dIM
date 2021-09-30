//
//  MessageStatus.swift
//  bluetoothChat
//
//  Created by Kasper Munch on 23/09/2021.
//

import SwiftUI

struct MessageStatus: View {
    let message: MessageEntity
    
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
