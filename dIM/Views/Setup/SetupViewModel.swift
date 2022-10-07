//
//  SetupViewModel.swift
//  bluetoothChat
//
//  Created by Kasper Munch on 31/01/2022.
//

import Foundation
import UserNotifications
import CoreData

class SetupViewModel: ObservableObject {
    /// Check if the user has set a username already.
    /// Used to redirect to ``HomeView``.
    @Published public var hasUsername = false
    
    @Published var username = "" {
        didSet {
            usernameState = usernameValidator.validate(username: username)
        }
    }
    @Published var usernameState: UsernameValidator.State = .undetermined
    
    /// Used to check for validaty of new username.
    let usernameValidator: UsernameValidator = .init()
    
    /// The CoreData context object which we save to persistent storage to.
    private var context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    @MainActor
    public func onAppear() {
        if UserDefaults.standard.string(forKey: "Username") != nil {
            hasUsername = true
        }
        
        // Request permission to send notifications
        UNUserNotificationCenter.current().requestAuthorization(
            options: [.alert, .badge, .sound]
        ) { success, error in
            if success {
                print("All set!")
            } else if let e = error {
                print(e.localizedDescription)
            }
        }
    }
    
    /// Set the username for this device and save it to `UserDefaults`.
    /// - Parameter username: The username to set.
    public func saveUsername() {
        if username == "DEMOAPPLETESTUSERNAME" {
            activateDemoMode()
        } else {
            switch usernameState {
            case .valid:
                saveAndContinue(with: username)
            case .undetermined, .error:
                ()
            }
        }
    }
    
    private func saveAndContinue(with username: String) {
        let usernameWithDigits = username + "#" + String(Int.random(in: 100000...999999))
        
        // Save to `UserDefaults`
        UserDefaults.standard.set(usernameWithDigits, forKey: "Username")
        hasUsername = true
    }
    
    /// Activate demo mode for Apple where a conversation is automatically added as an example.
    /// This is used for the App Review process.
    private func activateDemoMode() {
        let _ = CryptoHandler.getPublicKey()
        // Add a test conversation
        let conversation = ConversationEntity(context: context)
        conversation.author = "SteveJobs#123456"
        let prkey = CryptoHandler.generatePrivateKey()
        let pukey = prkey.publicKey
        let pukeyStr = CryptoHandler.exportPublicKey(pukey)
        conversation.publicKey = pukeyStr
        // And fill that conversation with a message
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
