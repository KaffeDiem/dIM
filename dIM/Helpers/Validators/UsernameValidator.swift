//
//  UsernameValidator.swift
//  dIM
//
//  Created by Kasper Munch on 07/10/2022.
//

import Foundation
import Combine

class UsernameValidator {
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
    }
    
    // MARK: Public variables
    @Published var state: State
    var userInfo: UserInfo? {
        guard let username, let userId else { return nil }
        return .init(id: username, name: userId)
    }
    
    // MARK: Private variables
    private var username: String? {
        UserDefaults.standard.string(forKey: Keys.username.value)
    }
    
    private var userId: String? {
        UserDefaults.standard.string(forKey: Keys.userId.value)
    }
    
    init() {
        self.state = .undetermined
        if let userInfo {
            self.state = .valid(userInfo: userInfo)
        }
    }
    
    @discardableResult
    /// Sets a new username and saves it to UserDefaults
    /// - Parameter username: Username to save
    /// - Returns: Username state
    func set(username: String) -> State {
        state = .undetermined
        let state = validate(username: username)
        if case .valid(let username) = state {
            UserDefaults.standard.set(username, forKey: Keys.username.value)
            UserDefaults.standard.set(userId, forKey: Keys.userId.value)
        }
        self.state = state
        return state
    }
    
    /// Validate a given username
    ///
    ///- Note: The given username should not include # or an id
    ///
    /// - Parameter username: Username without digits
    /// - Returns: A state describing the validation
    private func validate(username: String) -> State {
        guard username.count >= 4 else { return .error(message: "Username is too short") }
        guard username.count <= 16 else { return .error(message: "Username is too long") }
        guard !username.contains(" ") else { return .error(message: "Username cannot include spaces")}
        
        let id = String(Int.random(in: 1000 ... 9999))
        return .valid(userInfo: .init(id: id, name: username))
    }
}
