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
    @EnvironmentObject var chatBrain: ChatHandler
    /// Temporary storage for the new username textfield.
    @State private var usernameTemp: String = UserDefaults.standard.string(forKey: "Username") ?? ""
    
    /// Temporary storage for the new username textfield. The ID (anything after `#`) is removed from this value.
    @State private var editableUsername = ""
    
    /// Colorscheme for this device to show different images depending on dark or light mode.
    @Environment(\.colorScheme) var colorScheme
    /// The amount of connected devices which is fetched from the `ChatBrain`.
    @State private var connectedDevices = 0
    
    @State private var showInvalidUsernameAlert = false
    /// A constant version of `usernameTemp`. It is set at launch and used to revert changes to the username.
    @State private var storedUsername = ""
    /// The user's ID (everything after `#`).
    @State private var userID = ""
    @State private var wantsToRevertUsernameChange = false
    @State private var hasChangedUsername = false
    
    func removeIDfromUsername() {
        var tempEditableUsername = usernameTemp.components(separatedBy: "#")
        editableUsername = String(tempEditableUsername.first ?? "\(usernameTemp)")
        userID = String(tempEditableUsername.last ?? "000000")
    }
    
    
    /// UserDefaults value of `settings.readmessages`. Default value is `true`.
    @AppStorage("settings.readmessages") var readStatusToggle = true
    
    var body: some View {
        VStack {
            Form {
                Section {
                    if wantsToRevertUsernameChange {
                        HStack {
                            Spacer()
                            ProgressView()
                            Spacer()
                        }
                    } else {
                        HStack {
                            Image(systemName: "person.crop.circle.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 65)
                            TextField("Choose an username...",
                                text: $editableUsername,
                                onCommit: {
                                        
                                    UIApplication.shared.endEditing()
                                    
                                    if checkValidUsername(username: editableUsername) {
                                        let usernameDigits = editableUsername + "#" + String(Int.random(in: 100000...999999))
                                        defaults.set(usernameDigits, forKey: "Username")
                                        self.hasChangedUsername = true
                                        var tempEditableUsername = usernameDigits.components(separatedBy: "#")
                                        editableUsername = String(tempEditableUsername.first ?? "\(usernameTemp)")
                                        userID = String(tempEditableUsername.last ?? "000000")
                                    } else {
                                        usernameTemp = ""
                                        self.showInvalidUsernameAlert = true
                                    }
                                }
                            )
                            .onAppear {
                                self.storedUsername = usernameTemp
                                removeIDfromUsername()
                                if usernameTemp == editableUsername + "#" + userID {
                                    self.hasChangedUsername = false
                                }
                            }
                            .keyboardType(.namePhonePad)
                            .padding()
                            .cornerRadius(10.0)
                            Text("#" + userID)
                                .foregroundColor(.gray)
                            
                            Spacer()
                            if hasChangedUsername {
                                Button(action: {
                                    self.wantsToRevertUsernameChange = true
                                }, label: {
                                    Image(systemName: "arrow.uturn.left")
                                })
                                .disabled(checkValidUsername(username: editableUsername) == false)
                            }
                            
                        }
                        .foregroundColor(.accentColor)
                    }
                    
                    
                } header: {
                    Text("My Username")
                } footer: {
                    Text("If you change your username, you and your contacts will have to add each other again.")
                }
                Section {
                    Toggle(isOn: $readStatusToggle, label: {
                        Label("Show Read Receipts", systemImage: "arrow.up.arrow.down.circle.fill")
                    })
                }
                
                Section {
                    NavigationLink(destination: AboutView(), label: {
                        Label("About & Contact", systemImage: "questionmark.app")
                            .foregroundColor(.accentColor)
                    })
                }
                
                Section {
                    if connectedDevices < 1 {
                        Label("No devices connected yet.", systemImage: "ipad.and.iphone")
                             .imageScale(.large)
                             .font(.title3)
                             .fontWeight(.semibold)
                    } else {
                        Label("\(connectedDevices) devices connected.", systemImage: "ipad.and.iphone")
                             .imageScale(.large)
                             .font(.title3)
                             .fontWeight(.semibold)
                    }
                   
                    Label("\(chatBrain.routedCounter) messages routed in this session.", systemImage: "arrow.forward.circle.fill")
                        .imageScale(.large)
                         .font(.title3)
                         .fontWeight(.semibold)
                } header: {
                    Text("Connectivity")
                }
                
            }
            
            .symbolRenderingMode(.hierarchical)
            .navigationTitle("Settings")
            .autocapitalization(.none)
            .disableAutocorrection(true)
            .navigationBarTitle("Settings", displayMode: .large)
        }
        .alert(determineUsernameWordedIssue(username: editableUsername), isPresented: $showInvalidUsernameAlert) {
                    Button("Cancel", role: .cancel) {
                        self.usernameTemp = storedUsername
                    }
         }
        .alert("Do you want to change your username from \"\(defaults.string(forKey: "Username") ?? editableUsername)\" back to \"\(storedUsername)\"? You will not be able to revert afterwise.", isPresented: $wantsToRevertUsernameChange) {
            Button("Change", role: .none) {
                self.usernameTemp = storedUsername
                defaults.set(storedUsername, forKey: "Username")
                defaults.synchronize()
            }
            Button("Cancel", role: .cancel) {
                self.usernameTemp = defaults.string(forKey: "Username") ?? ""
            }
         }
    }
    
    /// Determines issues with setting an specific username and returns a `String` to be returned and shown in an alert.
    func determineUsernameWordedIssue(username: String) -> String {
        if username.count < 4 {
            return "Your username must have at least 4 characters."
        } else if username.count > 16 {
            return "Your username must not have more than 16 characters."
        } else if username.contains(" ") {
            return "Your username must not contain spaces."
        } else if username.isEmpty {
            return "Your username cannot be empty."
        }
        return "Your username has been changed successfully."
    }
    
    /*
     ScrollView {
         
         /*
          About dIM
          */
         
         
         /*
          Current connections
          */
         /*
         ConnectivityView()
             .environmentObject(chatBrain)
             .padding(EdgeInsets(top: 2, leading: 8, bottom: 2, trailing: 8))
          */
         
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
                 defaults.string(forKey: "Username") ?? "",
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
     */
    
    
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

/*
 // MARK: Missing EnvironmentObject, cannot be run in Xcode Previews
 struct SettingsView_Previews: PreviewProvider {
 static var previews: some View {
 SettingsView()
 }
 }
 */
