//
//  GLOBALS.swift
//  bluetoothChat
//
//  Created by Kasper Munch on 26/11/2021.
//

/**
 These globals are used for debugging and testing new features
 against older ones.
 They also allow the programmer to turn features on and off at need.
 */
import Foundation

/**
 Enable the message queue, which is the feature that allows your messages
 to be delivered by others if you are not in range of receipent.
 
 If a message is sent from A->B but B is not in range, however A->C is in range,
 then C travels a few miles and connects to B, such that C can deliver the message
 from A, C->B thus delivers the message from A->B without being in range of
 oneanother.
 */
let enableMessageQueue = false

/**
 Use Dynamic Source Routing algorithm for routing ACK messages.
 This reduces the traffic on the network up to ~50% for large networks. 
 */
let useDSRAlgorithm = true
