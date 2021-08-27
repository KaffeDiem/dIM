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
    
    @EnvironmentObject var bluetoothManager: ChatBrain
    var author: String
    
    @State var message: String = ""
    let username: String = UserDefaults.standard.string(forKey: "Username")!
        
    var body: some View {
        
        VStack {
            ScrollView {
                LazyVStack {
                    ForEach(bluetoothManager.getConversation(author: author)) {message in
                        VStack {
                            HStack {
                                if username == message.author {
                                    Spacer()
                                }
                                Text(message.text).padding(12)
                                    .foregroundColor(.white)
                                    .background(username == message.author ? Color("dimOrangeLIGHT") : Color(.gray) )
                                    .clipShape(Bubble(chat: username == message.author))
                                if username != message.author {
                                    Spacer()
                                }
                            }
                        }
                        .clipShape(Bubble(chat: username == message.author))
                        .padding(.leading)
                        .padding(.trailing)
                    }
                        .navigationTitle(author)
                }
            }
            HStack {
                TextField("Aa", text: $message, onEditingChanged: {changed in
                    // Should anything go here?
                }, onCommit: {
                    bluetoothManager.addMessage(receipent: author, messageText: message)
                    bluetoothManager.sendData(message: message)
                    UIApplication.shared.endEditing()
                    message = ""
                })
                .padding()
                .textFieldStyle(RoundedBorderTextFieldStyle())
                
                Button(action: {
                    bluetoothManager.addMessage(receipent: author, messageText: message)
                    bluetoothManager.sendData(message: message)
                    UIApplication.shared.endEditing()
                    message = ""
                }) {
                    Image(systemName: "chevron.forward.circle.fill")
                }
                .padding(.bottom)
                .padding(.trailing)
                .padding(.top)
                .scaleEffect(1.8)
            }
        }
    }
}
