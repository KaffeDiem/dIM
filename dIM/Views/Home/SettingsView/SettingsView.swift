//
//  SettingsView.swift
//  bluetoothChat
//
//  Created by Kasper Munch on 25/08/2021.
//

import SwiftUI

/// The main `SettingsView` which shows a number of subviews for different purposes.
///
/// It is here that we set new usernames and toggles different settings.
/// It also shows contact information for dIM among other things.
struct SettingsView: View {
    /// CoreDate context object
    @Environment(\.managedObjectContext) var context
    @Environment(\.colorScheme) var colorScheme
    
    /// The `UserDefaults` for getting information from persistent storage.
    private let defaults = UserDefaults.standard
    
    /// The `AppSession` to get things from the logic layer.
    @EnvironmentObject var appSession: AppSession
    
    @State private var usernameTextFieldText = ""
    @State private var usernameTextFieldIdentifier = ""
    
    @State private var invalidUsernameAlertMessageIsShown = false
    @State private var invalidUsernameAlertMessage = ""
    
    @State private var changeUsernameAlertMessageIsShown = false
    
    /// All conversations stored to CoreData
    @FetchRequest(
        entity: ConversationEntity.entity(),
        sortDescriptors: [
            NSSortDescriptor(keyPath: \ConversationEntity.date, ascending: false)
        ]
    ) var conversations: FetchedResults<ConversationEntity>
    
    /// Read messages setting saved to UserDefaults
    @AppStorage(UserDefaultsKey.readMessages.rawValue) var readStatusToggle = false
    
    var body: some View {
        Form {
            Section {
                HStack {
                    Image(systemName: "person.crop.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 65)
                    
                    if changeUsernameAlertMessageIsShown {
                        Spacer()
                        ProgressView()
                    } else {
                        TextField("Choose a username...", text: $usernameTextFieldText, onCommit: {
                            hideKeyboard()
                            
                            switch UsernameValidator.shared.validate(username: usernameTextFieldText) {
                            case .valid, .demoMode:
                                changeUsernameAlertMessageIsShown = true
                            case .error(message: let errorMessage):
                                invalidUsernameAlertMessage = errorMessage
                                invalidUsernameAlertMessageIsShown = true
                            default: ()
                            }
                        })
                        .keyboardType(.namePhonePad)
                        .padding()
                        .cornerRadius(10.0)
                    }
                    
                    Spacer()
                    
                    Text("# " + usernameTextFieldIdentifier)
                        .foregroundColor(.gray)
                }
                .foregroundColor(.accentColor)
            } header: {
                Text("My Username")
            } footer: {
                Text("If you change your username, you and your contacts will have to add each other again.")
            }
            
            Section {
                Toggle(isOn: $readStatusToggle) {
                    Label("Show Read Receipts", systemImage: "eye.fill")
                        .imageScale(.large)
                }
                .toggleStyle(SwitchToggleStyle(tint: .accentColor))
            } footer: {
                Text("Read receips allow your contacts to see if you have read their messages.")
            }
            
            Section {
                NavigationLink(destination: AboutView()) {
                    Label("About & Contact", systemImage: "questionmark")
                        .foregroundColor(.accentColor)
                        .imageScale(.large)
                }
            }
            
            Section {
                Label(
                    appSession.connectedDevicesAmount < 0 ? "No devices connected." : "\(appSession.connectedDevicesAmount) devices connected.",
                    systemImage: "ipad.and.iphone")
                    .imageScale(.large)
                
                Label("\(appSession.routedCounter) messages routed in this session.", systemImage: "arrow.left.arrow.right")
                    .imageScale(.large)
            } header: {
                Text("Connectivity")
            } footer: {
                Text("Information about connected devices and amount of messages routed through your phone.")
            }
        }
        .symbolRenderingMode(.hierarchical)
        .autocapitalization(.none)
        .disableAutocorrection(true)
        .navigationBarTitle("Settings", displayMode: .large)
        .onAppear {
            setUsernameTextFieldToStoredValue()
        }
        // MARK: Alerts
        // Invalid username alert
        .alert("Invalid username", isPresented: $invalidUsernameAlertMessageIsShown) {
            Button("OK", role: .cancel) {
                setUsernameTextFieldToStoredValue()
            }
        } message: {
            Text(invalidUsernameAlertMessage)
        }
        // Change username alert
        .alert("Change username", isPresented: $changeUsernameAlertMessageIsShown) {
            Button("Change", role: .destructive) {
                let state = UsernameValidator.shared.set(username: usernameTextFieldText, context: context)
                switch state {
                case .valid(let userInfo):
                    usernameTextFieldText = userInfo.name
                    usernameTextFieldIdentifier = userInfo.id
                    deleteAllConversations()
                    CryptoHandler.resetKeys()
                case .demoMode(let userInfo):
                    usernameTextFieldText = userInfo.name
                    usernameTextFieldIdentifier = userInfo.id
                    CryptoHandler.resetKeys()
                default:
                    setUsernameTextFieldToStoredValue()
                }
            }
            Button("Cancel", role: .cancel) {
                setUsernameTextFieldToStoredValue()
            }
        } message: {
            Text("Changing your username will reset dIM Chat and remove your contacts. Do this carefully.")
        }
    }
    
    /// Revert username to what is stored in UserDefaults
    private func setUsernameTextFieldToStoredValue() {
        usernameTextFieldText = UsernameValidator.shared.userInfo?.name ?? ""
        usernameTextFieldIdentifier = UsernameValidator.shared.userInfo?.id ?? ""
    }
    
    /// Delete all conversations (very destructive)
    private func deleteAllConversations() {
        conversations.forEach { conversation in
            context.delete(conversation)
        }
        do {
            try context.save()
        } catch {
            print("Context could not be saved after deleting all conversations")
        }
    }
}
