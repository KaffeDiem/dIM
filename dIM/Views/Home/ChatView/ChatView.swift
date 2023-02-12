//
//  ChatView.swift
//  bluetoothChat
//
//  Created by Kasper Munch on 23/08/2021.
//
import MobileCoreServices
import Foundation
import SwiftUI


/// The `ChatView` displays a conversation and all the messages that have been sent and
/// received in said conversation.
///
/// It is also here that we send new messages.
struct ChatView: View {
    
    /// The `CoreData` object context to which we save messages to persistent storage.
    @Environment(\.managedObjectContext) var context
    /// The users current colorscheme for pretty visuals.
    @Environment(\.colorScheme) var colorScheme
    /// The `chatHandler` object is used to send and receive messages.
    /// It handles the logic behind this view.
    @EnvironmentObject var chatHandler: ChatHandler
    
    /// The current conversation that the user is in. Used to get messages from conversation.
    @ObservedObject var conversation: ConversationEntity
    
    /// Fetched results of the messages for this conversation.
    @FetchRequest var messages: FetchedResults<MessageEntity>
    
    /// Temporary storage of the textfield entry.
    @State var message: String = ""
    
    @State var reportAlertIsShown = false
    
    /// Current username
    private let username: String
        
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
        
        let usernameValidator = UsernameValidator()
        if let username = usernameValidator.userInfo?.asString {
            self.username = username
        } else {
            fatalError("Unexpectedly did not find any username while opening a chat view")
        }
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
                                // Copy to clipboard
                                Button(role: .none) {
                                    UIPasteboard.general.setValue(
                                        message.text ?? "Something went wrong copying from dIM",
                                        forPasteboardType: "public.plain-text")
                                } label: {
                                    Label("Copy", systemImage: "doc.on.doc")
                                }
                                // Resend a message which has not been delivered
                                if message.sender! == username {
                                    Button(role: .none) {
                                        chatHandler.sendMessage(for: conversation, text: message.text!, context: context)
                                    } label: {
                                        Label("Resend", systemImage: "arrow.uturn.left.circle")
                                    }
                                }
                                // Delete button
                                Button(role: .destructive, action: {
                                    context.delete(message)
                                    do {
                                        try context.save()
                                    } catch {
                                        print("Error: Saving the context after deleting a message went wrong.")
                                    }
                                }, label: {
                                    Label("Delete", systemImage: "minus.square")
                                })
                                /* Report button */
                                Button(role: .destructive, action: {
                                    reportAlertIsShown = true
                                }, label: {
                                    Label("Report", systemImage: "exclamationmark.bubble")
                                })
                            }
                            .alert("Report Message", isPresented: $reportAlertIsShown) {
                                Button("OK", role: .cancel) {}
                            } message: {
                                Text("dIM stores all data on yours and the senders device. Therefore you should block the user who has sent this message to you if you deem it inappropriate.\nIllegal content should be reported to the authorities.")
                            }
                        }
                    }
                }
                .onAppear {
                    // Scroll to bottom on appear
                    if messages.count > 0 {
                        proxy.scrollTo(messages[messages.endIndex-1])
                    }
                }
            }
            // Minor hack to refresh view when ACK / READ message is received
            .id(chatHandler.refreshID)
            
            // MARK: Send message
            HStack {
                TextField("Aa", text: $message)
                .padding()
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .submitLabel(.send)
                .onSubmit({
                    if message.count < 261 {
                        chatHandler.sendMessage(for: conversation, text: message, context: context)
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
                        chatHandler.sendMessage(for: conversation, text: message, context: context)
                        message = ""
                    }
                }, label: {
                    Image(systemName: "paperplane.circle.fill")
                        .padding(.trailing)
                })
            }
        }
        .navigationTitle((conversation.author!.components(separatedBy: "#")).first ?? "Unknown")
    
        .onAppear() {
            /*
             Send READ acknowledgements messages if the user has enabled
             it in settings.
             */
            if UserDefaults.standard.bool(forKey: UserDefaultsKey.readMessages.rawValue) {
                chatHandler.sendReadMessage(conversation)
            }
        }
        .onDisappear() {
            if UserDefaults.standard.bool(forKey: UserDefaultsKey.readMessages.rawValue) {
                chatHandler.sendReadMessage(conversation)
            }
        }
    }
}
