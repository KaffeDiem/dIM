//
//  MessageBubble.swift
//  bluetoothChat
//
//  Created by Kasper Munch on 22/10/2021.
//

import SwiftUI

/// The beautiful bubbles messages are displayed in.
///
/// This view is used as a subview in `ChatView`.
struct MessageBubble: View {
    
    /// The username of the person who sent a message.
    var username: String
    /// The message which was sent or received.
    var message: MessageEntity
    
    var dateFormatter: DateFormatter
    
    /// Initialise a new chat bubble.
    ///
    /// Takes care of formatting the date to display it as `HH:mm`
    /// - Parameters:
    ///   - username: The username of the person who sent the message.
    ///   - message: The actual message which was sent.
    init(username: String, message: MessageEntity) {
        dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        
        self.username = username
        self.message = message
    }
    
    var body: some View {
        if username == message.sender! {
            Spacer()
        }
        
        Text(message.text ?? "Error: Message text was nil.")
            .padding(12)
            .foregroundColor(.white)
            .background(
                username == message.sender ? Color("dimOrangeLIGHT") : Color("setup-grayDARK")
            )
            .clipShape(Bubble(chat: username == message.sender!))
            .padding(.leading)
            
        if username != message.sender! {
            Text("\(dateFormatter.string(from: message.date!))")
                .font(.footnote)
                .foregroundColor(.gray)
        }
        
        if username != message.sender! {
            Spacer()
        }
    
        if username == message.sender! {
            MessageStatus(message: message)
                .foregroundColor(.accentColor)
                .padding(.trailing)
        }
    }
}
