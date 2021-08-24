//
//  ChatModel.swift
//  bluetoothChat
//
//  Created by Kasper Munch on 23/08/2021.
//

import Foundation
import SwiftUI

// A simple enum which decided if we have sent or received
// the message.
enum BubblePosition {
    case received
    case sent
}

// The ChatModel handles the array of messages sent and received.
class ChatModel: ObservableObject {
    var text: String = ""
    @Published var messages: [String] = []
    @Published var positions: [BubblePosition] = []
    @Published var position: BubblePosition = BubblePosition.sent
}

// Holds all the infor
struct ChatBubble<Content>: View where Content: View {
    let position: BubblePosition
    let color : Color
    let content: () -> Content
    
    init(position: BubblePosition, color: Color, @ViewBuilder content: @escaping () -> Content) {
        self.content = content
        self.color = color
        self.position = position
    }
    
    var body: some View {
        HStack(spacing: 0 ) {
            content()
                .padding(.all, 15)
                .foregroundColor(Color.white)
                .background(color)
                .clipShape(RoundedRectangle(cornerRadius: 18))
                .overlay(
                    Image(systemName: "arrowtriangle.left.fill")
                        .foregroundColor(color)
                        .rotationEffect(Angle(degrees: position == .received ? -50 : -130))
                        .offset(x: position == .received ? -5 : 5)
                    ,alignment: position == .received ? .bottomLeading : .bottomTrailing)
        }
        .padding(position == .received ? .leading : .trailing , 15)
        .padding(position == .sent ? .leading : .trailing , 60)
        .frame(width: UIScreen.main.bounds.width, alignment: position == .received ? .leading : .trailing)
    }
}
