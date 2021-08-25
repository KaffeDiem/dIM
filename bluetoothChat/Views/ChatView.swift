//
//  ChatView.swift
//  bluetoothChat
//
//  Created by Kasper Munch on 23/08/2021.
//

import Foundation
import SwiftUI


struct ChatView: View {
    
    @EnvironmentObject var bluetoothManager: BluetoothManager
    var author: String
    
    @State var message: String = ""
        
    var body: some View {
        
        VStack {
            List (bluetoothManager.getConversation(author: author)) {message in
                VStack {
                    HStack {
                        Text(message.text)
                        Spacer()
                    }
                    HStack {
                        Text(message.author)
                            .font(.footnote)
                        Spacer()
                    }
                }
                    
                .navigationTitle(author)
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
