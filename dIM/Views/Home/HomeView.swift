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
    
    /// Initialize the appSession which handles logic of Bluetooth
    /// and sending / receiving messages.
    @EnvironmentObject var appSession: AppSession
    
    @ObservedObject var viewModel = HomeViewModel()
    
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
    @StateObject private var UIStateCarousel = CarouselViewModel()
    
    /// Body and content of the HomeView.
    var body: some View {
        
        VStack {
            if !conversationsIsEmpty() {
                /*
                 List all added users and their conversations.
                 */
                List() {
                    ForEach(conversations, id: \.self) { conversation in
                        NavigationLink {
                            ChatView(conversation: conversation)
                                .environmentObject(appSession)
                        } label: {
                            VStack {
                                Text(viewModel.getAuthor(for: conversation) ?? "Unknown")
                                    .foregroundColor(.accentColor)
                                    .frame(maxWidth: .infinity, alignment: .leading)

                                Text(conversation.lastMessage ?? "Start a new conversation.")
                                    .scaledToFit()
                                    .font(.footnote)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            .padding()
                        }
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
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
                                Label("Clear", systemImage: "exclamationmark.bubble.fill")
                            }
                            .tint(.accentColor)
                            
                            Button(role: .destructive) {
                                deleteContact(for: conversation)
                            } label: {
                                Label("Delete", systemImage: "person.fill.xmark")
                            }
                        }
                    }
                }
            } else {
                SnapCarousel()
                    .environmentObject(UIStateCarousel)
            }
        }
        .toolbar {
            ToolbarItem(placement: .principal) {
                VStack {
                    Text("Chats")
                        .font(.headline)
                    if appSession.connectedDevicesAmount < 1 {
                        HStack {
                            Image(systemName: "antenna.radiowaves.left.and.right.slash")
                                .imageScale(.small)
                                .symbolRenderingMode(.palette)
                                .foregroundStyle(.red, .orange, .white)
                            Text("Not connected")
                                .foregroundColor(.accentColor)
                                .font(.subheadline)
                        }
                    } else {
                        HStack {
                            Image(systemName: "antenna.radiowaves.left.and.right")
                                .imageScale(.small)
                            Text("\(appSession.connectedDevicesAmount) in range").font(.subheadline)
                        }
                    }
                }
            }
            ToolbarItem(placement: .navigationBarLeading) {
                NavigationLink(destination: SettingsView().environmentObject(appSession), label: {
                    Image(systemName: "gearshape.fill")
                })
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink(destination: QRView().environmentObject(appSession), label: {
                    Image(systemName: "qrcode")
                })
            }
        }
        .navigationBarBackButtonHidden(true)
        .onAppear {
            Task {
                try? await PurchaseManager.shared.loadProducts()
            }
        }
    }
    
    private func deleteContact(for conversation: ConversationEntity) {
        Session.context.delete(conversation)
        
        do {
            try Session.context.save()
        } catch {
            print("[Error] Could not delete conversations.")
        }
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
