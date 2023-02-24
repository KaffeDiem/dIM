//
//  MessageStatus.swift
//  bluetoothChat
//
//  Created by Kasper Munch on 23/09/2021.
//

import SwiftUI

/// Status of a message as seen in the ``ChatView``
struct MessageStatusChatIcon: View {
    let status: MessageStatus
    
    var body: some View {
        switch status {
        case .sent:
            Image(systemName: "arrow.up.arrow.down.circle")
        case .delivered:
            Image(systemName: "arrow.up.arrow.down.circle.fill")
        case .read:
            Image(systemName: "eye.circle.fill")
        case .failed:
            Image(systemName: "wifi.slash")
        default:
            Image(systemName: "exclamationmark.bubble.fill")
        }
    }
}
