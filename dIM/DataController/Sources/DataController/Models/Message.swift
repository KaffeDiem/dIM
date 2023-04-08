//
//  MessageModel.swift
//  bluetoothChat
//
//  Created by Kasper Munch on 23/08/2021.
//

import Foundation

/*
 Messages are the objects sent between devices. They are JSON encoded while sent
 across the network. There are different kinds of messages each of their own
 used to identify what type it is.
 */
public struct Message: Codable, Identifiable {
    public enum Kind: Int, Codable {
        /// Regular encrypted messages. The receipent will have to decrypt it.
        case regular = 0
        /// Acknowledment messages are sent automatically once a message has been received.
        /// Used to verify that the receipent received and successfully decrypted the message.
        case acknowledgement = 1
        /// Read message kind which allows users to know that their sent message has been read.
        /// They should not be sent per default, as it may be privacy
        case read = 2
        /// GPS is used to send GPS coordinates off to others. It is included for the possibility
        /// to optionally include it in your app.
        case gps = 3
        
        public var asString: String {
            switch self {
            case .regular:
                return "REG"
            case .acknowledgement:
                return "ACK"
            case .read:
                return "READ"
            case .gps:
                return "DIM.GPS"
            }
        }
    }
    
    public var id: Int32 // Random integer, could use a UUID in the future.
    public var kind: Kind
    public var sender: String
    public var receiver: String
    public var text: String // Note that text in the message struct is encrypted
    
    public init(id: Int32, kind: Kind, sender: String, receiver: String, text: String) {
        self.id = id
        self.kind = kind
        self.sender = sender
        self.receiver = receiver
        self.text = text
    }
    
}
