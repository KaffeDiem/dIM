//
//  GLOBALS.swift
//  bluetoothChat
//
//  Created by Kasper Munch on 26/11/2021.
//

/*
 These globals are used for debugging and testing new features
 against older ones.
 */

import Foundation

/*
 Enable the message queue, which is the feature that allows your messages
 to be delivered by others if you are not in range of receipent.
 */
let enableMessageQueue = false

/*
 Use Dynamic Source Routing algorithm for routing ACK messages.
 */
let useDSRAlgorithm = true
