//
//  SettingsView.swift
//  bluetoothChat
//
//  Created by Kasper Munch on 25/08/2021.
//

import SwiftUI


/*
 Read message toggle.
 */
struct ReadToggle: View {
    
    let defaults = UserDefaults.standard
    @State var readStatusToggle: Bool = UserDefaults.standard.bool(forKey: "settings.readmessages")
    
    var body: some View {
        VStack {
            Toggle("Read receipts", isOn: $readStatusToggle)
                .onChange(of: readStatusToggle, perform: {value in
                    if value {
                        defaults.setValue(readStatusToggle, forKey: "settings.readmessages")
                        print("toggle on")
                    } else {
                        defaults.setValue(readStatusToggle, forKey: "settings.readmessages")
                        print("toggle off")
                    }
                })
                .toggleStyle(SwitchToggleStyle(tint: .accentColor))
        }
    }
}


/*
 A connectivity view for device information
 */
struct ConnectivityView: View {
    
    @EnvironmentObject var chatBrain: ChatBrain
    
    var body: some View {
        GroupBox(label: Text("Connectivity"), content: {
            
            Divider().padding(.vertical, 4)
            
            Text("At least one device connected is needed to send messages.")
                .font(.footnote)
                .foregroundColor(.gray)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            if chatBrain.discoveredDevices.count < 1 {
                Label("Not connected.", systemImage: "figure.stand")
            
            } else {
                Label(
                    "\(chatBrain.discoveredDevices.count) device\(chatBrain.discoveredDevices.count == 1 ? "" : "s") connected.",
                    systemImage: "figure.stand.line.dotted.figure.stand"
                )
            
            }
            
            Text("Messages sent trough your phone to be delivered to others.")
                .font(.footnote)
                .foregroundColor(.gray)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Label("\(chatBrain.routedCounter) messages routed.", systemImage: "network")
            
        })
    }
}


struct SettingsView: View {
    
    let defaults = UserDefaults.standard
    
    @EnvironmentObject var chatBrain: ChatBrain
    
    @State var usernameTemp: String = ""
    @Environment(\.colorScheme) var colorScheme
    
    @State private var connectedDevices = 0
    
    var body: some View {
        VStack(spacing: 20) {
            
            ScrollView {
                
                
                ConnectivityView()
                    .environmentObject(chatBrain)
                    .padding(EdgeInsets(top: 2, leading: 8, bottom: 2, trailing: 8))
                
                /*
                 dIM Icon in top of settings view.
                 */
                GroupBox(label: Text("Decentralized Instant Messenger"), content: {
                    Divider().padding(.vertical, 4)
                    HStack {
                        Image("appiconsvg")
                            .resizable()
                            .frame(width: 96, height: 96, alignment: .leading)
                            .aspectRatio(contentMode: .fit)
                            .scaledToFit()
                        Spacer()
                        
                            
                        Text("""
                            dIM is a decentralized chat app based on Bluetooth. If you send a contact a message it will be sent on the Bluetooth peer-to-peer network. Messages are encrypted such that only you and the receiver can read the content.
                            """
                        )
                            .foregroundColor(.gray)
                            .font(.footnote)
                            .padding(.leading)
                            .fixedSize(horizontal: false, vertical: true)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                })
                    .padding(EdgeInsets(top: 2, leading: 8, bottom: 2, trailing: 8))
                
                GroupBox(label: Text("Send read receipts"), content: {
                    Divider().padding(.vertical, 4)
                    Text("Read receipts allow your contacts to known when you have seen their messages.")
                        .font(.footnote)
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    ReadToggle()
                })
                    .padding(EdgeInsets(top: 2, leading: 8, bottom: 2, trailing: 8))

                GroupBox(label: Text("Change username"), content: {
                    Divider().padding(.vertical, 4)
                    /*
                     Text field to input new username
                     */
                    Text("Notice: If you change your username you and your contacts will have to add each other again.")
                        .foregroundColor(.gray)
                        .font(.footnote)
                        .fixedSize(horizontal: false, vertical: true)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    TextField(
                        defaults.string(forKey: "Username")!,
                        text: $usernameTemp,
                        onCommit: {
                                
                            UIApplication.shared.endEditing()
                            
                            if checkValidUsername(username: usernameTemp) {
                                let usernameDigits = usernameTemp + "#" + String(Int.random(in: 100000...999999))
                                defaults.set(usernameDigits, forKey: "Username")
                            } else {
                                usernameTemp = ""
                            }
                        }
                    )
                    .keyboardType(.namePhonePad)
                    .padding()
                    .background(
                        colorScheme == .dark ? Color("setup-grayDARK") : Color("setup-grayLIGHT")
                    )
                    .cornerRadius(10.0)
                    
                    /*
                     Text below textfield.
                     */
                    if usernameTemp.count < 4 {
                        Text("Minimum 4 characters.")
                            .font(.footnote)
                            .foregroundColor(.accentColor)
                    } else if usernameTemp.count > 16 {
                        Text("Maximum 16 characters.")
                            .font(.footnote)
                            .foregroundColor(.accentColor)
                    } else if usernameTemp.contains(" ") {
                        Text("No spaces in username.")
                            .font(.footnote)
                            .foregroundColor(.accentColor)
                    } else {
                        Text(" ")
                    }
                })
                    .padding(EdgeInsets(top: 2, leading: 8, bottom: 2, trailing: 8))
            }
            .autocapitalization(.none)
            .disableAutocorrection(true)
            .navigationBarTitle("Settings", displayMode: .automatic)
        }
    }
    
    func checkValidUsername(username: String) -> Bool{
        if username.count < 4 {
            return false
        } else if username.count > 16 {
            return false
        } else if username.contains(" ") {
            return false
        }
        return true
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
