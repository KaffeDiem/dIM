//
//  HomeViewModel.swift
//  bluetoothChat
//
//  Created by Kasper Munch on 01/02/2022.
//

import Foundation

class HomeViewModel: ObservableObject {
    /// Usernames have random digits attached and this function removes them.
    /// - Parameter conversation: The conversation to get the author from.
    /// - Returns: The username without random digits or nil if format is wrong.
    public func getAuthor(for conversation: ConversationEntity) -> String? {
        conversation.author?
            .components(separatedBy: "#")
            .first
    }
}
