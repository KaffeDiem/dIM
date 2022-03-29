//
//  GroupChatView.swift
//  bluetoothChat
//
//  Created by Kasper Munch on 29/03/2022.
//

import SwiftUI

struct GroupChatView: View {
    
    /// Fetched results of the messages for this conversation.
    @FetchRequest var messages: FetchedResults<MessageEntity>
    
    let group: GroupEntity
    
    @State var showingReportAlert = false
    let username: String = UserDefaults.standard.string(forKey: "Username")!
    @State var message: String = ""
    
    init(group: GroupEntity) {
        self.group = group
//        self.viewModel = ChatViewModel(forConversation: conversation)
        
        _messages = FetchRequest<MessageEntity>(
            entity: MessageEntity.entity(),
            sortDescriptors: [
                NSSortDescriptor(keyPath: \MessageEntity.date, ascending: true)
            ],
            predicate: NSPredicate(format: "inGroup == %@", group),
            animation: nil
        )
    }
    
    var body: some View {
        VStack {
            ScrollViewReader { proxy in
                ScrollView(.vertical) {
                    LazyVStack {
                        ForEach(messages, id: \.self) { message in
                            HStack {
                                
                                MessageBubble(username: username, message: message)
                                
                            }
                            .padding(EdgeInsets(top: 1, leading: 0, bottom: 1, trailing: 0))
                            .contextMenu {
                                /* Copy button */
                                Button(role: .none, action: {
                                    UIPasteboard.general.setValue(message.text ?? "Something went wrong copying from dIM",
                                                                  forPasteboardType: "public.plain-text")
                                }, label: {
                                    Label("Copy", systemImage: "doc.on.doc")
                                })
                                /* Resend button (for users own messages) */
                                if message.sender! == username {
                                    Button(role: .none, action: {
                                        print("Send group message")
//                                        Session.chatHandler.sendMessage(for: conversation, text: message.text!, context: context)
                                    }, label: {
                                        Label("Resend", systemImage: "arrow.uturn.left.circle")
                                    })
                                    }
                                /* Delete button*/
                                Button(role: .destructive, action: {
                                    Session.context.delete(message)
                                    do {
                                        try Session.context.save()
                                    } catch {
                                        print("Error: Saving the context after deleting a message went wrong.")
                                    }
                                }, label: {
                                    Label("Delete", systemImage: "minus.square")
                                })
                                /* Report button */
                                Button(role: .destructive, action: {
                                    showingReportAlert = true
                                    print("Alert should be shown")
                                }, label: {
                                    Label("Report", systemImage: "exclamationmark.bubble")
                                })
                            }
                            .alert("Report Message", isPresented: $showingReportAlert) {
                                Button("OK", role: .cancel) {}
                            } message: {
                                Text("dIM stores all data on yours and the senders device. Therefore you should block the user who has sent this message to you if you deem it inappropriate.\nIllegal content should be reported to the authorities.")
                            }
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
            .id(Session.chatHandler.refreshID) // Force a refresh when an ACK message is received
            
            /*
             Send message part
             */
            HStack {
                TextField("Aa", text: $message)
                .padding()
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .submitLabel(.send)
                .onSubmit({
                    if message.count < 261 {
                        print("Send a group message")
//                        Session.chatHandler.sendMessage(for: conversation, text: message, context: context)
                        message = ""
                    }
                })

                if message.count > 260 {
                    Text("\(message.count)/260")
                        .padding(.trailing)
                        .foregroundColor(.red)
                } else {
                    Text("\(message.count)/260")
                        .padding(.trailing)
                }
                
                Button(action: {
                    if message.count < 261 {
                        print("Send a group message")
//                        Session.chatHandler.sendMessage(for: conversation, text: message, context: context)
                        message = ""
                    }
                }, label: {
                    Image(systemName: "paperplane.circle.fill")
                        .padding(.trailing)
                })
            }
        }
        .navigationTitle(group.name ?? "Unknown")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink {
                } label: {
                    Text("Invite")
                    Image(systemName: "qrcode")
                }

            }
        }
    
        .onAppear() {
//            viewModel.onAppear()
        }
        .onDisappear() {
//            viewModel.onDissapear()
        }
    }
}
