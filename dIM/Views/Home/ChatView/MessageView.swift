//
//  MessageView.swift
//  dIM
//
//  Created by Kasper Munch on 20/04/2023.
//

import Foundation
import SwiftUI
import DataController

struct MessageView: View {
    let username: String
    let message: MessageEntity
    
    var body: some View {
        switch Message.Kind(fromString: message.kind ?? "") {
        case .regular:
            MessageBubble(username: username, message: message)
        case .gps:
            Text("GPS")
        default:
            MessageBubble(username: username, message: message)
        }
    }
}
