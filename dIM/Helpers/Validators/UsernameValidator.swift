//
//  UsernameValidator.swift
//  dIM
//
//  Created by Kasper Munch on 07/10/2022.
//

import Foundation
import Combine
import CoreData

class UsernameValidator: ObservableObject {
    /// UsernameValidator as a singleton. Use this to access all user information.
    static var shared = UsernameValidator()
    
    struct UserInfo {
        let id: String
        let name: String
        
        var asString: String {
            name + "#" + id
        }
    }
    
    /// State describing the current username
    enum State {
        case valid(userInfo: UserInfo)
        case demoMode(userInfo: UserInfo)
        case error(message: String)
        case undetermined
    }
    
    // MARK: Public variables
    @Published private(set) var state: State
    @Published private(set) var userInfo: UserInfo?
    @Published var isUsernameValid: Bool = false
    
    // MARK: Private variables
    private var usernameStore: String? {
        UserDefaults.standard.string(forKey: UserDefaultsKey.username.rawValue)
    }
    
    private var userIdStore: String? {
        UserDefaults.standard.string(forKey: UserDefaultsKey.userId.rawValue)
    }
    
    private var cancellables = Set<AnyCancellable>()
    
    private init() {
        self.state = .undetermined
        if let username = usernameStore, let userId = userIdStore {
            userInfo = .init(id: userId, name: username)
            isUsernameValid = true
        }
        setupState()
    }
    
    private func setupState() {
        if let userInfo {
            self.state = .valid(userInfo: userInfo)
        }
    }
    
    /// Sets a new username and saves it to UserDefaults
    /// - Note: Do not append id to username
    /// - Parameter username: Username to save
    /// - Returns: Username state
    @discardableResult func set(username: String, context: NSManagedObjectContext) -> State {
        state = .undetermined
        let state = validate(username: username)
        switch state {
        case .valid(let userInfo):
            UserDefaults.standard.set(userInfo.name, forKey: UserDefaultsKey.username.rawValue)
            UserDefaults.standard.set(userInfo.id, forKey: UserDefaultsKey.userId.rawValue)
        case .demoMode(let userInfo):
            UserDefaults.standard.set(userInfo.name, forKey: UserDefaultsKey.username.rawValue)
            UserDefaults.standard.set(userInfo.id, forKey: UserDefaultsKey.userId.rawValue)
            activateDemoMode(for: context)
        default: ()
        }
        self.state = state
        if let username = usernameStore, let userId = userIdStore {
            userInfo = .init(id: userId, name: username)
            isUsernameValid = true
        }
        return state
    }
    
    /// Validate a given username
    ///- Note: The given username should not include # or an id
    ///- Note: Discard the userInfo if only used to check if a given username is valid
    /// - Parameter username: Username without digits
    /// - Returns: A state describing the validation
    func validate(username: String) -> State {
        guard !(username == "APPLEDEMO") else { return .demoMode(userInfo: .init(id: "123456", name: "DEMO")) }
        guard username.count >= 4 else { return .error(message: "Username is too short") }
        guard username.count <= 16 else { return .error(message: "Username is too long") }
        guard !username.contains(" ") else { return .error(message: "Username cannot include spaces")}
        guard !username.contains("#") else { return .error(message: "Username cannot include #")}
        guard !username.contains("/") else { return .error(message: "Username cannot include /")}
        
        let id = String(Int.random(in: 1000 ... 9999))
        return .valid(userInfo: .init(id: id, name: username))
    }
}

// MARK: Apple demo mode (for review process)
extension UsernameValidator {
    /// Activate demo mode for App Store review process
    private func activateDemoMode(for context: NSManagedObjectContext) {
        let _ = CryptoHandler.fetchPublicKeyString()
        
        // Add a test conversation
        let conversation = ConversationEntity(context: context)
        conversation.author = "SteveJobs#123456"
        let privateKey = CryptoHandler.generatePrivateKey()
        let publicKey = privateKey.publicKey
        let publicKeyText = CryptoHandler.convertPublicKeyToString(publicKey)
        conversation.publicKey = publicKeyText
        
        // And fill that conversation with a message
        let firstMessage = MessageEntity(context: context)
        firstMessage.id = 123456
        firstMessage.receiver = "DEMOAPPLETESTUSERNAME"
        firstMessage.sender = conversation.author
        firstMessage.status = MessageStatus.received.rawValue
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
