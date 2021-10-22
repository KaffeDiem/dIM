//
//  MessageBubble.swift
//  bluetoothChat
//
//  Created by Kasper Munch on 22/10/2021.
//

import SwiftUI

struct MessageBubble: View {
    
    var username: String
    var message: MessageEntity
    
    var dateFormatter: DateFormatter
    
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
