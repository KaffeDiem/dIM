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
    /// The users current colorscheme for pretty visuals.
    @Environment(\.colorScheme) var colorScheme
    /// The `appSession` object is used to send and receive messages.
    /// It handles the logic behind this view.
    @EnvironmentObject var appSession: AppSession
    
    /// The current conversation that the user is in. Used to get messages from conversation.
    @ObservedObject var conversation: ConversationEntity
    
    /// Fetched results of the messages for this conversation.
    @FetchRequest var messages: FetchedResults<MessageEntity>
    
    /// Temporary storage of the textfield entry.
    @State var message: String = ""
    
    @State var reportAlertIsShown = false
    
    /// Current username
    private let username: String
    
    private let title: String
    
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
        
        if let username = UsernameValidator.shared.userInfo?.asString {
            self.username = username
        } else {
            fatalError("Unexpectedly did not find any username while opening a chat view")
        }
        
        self.title = conversation.author?.components(separatedBy: "#").first ?? "Unknown"
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
                                if message.sender == username {
                                    Button(role: .none) {
                                        Task {
                                            await appSession.send(text: message.text ?? "", conversation: conversation)
                                        }
                                    } label: {
                                        Label("Resend", systemImage: "arrow.uturn.left.circle")
                                    }
                                }
                                // Delete button
                                Button(role: .destructive, action: {
                                    appSession.context.delete(message)
                                    do {
                                        try appSession.context.save()
                                    } catch {
                                        appSession.showErrorMessage(error.localizedDescription)
                                    }
                                }, label: {
                                    Label("Delete", systemImage: "minus.square")
                                })
                                // Report button
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
            .id(appSession.refreshID) // Refresh view when an ACK or READ message is received (minor hack)
            .removeFocusOnTap()
            
            // MARK: Send message
            HStack(spacing: 12) {
                DIMChatTextField(text: $message, placeholder: "Aa", characterLimitShown: true) { text in
                    send(message: message)
                }
                .padding([.leading, .bottom, .top])
                
                Button {
                    send(message: message)
                } label: {
                    Image(systemName: message.isEmpty ? "arrow.up.circle" : "arrow.up.circle.fill")
                        .animation(.spring(), value: message.isEmpty)
                        .imageScale(.large)
                }
                .padding(.trailing)
            }
        }
        .navigationTitle(title)
        
        .onAppear() {
            // Send READ messages if enabled in settings
            if UserDefaults.standard.bool(forKey: UserDefaultsKey.readMessages.rawValue) {
                Task {
                    await appSession.sendReadMessages(for: conversation)
                }
            }
        }
        .onDisappear() {
            if UserDefaults.standard.bool(forKey: UserDefaultsKey.readMessages.rawValue) {
                Task {
                    await appSession.sendReadMessages(for: conversation)
                }
            }
        }
    }
    
    private func send(message: String) {
        if message.count < 261 {
            self.message = ""
            Task {
                await appSession.send(text: message, conversation: conversation)
            }
        }
    }
}
