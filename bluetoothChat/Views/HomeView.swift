//
//  HomeView.swift
//  bluetoothChat
//
//  Created by Kasper Munch on 23/08/2021.
//

import CoreData
import SwiftUI

/*
 This is the main view from which everything else will be loaded.
 Most important is the Bluetooth Manager which handles the logic
 of the app.
 */
struct HomeView: View {
    
    /*
     Get the contact list saved to UserDefaults as a String array
     */
    
    /*
     Get the environment object context
     */
    @Environment(\.managedObjectContext) var context
    
    /*
     Initialize the ChatBrain which handles logic of Bluetooth
     and sending / receiving messages.
     */
    @StateObject var chatBrain: ChatBrain
    
    /*
     Get conversations saved to Core Data
     */
    @FetchRequest(
        entity: ConversationEntity.entity(),
        sortDescriptors: [
            NSSortDescriptor(keyPath: \ConversationEntity.author, ascending: true)
        ]
    ) var conversations: FetchedResults<ConversationEntity>
    
    /*
     The actual body of the HomeView
     */
    var body: some View {
        
        VStack {
            if !conversationsIsEmpty() {
                /*
                 List all added users and their conversations.
                 */
                List(conversations) { conversation in
                    NavigationLink(
                        destination: ChatView(conversation: conversation)
                            .environmentObject(chatBrain),
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
                                    try context.save()
                                } catch {
                                    print("Context could not be saved.")
                                }
                            } label: {
                                Label("Clear Conversation", systemImage: "exclamationmark.bubble.fill")
                            }
                            .tint(.accentColor)
                            // Deleting a contact.
                            Button(role: .destructive) {
                                context.delete(conversation)
                                do {
                                    try context.save()
                                } catch {
                                    print("Context could not be saved.")
                                }
                            } label: {
                                Label("Delete Contact", systemImage: "person.fill.xmark")
                            }
                        }
                }
            } else {
                Text("Add a new contact by scanning their QR code and by letting them scan yours.")
                    .padding()
            }
        }
        .navigationTitle("Chat")
        
        /*
         Toolbar in the navigation header for SettingsView and ChatView.
         */
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                NavigationLink(destination: SettingsView().environmentObject(chatBrain), label: {
                    Image(systemName: "gearshape.fill")
                })
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink(destination: QRView(), label: {
                    Image(systemName: "qrcode")
                })
                
            }
        }
    }
    
    func getSafeAuthor(conversation: ConversationEntity) -> String {
        if let safeAuthor = conversation.author {
            return safeAuthor.components(separatedBy: "#").first ?? "Unknown"
        }
        return "Unknown"
    }
    
    func conversationsIsEmpty() -> Bool {
        do {
            let request: NSFetchRequest<ConversationEntity>
            request = ConversationEntity.fetchRequest()
            
            let count = try context.count(for: request)
            return count == 0
        } catch {
            return true
        }
    }
}
