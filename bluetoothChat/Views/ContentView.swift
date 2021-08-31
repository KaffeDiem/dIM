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
    
    @StateObject var chatBrain = ChatBrain()
    
    @State var contacts = UserDefaults.standard.stringArray(forKey: "Contacts")
    
    var body: some View {
        VStack {
            if let safeContacts = contacts {
                
                /*
                 List of contacts and their last messages.
                 */
                List(safeContacts, id: \.self) {contact in
                    
                    NavigationLink(
                        destination: ChatView(sender: contact)
                            .environmentObject(chatBrain),
                        label: {
                            HStack {
                                Image(systemName: "person")
                                    .frame(width: 50, height: 50, alignment: .center)

                                VStack {
                                    HStack {
                                        Text(contact)
                                        Spacer()
                                    }
                                HStack {
                                    Text(chatBrain.getLastMessage(contact) ?? "Start a conversation with \(contact).")
                                        .scaledToFit()
                                        .font(.footnote)
                                    Spacer()
                                }
                                }
                            }
                        })
                    
                }
            } else {
                Spacer()
                
                Text("Add a contact to start chatting. Do this by scanning their QR code.")
                    .padding()
                
                Spacer()
            }
        }
        
        
        .navigationTitle("Chat")

        .toolbar {
            // Settings button
            ToolbarItemGroup(placement: .navigationBarLeading) {
                NavigationLink(
                    destination: SettingsView()
                        .environmentObject(chatBrain),
                    label: {
                        Image(systemName: "gearshape.fill")
                    }
                )
            }
            
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                // Discover button
                NavigationLink(
                    destination: QRScreenView()
                        .environmentObject(chatBrain),
                    label: {
                        Image(systemName: "qrcode")
                    }
                )
            }
        }
        .onAppear() {
            Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { timer in
                contacts = UserDefaults.standard.stringArray(forKey: "Contacts")
            }
        }
        
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
