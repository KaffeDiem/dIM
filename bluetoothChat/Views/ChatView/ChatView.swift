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
    
    @Environment(\.managedObjectContext) var context
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var chatBrain: ChatBrain
    
    /*
     The current conversation that the user is in.
     */
    var conversation: ConversationEntity
    
    /*
     Fetch requests belonging to this conversation from the database.
     */
    @FetchRequest var messages: FetchedResults<MessageEntity>
    
    /*
     Used for temporary storage when typing in text fields.
     */
    @State var tempTextField: String = ""
    @State var message: String = ""
    
    let username: String = UserDefaults.standard.string(forKey: "Username")!
        
    init(conversation: ConversationEntity) {
        self.conversation = conversation
        
        _messages = FetchRequest<MessageEntity>(
            entity: MessageEntity.entity(),
            sortDescriptors: [
                NSSortDescriptor(keyPath: \MessageEntity.date, ascending: true)
            ],
            predicate: NSPredicate(format: "inConversation == %@", conversation),
            animation: nil
        )
    }
    
    var body: some View {
        
        VStack {
            ScrollViewReader { proxy in
                ScrollView(.vertical) {
                    LazyVStack {
                        ForEach(messages, id: \.id) { message in
                            HStack {
                                if username == message.sender! {
                                    Spacer()
                                }
                                
                                VStack {
                                    Text(message.text ?? "Error: Message text was nil.")
                                        .padding(12)
                                        .foregroundColor(.white)
                                        .background(
                                            username == message.sender ? Color("dimOrangeLIGHT") : Color("setup-grayDARK")
                                        )
                                        .clipShape(Bubble(chat: username == message.sender!))
                                        .padding(.leading)
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
                            .padding(EdgeInsets(top: 1, leading: 0, bottom: 1, trailing: 0))
                        }
                    }
                    
                }
                .onAppear {
                    /*
                     Scroll to bottom of chat list automatically when view is loaded.
                     */
                    if messages.count > 0 {
                        proxy.scrollTo(messages[messages.endIndex-1])
                    }
                }
            }
            
            
            /*
             Send message part
             */
            HStack {
                TextField("Aa", text: $message, onEditingChanged: {changed in
                    
                }, onCommit: {

                    if message.count < 261 {
                        chatBrain.sendMessage(for: conversation, text: message, context: context)
                    }

                    message = ""
                })
                .padding()
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .submitLabel(.send)

                if message.count > 260 {
                    Text("\(message.count)/260")
                        .padding(.trailing)
                        .foregroundColor(.red)
                } else {
                    Text("\(message.count)/260")
                        .padding(.trailing)
                }
            }
        }
        .navigationTitle((conversation.author!.components(separatedBy: "#")).first ?? "Unknown")
    
        .onAppear() {
            /*
             Send READ acknowledgements messages if the user has enabled
             it in settings.
             */
            if UserDefaults.standard.bool(forKey: "settings.readmessages") {
                chatBrain.sendReadMessage(conversation)
            }
        }
        .onDisappear() {
            if UserDefaults.standard.bool(forKey: "settings.readmessages") {
                chatBrain.sendReadMessage(conversation)
            }
        }
    }
}
