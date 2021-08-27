//
//  ContentView.swift
//  bluetoothChat
//
//  Created by Kasper Munch on 23/08/2021.
//

import SwiftUI

/*
 This is the main view from which everything else will be loaded.
 Most important is the Bluetooth Manager which handles the logic
 of the app.
 */
struct ContentView: View {
    
    // Create a new Bluetooth Manager which handles the central and peripheral role.
    @StateObject var bluetoothManager = ChatBrain()
    
    var body: some View {
        List(bluetoothManager.conversations) {conversation in
            NavigationLink(
                destination: ChatView(sender: conversation.author)
                    .environmentObject(bluetoothManager),
                label: {
                    HStack {
                        Image(systemName: "person")
                            .frame(width: 50, height: 50, alignment: .center)

                        VStack {
                            HStack {
                                Text(conversation.author)
                                Spacer()
                            }
                            HStack {
                                Text(conversation.lastMessage.text)
                                    .scaledToFit()
                                    .font(.footnote)
                                Spacer()
                            }
                        }
                    }
                }
            )
        }
        .onAppear() {
            
        }
        
        .navigationTitle("Chat")

        .toolbar {
            // Settings button
            ToolbarItemGroup(placement: .navigationBarLeading) {
                NavigationLink(
                    destination: SettingsView(),
                    label: {
                        Image(systemName: "gearshape.fill")
                    }
                )
            }
            
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                // Discover button
                NavigationLink(
                    destination: DiscoverView()
                        .environmentObject(bluetoothManager),
                    label: {
                        Image(systemName: "person.fill.badge.plus")
                    }
                )
                // Connection Button
                NavigationLink(
                    destination: ConnectionView()
                        .environmentObject(bluetoothManager),
                    label: {
                        Image(systemName: "bolt.horizontal.circle.fill")
                    }
                )
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
