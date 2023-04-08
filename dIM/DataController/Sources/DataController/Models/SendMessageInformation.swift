//
//  File.swift
//  
//
//  Created by Kasper Munch on 04/04/2023.
//

import Foundation

public struct SendMessageInformation {
    public let id: Int32
    public let encryptedText: String
    public let receipent: String
    
    /// Information needed to send a message.
    ///
    /// Warning: Do not send unencrypted text messages. This will make the text message
    /// readable by other Bluetooth devices in the area.
    ///
    /// - Parameters:
    ///   - encryptedText: Encrypted text message to be sent to some user.
    ///   - receipent: The receipent of the text message. Usually formatted as `username#1234`
    public init(id: Int32, encryptedText: String, receipentWithDigits: String) {
        self.encryptedText = encryptedText
        self.receipent = receipentWithDigits
        self.id = id
    }
}
