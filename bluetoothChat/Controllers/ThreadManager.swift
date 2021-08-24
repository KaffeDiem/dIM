//
//  ThreadManager.swift
//  bluetoothChat
//
//  Created by Kasper Munch on 24/08/2021.
//

import Foundation
import SwiftUI

class Threads: ObservableObject {
    // Threads is a dictionary which allows lookup on an author and then
    // returns a list of the correspondance between the author and the
    // receipent.
    @Published var threads: [String : [Message]] = [:]
    
    init() {
        
    }
    
    // Add a message to a thread of the provided user.
    // Create a new thread if it is not available.
    func addToThread(user: String, message: Message) {
        if threads[user] != nil {
            self.threads[user]!.append(message)
        } else {
            threads[user] = []
            threads[user]!.append(message)
        }
    }
    
    // Return the thread for a given user if it exists.
    // Else return an empty list. 
    func getThread(user: String) -> [Message] {
        return threads[user] == nil ? [] : threads[user]!
    }
}
