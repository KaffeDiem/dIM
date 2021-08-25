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
                Text(message.text)
                    
                .navigationTitle(author)
            }
            HStack {
                TextField("Aa", text: $message, onEditingChanged: {changed in
                    print("onEditingChanged: \(changed)")
                }, onCommit: {
                    bluetoothManager.sendData(message: message)
                })
                .padding()
                .textFieldStyle(RoundedBorderTextFieldStyle())
                
                Button(action: {
                    bluetoothManager.sendData(message: message)
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
