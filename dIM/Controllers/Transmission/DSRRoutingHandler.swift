//
//  DSRRoutingHandler.swift
//  bluetoothChat
//
//  Created by Kasper Munch on 26/11/2021.
//

import Foundation

/*
 Notice that these functions are only called if 'useDSRAlgortihm' is
 set to true in GLOBALS.swift as it is an experimental feature.
 */
extension AppSession {
    
    // MARK: DSR (Dynamic Source Routing) functionality
    
    /// Add a message to the dicitionary when it is received.
    ///
    /// This is to ensure that we have knowledge of where a message came from
    /// to send back `ACK` messages the shortest route possible.
    /// - Parameters:
    ///   - messageID: The id of the message to keep track of.
    ///   - bluetoothID: The id of the sender of the message to save.
    func addMessageToDSRTable(messageID: Int32, bluetoothID: String) {
        // Check that the message has not already been added
        guard senderOfMessageID[messageID] == nil else { return }
        senderOfMessageID[messageID] = bluetoothID
    }
    
    /// Check if we have seen a message before. If we have not we will
    /// flood the network.
    /// - Parameter messageID: The id of the message to check.
    /// - Returns: A boolean to confirm if we have seen the message before.
    func checkMessageSeenBefore(messageID: Int32) -> Bool {
        return senderOfMessageID[messageID] != nil
    }
    
    /// Get the sender of a message given a message id.
    /// - Parameter messageID: The message id to check for.
    /// - Returns: The Bluetooth UUID as a string.
    func getSenderOfMessage(messageID: Int32) -> String {
        return senderOfMessageID[messageID]!
    }
}
