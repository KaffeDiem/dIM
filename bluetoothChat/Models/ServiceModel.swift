//
//  ServiceModel.swift
//  bluetoothChat
//
//  Created by Kasper Munch on 23/08/2021.
//

import Foundation
import CoreBluetooth
import UIKit

/// The Service struct keeps information that we may need across
/// the app. This includes the UUID of the apps Bluetooth service
/// as well as the Characteristics UUID.
struct Session {
    static let deviceName = UIDevice.current.name
    
    /**
     The UUID uniqely verifies this app as to make sure that we do not
     send bluetooth messages to the wrong device.
     */
    static let UUID = CBUUID(string: "D6B52A44-E586-4502-9F98-4799C8B95C86")
    /// The unique UUID of the characteristic (the chat functionality part)
    static let characteristicsUUID = CBUUID(string: "54C89B72-F7EE-4A0A-8382-7367C3E151A5")
    /// Core Data Context for reading and saving to persistent storage.
    static let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
}
