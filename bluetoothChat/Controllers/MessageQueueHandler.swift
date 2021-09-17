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
     */
    func messageQueueAdd(_ message: Message) {
        let queuedMessage = queuedMessage(message: message, date: Date())
        
        messageQueue.append(queuedMessage)
    }
    
    /*
     Check if there are messages in the queue older than 24 hours which
     needs to be removed from the queue.
     */
    func checkMessageQueue() {
        /*
         Check if the message exists
         */
        if let safeFirst = messageQueue.first {
            let timePassed = safeFirst.date.timeIntervalSinceNow
            print("Time since first message was added to queue: \(timePassed)")
            
            /*
             If the oldest message in the queue is older than 24 hours we
             have to clean up the queue.
             */
            // seconds in 24 hours 86400
            if timePassed < -86400 {
                // MARK: TODO clean up of message queue.
            }
        }
    }
    
    /*
     When a new device is connected to ours we sync the message queue
     between the devices.
     */
    func messageQueueNewConnection(_ central: CBCentral) {
        for message in messageQueue {
            
            guard message.date.timeIntervalSinceNow < -86400 else {
                continue
            }
            
            do {
                let encoded = try JSONEncoder().encode(message.message)
                
                /*
                 Send all messages which are queued again when a new device connects.
                 */
                peripheralManager.updateValue(encoded, for: characteristic!, onSubscribedCentrals: [central])
                messageQueue = []
                // MARK: TODO - figure out how to remove messages from the queue
            } catch {
                print("Error encoding queued message: \(error)")
            }
        }
    }
}
