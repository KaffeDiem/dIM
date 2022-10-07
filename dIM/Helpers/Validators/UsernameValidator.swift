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
    
    func validate(username: String) -> State {
        if username.count < 4 {
            return .error(message: "Username is too short")
        } else if username.count > 16 {
            return .error(message: "Username is too long")
        } else if username.contains(" ") {
            return .error(message: "Username must not contain space")
        } else if username.isEmpty {
            return .undetermined
        } else {
            return .valid
        }
    }
}
