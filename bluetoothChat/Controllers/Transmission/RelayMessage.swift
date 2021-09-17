//
//  RelayMessage.swift
//  bluetoothChat
//
//  Created by Kasper Munch on 27/08/2021.
//

import Foundation

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
                
                /*
                 Add messages that we relay to the queue of messages
                 for later delivery.
                 */
                messageQueueAdd(message)
                
                routedCounter += 1
                
            } catch {
                print("Error encoding message: \(error)")
            }
        }
        
    }

}
