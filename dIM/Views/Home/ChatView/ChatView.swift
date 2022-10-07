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
    
    /// A boolean for showing the report alert or not. Showed if we press
    /// the report button after a longpress on a message.
    @State var showingReportAlert = false
    
    /// Our username for comparisons to the username of the conversation.
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
                                        chatHandler.sendMessage(for: conversation, text: message.text!, context: context)
                                    }, label: {
                                        Label("Resend", systemImage: "arrow.uturn.left.circle")
                                    })
                                    }
                                /* Delete button*/
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
            .id(chatHandler.refreshID) // Force a refresh when an ACK message is received
            
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
            if UserDefaults.standard.bool(forKey: "settings.readmessages") {
                chatHandler.sendReadMessage(conversation)
            }
        }
        .onDisappear() {
            if UserDefaults.standard.bool(forKey: "settings.readmessages") {
                chatHandler.sendReadMessage(conversation)
            }
        }
    }
}


/// A simple shape of a bubbble.
struct Bubble: Shape {
    /// A boolean confirming that the message is sent by us or not.
    var chat: Bool
    /// Drawing of the actual path.
    /// - Parameter rect: The rectangle size to draw.
    /// - Returns: A path which is used for drawing.
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: [.topRight, .topLeft, chat ? .bottomLeft : .bottomRight], cornerRadii: CGSize(width: 20, height: 20))
        return Path(path.cgPath)
    }
}
