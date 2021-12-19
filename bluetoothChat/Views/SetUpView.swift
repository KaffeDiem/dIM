//
//  SetUpVoew.swift
//  bluetoothChat
//
//  Created by Kasper Munch on 26/08/2021.
//

import SwiftUI
import UIKit

/**
 SetUpView handles all initial first logins where users choose a username
 and are then redirected to ContentView which is the main View of the app.
 */
struct SetUpView: View {
    /// The `username` field stores the currently entered username from the user.
    @State var username: String = ""
    /// Checks if the user has set a username already. If yes we redirect to the `HomeView` instantly.
    @State var hasUsername: Bool = false
    /// True if the keyboard is shown. Used for animations.
    @FocusState private var keyboardShown: Bool
    /// A model for keeping track of active card in the carousel.
    @ObservedObject var UIStateCarousel = UIStateModel()
    
    /// The current colorscheme of the phone for displaying different visuals depending on light
    /// or dark mode.
    @Environment(\.colorScheme) var colorScheme
    /// The CoreData context object which we save to persistent storage to.
    @Environment(\.managedObjectContext) var context
    
    @FetchRequest(
        entity: ConversationEntity.entity(),
        sortDescriptors: [
            NSSortDescriptor(keyPath: \ConversationEntity.author, ascending: true)
        ]
        /// The saved conversations of the current user. Passed to the `HomeView`.
    ) var conversations: FetchedResults<ConversationEntity>
    
    var body: some View {
        NavigationView {
            VStack {
                // Explanatory carousel
                if !keyboardShown {
                    SnapCarousel()
                        .environmentObject(UIStateCarousel)
                        .transition(.slide)
                }
                
                // TextField for setting username
                VStack {
                    TextField("Username", text: $username, onCommit: {
                        }
                    )
                    .keyboardType(.namePhonePad)
                    .padding()
                    .background(
                        colorScheme == .dark ? Color("setup-grayDARK") : Color("setup-grayLIGHT")
                    )
                    .cornerRadius(10.0)
                    .focused($keyboardShown)
                    // Guide to username requirements
                    if !(username == "") {
                        if username.count < 4 {
                            Text("Minimum 4 characters.")
                                .font(.footnote)
                                .foregroundColor(.accentColor)
                        } else if username.count > 16 {
                            Text("Maximum 16 characters.")
                                .font(.footnote)
                                .foregroundColor(.accentColor)
                        } else if username.contains(" ") {
                            Text("No spaces in username.")
                                .font(.footnote)
                                .foregroundColor(.accentColor)
                        } else {
                            Text("")
                        }
                    }
                }
                .animation(.spring())
                .padding()
                .autocapitalization(.none)
                .disableAutocorrection(true)
                
                Spacer()
                
                VStack {
                    /*
                     EULA part.
                     */
                    HStack {
                        Text("By continuing you agree to the")
                        Link("EULA", destination: URL(string: "https://www.dimchat.org/eula")!)
                    }
                    
                    /*
                     Enter button which handles setting the username if valid.
                     */
                    Button(action: {
                        let usernameValid: Bool = checkUsername(username: username)
                        //  If the username is accepted then save it to persistent memory.
                        if usernameValid {
                            let usernameDigits = username + "#" + String(Int.random(in: 100000...999999))
                            UserDefaults.standard.set(usernameDigits, forKey: "Username")
                        }
                        hasUsername = usernameValid
                    }, label: {
                        Text("Continue")
                        .padding()
                        .foregroundColor(.white)
                        .frame(minWidth: 0, maxWidth: .infinity)
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [Color("dimOrangeDARK"), Color("dimOrangeLIGHT")]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(10.0)
                    })
                }
                .padding()
                
                // Empty link which takes the user to the main screen if username has been set.
                NavigationLink(destination: HomeView(chatBrain: ChatBrain(context: context))
                                .navigationBarTitle("")
                                .navigationBarBackButtonHidden(true),
                               isActive: $hasUsername) {
                    EmptyView()
                }
            }
            .onAppear() {
                // Check if the user already has a username.
                if UserDefaults.standard.string(forKey: "Username") != nil {
                    print("Username has been set -> Skip SetUpView")
                    self.hasUsername = true
                } else {
                    self.hasUsername = false
                }
                
                // Request permission to send notifications.
                UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
                    if success {
                        print("All set!")
                    } else if let error = error {
                        print(error.localizedDescription)
                    }
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    /// Checks if a username is valid
    /// - Parameter username: The string which a user types in a textfield.
    /// - Returns: Returns a boolean stating if the username is valid or not.
    private func checkUsername(username: String) -> Bool{
        if username == "DEMOAPPLETESTUSERNAME" {
            activateDemoMode()
            return true
        } else if username.count < 4 {
            return false
        } else if username.count > 16 {
            return false
        } else if username.contains(" ") {
            return false
        }
        return true
    }
    
    /// Activate demo mode for Apple where a conversation is automatically added as an example.
    /// This is used for the App Review process.
    private func activateDemoMode() {
        let _ = CryptoHandler().getPublicKey()
        /*
         Add a test conversation
         */
        let conversation = ConversationEntity(context: context)
        conversation.author = "SteveJobs#123456"
        let prkey = CryptoHandler().generatePrivateKey()
        let pukey = prkey.publicKey
        let pukeyStr = CryptoHandler().exportPublicKey(pukey)
        conversation.publicKey = pukeyStr
        
        let firstMessage = MessageEntity(context: context)
        firstMessage.id = 123456
        firstMessage.receiver = "DEMOAPPLETESTUSERNAME"
        firstMessage.sender = conversation.author
        firstMessage.status = Status.received.rawValue
        firstMessage.text = "Hi there, how are you?"
        firstMessage.date = Date()
        
        conversation.addToMessages(firstMessage)
        
        conversation.lastMessage = firstMessage.text
        
        do {
            try context.save()
        } catch {
            print("Demo user activated but could not save context.")
        }
    }
}
