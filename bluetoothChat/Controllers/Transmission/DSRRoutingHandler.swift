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
extension ChatBrain {
    /*
     Add a message to the dictionary when it is received. Only do this
     the first time that a message has been received.
     */
    func addMessageToDSRTable(messageID: Int32, bluetoothID: String) {
        // Check that the message has not already been added
        guard senderOfMessageID[messageID] == nil else { return }
        
        senderOfMessageID[messageID] = bluetoothID
    }
    
    /*
     Check if the message ID has been seen before, otherwise it will
     use flooding
     */
    func checkMessageSeenBefore(messageID: Int32) -> Bool {
        return senderOfMessageID[messageID] != nil
    }
    
    /*
     Return the sender of the original message based on an ID
     */
    func getSenderOfMessage(messageID: Int32) -> String {
        return senderOfMessageID[messageID]!
    }
}
