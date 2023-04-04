//
//  DataController.swift
//  dIM
//
//  Created by Kasper Munch on 12/02/2023.
//

import Foundation
import CoreBluetooth
import UIKit
import SwiftUI

public protocol DataController {}

/// The Service struct keeps information that we may need across
/// the app. This includes the UUID of the apps Bluetooth service
/// as well as the Characteristics UUID.
public struct Session {
    /// Name of the device.
    static let deviceName = UIDevice.current.name
    /// Bluetooth service UUID
    static let UUID = CBUUID(string: "D6B52A44-E586-4502-9F98-4799C8B95C86")
    /// The unique UUID of the characteristic (the chat functionality part)
    static let characteristicsUUID = CBUUID(string: "54C89B72-F7EE-4A0A-8382-7367C3E151A5")
    /// Core Data Context for reading and saving to persistent storage.
//    static let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
}

/// Type of object sent between devices
public struct Message: Codable, Identifiable {
    public enum Kind: Int, Codable {
        /// Regular message
        case regular = 0
        /// Acknowledge that the message has been received. This is sent back to the sender
        /// of a message if the message was successfully delivered and decrypted.
        case acknowledgement = 1
        /// Read message kind which allows users to know that their sent message has been read.
        /// This is only used if the feature has been enabled in settings.
        case read = 2
    }
    
    public var id: Int32
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
