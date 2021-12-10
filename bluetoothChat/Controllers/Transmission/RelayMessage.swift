//
//  RelayMessage.swift
//  bluetoothChat
//
//  Created by Kasper Munch on 27/08/2021.
//

import Foundation
import CoreBluetooth

/*
 Takes care of routing messages forward which are not meant
 for this client.
 */

extension ChatBrain {
    
    // MARK: Relay messages functionality.
    
    /// Relay a message which we have received and is not for us.
    ///
    /// This function simply sends all received messages not for us to all
    /// connected servers (central managers).
    /// - Parameter message: The message to relay still in its encrypted format.
    func relayMessage(_ message: Message) {
        
        if let characteristic = self.characteristic {
            do {
                let encodedMessage = try JSONEncoder().encode(message)
                peripheralManager.updateValue(encodedMessage, for: characteristic, onSubscribedCentrals: nil)
                
                if enableMessageQueue {
                    /*
                     Add to message queue for later delivery.
                     */
                    messageQueueAdd(message)
                }
                
                routedCounter += 1
            } catch {
                print("Error encoding message: \(error)")
            }
        }
    }
    
    /*
     Used for DSR algorithm
     */
    /// Relay message but to be used for `DSR` routing.
    /// Therefore we require a specific Bluetooth ID to send the send the message to.
    ///
    /// - Note: This function is only used for `ACK` messages currently.
    /// - Parameters:
    ///   - message: The message to send.
    ///   - bluetoothID: The BluetoothID to send it to (a UUID as a string).
    func relayMessage(_ message: Message, _ bluetoothID: String) {
        if let characteristic = self.characteristic {
            do {
                let encodedMessage = try JSONEncoder().encode(message)
                
                var receivingCentral: CBCentral?
                for central in seenCBCentral {
                    if central.identifier.uuidString == bluetoothID {
                        receivingCentral = central
                        continue
                    }
                }
                if receivingCentral == nil { // If the central has not been seen then flood
                    relayMessage(message)
                    return
                }
                
                print("ACK Message: Sent to specific user")
                peripheralManager.updateValue(encodedMessage, for: characteristic, onSubscribedCentrals: [receivingCentral!])
                
                if enableMessageQueue {
                    /*
                     Add to message queue for later delivery.
                     */
                    messageQueueAdd(message)
                }
                
                routedCounter += 1
            } catch {
                print("Error encoding message: \(error)")
            }
        }
    }
}
