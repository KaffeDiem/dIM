//
//  ChatView.swift
//  bluetoothChat
//
//  Created by Kasper Munch on 23/08/2021.
//

import Foundation
import SwiftUI


struct Bubble: Shape {
    var chat: Bool
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: [.topRight, .topLeft, chat ? .bottomLeft : .bottomRight], cornerRadii: CGSize(width: 20, height: 20))
        return Path(path.cgPath)
    }
}

struct ChatView: View {
    
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var chatBrain: ChatBrain
    var sender: String
    
    @State var message: String = ""
    let username: String = UserDefaults.standard.string(forKey: "Username")!
        
    var body: some View {
        
        VStack {
            
            /*
             Listing all chat messages.
             */
            
            ScrollView {
                LazyVStack {
                    ForEach(chatBrain.getConversation(sender: sender)) {message in
                        VStack {
                            HStack {
                                if username == message.sender {
                                    Spacer()
                                }
                                Text(message.text).padding(12)
                                    .foregroundColor(.white)
                                    .background(username == message.sender ? Color("dimOrangeLIGHT") : Color("setup-grayDARK"))
                                    .clipShape(Bubble(chat: username == message.sender))
                                if username != message.sender {
                                    Spacer()
                                }
                            }
                        }
                        .clipShape(Bubble(chat: username == message.sender))
                        .padding(.leading)
                        .padding(.trailing)
                    }
                        
                }
            }
            
            /*
             Send message part
             */
            
            HStack {
                TextField("Aa", text: $message, onEditingChanged: {changed in
                    // Should anything go here?
                }, onCommit: {
                    
                    chatBrain.sendMessage(for: sender, text: message)
                    
                    message = ""
                })
                .padding()
                .textFieldStyle(RoundedBorderTextFieldStyle())
                
                Button(action: {
                    
                    chatBrain.sendMessage(for: sender, text: message)
                    
                    message = ""
                }) {
                    Image(systemName: "chevron.forward.circle.fill")
                }
                .padding(.bottom)
                .padding(.trailing)
                .padding(.top)
                .scaleEffect(1.8)
            }
            
            .navigationTitle(sender)
        }
    }
}
