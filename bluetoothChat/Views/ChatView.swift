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


struct MessageStatus: View {
    let message: LocalMessage
    var body: some View {
        if message.status == .sent {
            Image(systemName: "arrow.up.arrow.down.circle")
        } else if message.status == .delivered {
            Image(systemName: "arrow.up.arrow.down.circle.fill")
        } else if message.status == .read {
            Image(systemName: "eye.circle.fill")
        } else if message.status == .failed {
            Image(systemName: "wifi.slash")
        }
    }
}


struct ChatView: View {
    
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var chatBrain: ChatBrain
    
    /*
     Sender is the person whose conversation we are looking at.
     */
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
                        HStack {
                            
                            /*
                             Place your messages on the right side of the screen.
                             */
                            if username == message.sender {
                                Spacer()
                            }
                            
                            VStack {
                                Text(message.text).padding(12)
                                    .foregroundColor(.white)
                                    .background(username == message.sender ? Color("dimOrangeLIGHT") : Color("setup-grayDARK"))
                                    
                            }
                            .clipShape(Bubble(chat: username == message.sender))
                            .padding(.leading)
                            
                            /*
                             Place receivers message on the left side of the screen.
                             */
                            if username != message.sender {
                                Spacer()
                            }
                            
                            if message.sender == username {
                                MessageStatus(message: message)
                                    .foregroundColor(.accentColor)
                                    .padding(.trailing)
                            }
                        }
                        .padding(EdgeInsets(top: 1, leading: 0, bottom: 1, trailing: 0))
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
        .onAppear() {
            /*
             Send READ acknowledgements messages if the user has enabled
             it in settings.
             */
            if UserDefaults.standard.bool(forKey: "settings.readmessages") {
                chatBrain.sendReadMessage(sender)
            }
        }
    }
}
