//
//  MessageQueueHandler.swift
//  bluetoothChat
//
//  Created by Kasper Munch on 17/09/2021.
//

import Foundation
import CoreBluetooth

extension ChatBrain {
    
    struct queuedMessage {
        let message: Message
        let date: Date
    }
    
    /*
     Add a new message to the queue of messages for later delivery.
     Messages are stored for 24h.
     */
    func messageQueueAdd(_ message: Message) {
        let queuedMessage = queuedMessage(message: message, date: Date())
        messageQueue.append(queuedMessage)
    }
    
    /*
     Remove messages older than 24h from the queue.
     */
    func checkMessageQueue() {
        var removedMessages: Int = 0
        /*
         Loop trough messages in the messageQueue removing those
         older than 15 minutes.
         Once we hit a message less than 15 minutes we break the loop
         as there are no reason to continue then.
         */
        for (index, message) in messageQueue.enumerated() {
            if message.date.timeIntervalSinceNow < -900 {
                messageQueue.remove(at: index-removedMessages)
                removedMessages += 1
            } else {
                break
            }
        }
    }
    
    /*
     When a new device is connected to ours we sync the message queue
     between the devices.
     */
    func messageQueueNewConnection(_ central: CBCentral) {
        // Update message queue and remove old messages. 
        checkMessageQueue()
        
        for message in messageQueue {
            do {
                let encoded = try JSONEncoder().encode(message.message)
                
                /*
                 Send all messages which are queued again when a new device connects.
                 */
                peripheralManager.updateValue(encoded, for: characteristic!, onSubscribedCentrals: [central])
            } catch {
                print("Error encoding queued message: \(error)")
            }
        }
    }
}
