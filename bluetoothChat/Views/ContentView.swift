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
    
    @State var contacts: [String]? = UserDefaults.standard.stringArray(forKey: "Contacts")

    @State var QRViewActive = false
    @State var SettingsViewActive = false
    private var list = [0]
    
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
                                        Text((contact.components(separatedBy: "#")).first ?? "Unknown")
                                        Spacer()
                                    }
                                    HStack {
                                        Text(chatBrain.getLastMessage(contact) ?? "Start a new conversation.")
                                            .scaledToFit()
                                            .font(.footnote)
                                        Spacer()
                                    }
                                }
                            }
                        })
                        /*
                         TODO: Update as a sliding gesture for iOS13
                         
                         Remove contacts on long press.
                         */
                        .contextMenu(menuItems: {
                            
                            Button("Remove Contact") {
                                if contacts != nil {
                                    guard contacts!.contains(contact) else {
                                        return
                                    }
                                    
                                    var newContacts: [String] = []
                                    for c in contacts! {
                                        if c != contact {
                                            newContacts.append(c)
                                        }
                                    }
                                    
                                    UserDefaults.standard.setValue(newContacts, forKey: "Contacts")
                                }
                            }
                        })
                }
            }
            /*
             If no contacts have been added yet:
             */
            else {
                Spacer()
                
                Text("Add a contact to start chatting. Do this by scanning their QR code.")
                    .padding()
                
                Spacer()
            }
        }
        .navigationTitle("Chat")

        /*
         Toolbar in the navigation header.
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
        .onAppear() {
            Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { timer in
                contacts = UserDefaults.standard.stringArray(forKey: "Contacts")
            }
        }
    }
}

struct LongpressView: View {
    let contacts = UserDefaults.standard.stringArray(forKey: "Contacts")
    let contact: String
    
    var body: some View {
        Menu("Options") {
            Button("Remove Contact", action: {
                if contacts != nil {
                    guard contacts!.contains(contact) else {
                        return
                    }
                    
                    var newContacts: [String] = []
                    for c in contacts! {
                        if c != contact {
                            newContacts.append(c)
                        }
                    }
                    
                    UserDefaults.standard.setValue(newContacts, forKey: "Contacts")
                }
            })
        }
    }
    
    private func removeContact(_ who: String) {
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
