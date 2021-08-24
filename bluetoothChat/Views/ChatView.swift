//
//  ChatView.swift
//  bluetoothChat
//
//  Created by Kasper Munch on 23/08/2021.
//

import Foundation
import SwiftUI

struct ChatView: View {
    
    @ObservedObject var model = ChatModel()
    @EnvironmentObject var bluetoothManager: BluetoothManager
    
    var body: some View {
        GeometryReader { geo in
            VStack {
                //MARK:- ScrollView
                CustomScrollView(scrollToEnd: true) {
                    LazyVStack {
                        ForEach(0..<model.messages.count, id:\.self) { index in
                            ChatBubble(position: model.positions[index], color: model.positions[index] == BubblePosition.sent ?.green : .blue) {
                                Text(model.messages[index])
                            }
                        }
                    }
                }.padding(.top)
                //MARK:- text editor
                HStack {
                    ZStack {
                        TextEditor(text: $model.text)
                        RoundedRectangle(cornerRadius: 10)
                            .stroke()
                            .foregroundColor(.gray)
                    }.frame(height: 50)
                    
                    Button("send") {
                        if model.text != "" {
                            model.position = model.position == BubblePosition.received ? BubblePosition.sent : BubblePosition.received
                            model.positions.append(model.position)
                            model.messages.append(model.text)
                            model.text = ""
                        }
                    }
                }.padding()
                .navigationTitle("A chat window")
            }
        }
    }
}
