//
//  SendMessage.swift
//  bluetoothChat
//
//  Created by Kasper Munch on 27/08/2021.
//

import Foundation

extension ChatBrain {
    /*
     Send a string to all connected devices.
     */
    func sendMessage(for receiver: String?, text message: String) {
        
        guard message != "" else { return }
        
        if let characteristic = self.characteristic {
            
            if let receiver = receiver {
                
                let username = UserDefaults.standard.string(forKey: "Username")!
                
                let packet = Message(
                    id: Int.random(in: 0...1000),
                    sender: username,
                    receiver: receiver,
                    text: message
                )
                
                seenMessages.append(packet.id)
                
                do {
                    let messageEncoded = try JSONEncoder().encode(packet)

                    peripheralManager.updateValue(messageEncoded, for: characteristic, onSubscribedCentrals: nil)
                } catch {
                    print("Error encoding message: \(message) -> \(error)")
                }
            }
            
            else {
                print("Not yet implemented: Send message to all users.")
            }
        }
    }
}
