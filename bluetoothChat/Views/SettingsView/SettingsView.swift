//
//  SettingsView.swift
//  bluetoothChat
//
//  Created by Kasper Munch on 25/08/2021.
//

import SwiftUI

/// The `READ` setting toggle which is a setting that
/// can be turned on and off based on user preferences.
///
/// If it is enabled then the sender of messages can see that you have
/// read their messages.
///
/// - Note: Default value is off.
struct ReadToggle: View {
    
    /// `UserDefaults` for persistent storage.
    let defaults = UserDefaults.standard
    /// The read status toggle as a boolean saved to `UserDefaults`
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

/// The main `SettingsView` which shows a number of subviews for different purposes.
///
/// It is here that we set new usernames and toggles different settings.
/// It also shows contact information for dIM among other things.
struct SettingsView: View {
    
    /// The `UserDefaults` for getting information from persistent storage.
    let defaults = UserDefaults.standard
    
    /// The `ChatBrain` to get things from the logic layer.
    @EnvironmentObject var chatBrain: ChatBrain
    
    /// Temporary storage for the new username textfield.
    @State var usernameTemp: String = ""
    /// Colorscheme for this device to show different images depending on dark or light mode.
    @Environment(\.colorScheme) var colorScheme
    
    /// The amount of connected devices which is fetched from the `ChatBrain`.
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
    
    /// Check if a username is valid. If it is not we are not allowed
    /// to set it.
    ///
    /// Usernames must be 4-16 chars long and not contain spaces.
    /// - Parameter username: The username to check.
    /// - Returns: A boolean indicating if the username is valid.
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
