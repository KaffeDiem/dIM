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
