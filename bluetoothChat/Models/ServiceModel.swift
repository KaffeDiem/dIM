//
//  ServiceModel.swift
//  bluetoothChat
//
//  Created by Kasper Munch on 23/08/2021.
//

import Foundation
import CoreBluetooth
import UIKit

struct Service {
    let deviceName = UIDevice.current.name
    
    /*
     The UUID uniqely verifies this app as to make sure that we do not
     send bluetooth messages to the wrong device.
     */
    
    let UUID = CBUUID(string: "D6B52A44-E586-4502-9F98-4799C8B95C86")
    // The unique uuid of the characteristic (the chat functionality)
    let charUUID = CBUUID(string: "54C89B72-F7EE-4A0A-8382-7367C3E151A5")
}
