//
//  HomeView.swift
//  bluetoothChat
//
//  Created by Kasper Munch on 23/08/2021.
//

import CoreData
import SwiftUI

/// The `HomeView` where users are presented with the different conversations that they are in.
/// It is also here that we redirect them to other pages, let it be the `ChatView` or the `SettingsView`.
struct HomeView: View {
    
    /// Initialize the ChatBrain which handles logic of Bluetooth
    /// and sending / receiving messages.
    @StateObject var chatHandler: ChatHandler
    
    /// Get conversations saved to Core Data and sort them by date last updated.
    @FetchRequest(
        entity: ConversationEntity.entity(),
        sortDescriptors: [
            NSSortDescriptor(keyPath: \ConversationEntity.date, ascending: false)
        ]
    ) var conversations: FetchedResults<ConversationEntity>
    
    /// Used for confirmation dialog when deleting a contact.
    @State private var confirmationShown: Bool = false
    
    /// Keep track of the active card in the carousel view.
    @StateObject private var UIStateCarousel = UIStateModel()
    
    /// Body and content of the HomeView.
    var body: some View {
        
        VStack {
            if !conversationsIsEmpty() {
                /*
                 List all added users and their conversations.
                 */
                List(conversations) { conversation in
                    NavigationLink(
                        destination: ChatView(conversation: conversation)
                            .environmentObject(chatHandler),
                        label: {
                            VStack {
                                Text(getSafeAuthor(conversation: conversation))
                                    .foregroundColor(.accentColor)
                                    .frame(maxWidth: .infinity, alignment: .leading)

                                Text(conversation.lastMessage ?? "Start a new conversation.")
                                    .scaledToFit()
                                    .font(.footnote)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            .padding()
                        })
                    /*
                     Swipe Actions are activated when swiping left on the conversation thread.
                     */
                        .swipeActions {
                            // Clearing a conversation.
                            Button {
                                conversation.removeFromMessages(conversation.messages!)
                                conversation.lastMessage = "Start a new conversation."
                                do {
                                    try Session.context.save()
                                } catch {
                                    print("Context could not be saved.")
                                }
                            } label: {
                                Label("Clear Conversation", systemImage: "exclamationmark.bubble.fill")
                            }
                            .tint(.accentColor)
                            // Deleting a contact.
                            Button(role: .destructive, action: {confirmationShown = true}) {
                                Label("Delete Contact", systemImage: "person.fill.xmark")
                            }
                        }
                        .confirmationDialog(
                            "Are you sure?",
                            isPresented: $confirmationShown
                        ) {
                            Button("Delete Contact", role: .destructive) {
                                withAnimation {
                                    Session.context.delete(conversation)
                                    do {
                                        try Session.context.save()
                                    } catch {
                                        print("Context could not be saved.")
                                    }
                                }
                            }
                        }
                }
            } else {
                SnapCarousel()
                    .environmentObject(UIStateCarousel)
            }
        }
        /*
         Toolbar in the navigation header for SettingsView and ChatView.
         */
        .toolbar {
            ToolbarItem(placement: .principal) {
                VStack {
                    Text("Chats")
                        .font(.headline)
                    if chatHandler.discoveredDevices.count < 1 {
                        HStack {
                            Image(systemName: "antenna.radiowaves.left.and.right.slash")
                                .symbolRenderingMode(.palette)
                                .foregroundStyle(.red, .orange, .white)
                            Text("Not connected")
                                .foregroundColor(.accentColor)
                                .font(.subheadline)
                        }
                    } else {
                        HStack {
                            Image(systemName: "antenna.radiowaves.left.and.right")
                            Text("\(chatHandler.discoveredDevices.count) in range").font(.subheadline)
                        }
                    }
                }
            }
            ToolbarItem(placement: .navigationBarLeading) {
                NavigationLink(destination: SettingsView().environmentObject(chatHandler), label: {
                    Image(systemName: "gearshape.fill")
                })
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink(destination: QRView().environmentObject(chatHandler), label: {
                    Image(systemName: "qrcode")
                })
            }
        }
    }
    
    /// As usernames gets a random 4 digit number added to them, which we do not want
    /// to present, we use this function to only get the actual username of the user.
    ///
    /// If it fails for some reason (most likely wrong formatting) we simply show
    /// "Unknown".
    /// - Parameter conversation: The conversation for which we want to get the username.
    /// - Returns: A string with only the username, where the 4 last digits are removed.
    private func getSafeAuthor(conversation: ConversationEntity) -> String {
        if let safeAuthor = conversation.author {
            return safeAuthor.components(separatedBy: "#").first ?? "Unknown"
        }
        return "Unknown"
    }
    
    /// Checks if a conversation has no sent messages.
    ///
    /// It is used to show another text in the `recent` messages part.
    /// - Returns: True if the conversation has messages in it.
    private func conversationsIsEmpty() -> Bool {
        do {
            let request: NSFetchRequest<ConversationEntity>
            request = ConversationEntity.fetchRequest()
            
            let count = try Session.context.count(for: request)
            return count == 0
        } catch {
            return true
        }
    }
}
