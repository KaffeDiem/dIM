//
//  UsernameValidator.swift
//  dIM
//
//  Created by Kasper Munch on 07/10/2022.
//

import Foundation

class UsernameValidator {
    enum State {
        case valid
        case error(message: String)
        case undetermined
    }
    
    @Published var username: String = "" {
        didSet {
            validateUsername()
        }
    }
    @Published var usernameState: State = .undetermined
    
    private func validateUsername() {
        if username.count < 4 {
            usernameState = .error(message: "Username is too short")
        } else if username.count > 16 {
            usernameState = .error(message: "Username is too long")
        } else if username.contains(" ") {
            usernameState = .error(message: "Username must not contain space")
        } else if username.isEmpty {
            usernameState = .undetermined
        } else {
            usernameState = .valid
        }
    }
}
