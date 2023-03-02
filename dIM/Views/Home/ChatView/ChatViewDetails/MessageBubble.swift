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
        if username == message.sender {
            Spacer()
        }
        
        Text(message.text ?? "Error: Message text was nil.")
            .padding(12)
            .foregroundColor(.white)
            .background(
                username == message.sender ? Asset.dimOrangeLight.swiftUIColor : Asset.greyDark.swiftUIColor
            )
            .clipShape(Bubble(chat: username == message.sender))
            .padding(.leading)
            
        if username != message.sender {
            if let messageDate = message.date {
                Text("\(dateFormatter.string(from: messageDate))")
                    .font(.footnote)
                    .foregroundColor(.gray)
            }
        }
        
        if username != message.sender {
            Spacer()
        }
    
        if username == message.sender {
            MessageStatusChatIcon(status: .init(rawValue: message.status) ?? .unknown)
                .foregroundColor(.accentColor)
                .padding(.trailing)
        }
    }
}

/// A simple shape of a bubbble.
fileprivate struct Bubble: Shape {
    /// A boolean confirming that the message is sent by us or not.
    var chat: Bool
    /// Drawing of the actual path.
    /// - Parameter rect: The rectangle size to draw.
    /// - Returns: A path which is used for drawing.
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: [.topRight, .topLeft, chat ? .bottomLeft : .bottomRight], cornerRadii: CGSize(width: 20, height: 20))
        return Path(path.cgPath)
    }
}
