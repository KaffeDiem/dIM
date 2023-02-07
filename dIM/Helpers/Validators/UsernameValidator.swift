//
//  UsernameValidator.swift
//  dIM
//
//  Created by Kasper Munch on 07/10/2022.
//

import Foundation
import Combine

class UsernameValidator: ObservableObject {
    struct UserInfo {
        let id: String
        let name: String
    }
    
    /// Keys related to username used to access UserDefaults
    enum Keys: String {
        case username = "settings.username"
        case userId = "settings.userid"
        
        var value: String {
            return self.rawValue
        }
    }
    
    /// State describing the current username
    enum State {
        case valid(userInfo: UserInfo)
        case error(message: String)
        case undetermined
        case demoMode
    }
    
    // MARK: Public variables
    @Published private(set) var state: State {
        didSet {
            switch state {
            case .valid: isUsernameValid = true
            default: isUsernameValid = false
            }
        }
    }
    
    @Published var isUsernameValid: Bool = false
    @Published var userInfo: UserInfo?
    
    // MARK: Private variables
    private var usernameStore: String? {
        UserDefaults.standard.string(forKey: Keys.username.value)
    }
    
    private var userIdStore: String? {
        UserDefaults.standard.string(forKey: Keys.userId.value)
    }
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        self.state = .undetermined
        if let username = usernameStore, let userId = userIdStore {
            userInfo = .init(id: userId, name: username)
        }
        setupBindings()
        setupState()
    }
    
    private func setupBindings() {
        $state.receive(on: RunLoop.main)
            .sink { [weak self] state in
                switch state {
                case .valid(let userInfo):
                    self?.userInfo = userInfo
                default: ()
                }
            }.store(in: &cancellables)
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
    @discardableResult func set(username: String) -> State {
        state = .undetermined
        let state = validate(username: username)
        if case .valid(let userInfo) = state {
            UserDefaults.standard.set(userInfo.name, forKey: Keys.username.value)
            UserDefaults.standard.set(userInfo.id, forKey: Keys.userId.value)
        }
        self.state = state
        return state
    }
    
    /// Validate a given username
    ///- Note: The given username should not include # or an id
    /// - Parameter username: Username without digits
    /// - Returns: A state describing the validation
    private func validate(username: String) -> State {
        guard !(username == "DEMOAPPLETESTUSERNAME") else { return .demoMode }
        guard username.count >= 4 else { return .error(message: "Username is too short") }
        guard username.count <= 16 else { return .error(message: "Username is too long") }
        guard !username.contains(" ") else { return .error(message: "Username cannot include spaces")}
        
        let id = String(Int.random(in: 1000 ... 9999))
        return .valid(userInfo: .init(id: id, name: username))
    }
}
