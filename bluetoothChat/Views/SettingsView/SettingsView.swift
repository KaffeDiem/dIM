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

struct SettingsView: View {
    
    let defaults = UserDefaults.standard
    
    @EnvironmentObject var chatBrain: ChatBrain
    
    @State var usernameTemp: String = ""
    @Environment(\.colorScheme) var colorScheme
    
    @State private var connectedDevices = 0
    
    var body: some View {
        VStack(spacing: 20) {
            
            ScrollView {
                
                /*
                 About dIM
                 */
                AboutView()
                
                /*
                 Current connections
                 */
                ConnectivityView()
                    .environmentObject(chatBrain)
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
                
                SupportView()
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
