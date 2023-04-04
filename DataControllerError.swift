//
//  DataControllerError.swift
//  dIM
//
//  Created by Kasper Munch on 04/04/2023.
//

import Foundation

public enum DataControllerError: Error, LocalizedError {
    case bluetoothTurnedOff
    case sentEmptyMessage
    case noConnectedDevices
    case wrongDataFormat
    case unknown
    
    public var errorDescription: String? {
        switch self {
        case .bluetoothTurnedOff:
            return NSLocalizedString("You should turn Bluetooth on.", comment: "Bluetooth off")
        case .sentEmptyMessage:
            return NSLocalizedString("You cannot send empty messages.", comment: "No message text")
        case .noConnectedDevices:
            return NSLocalizedString("There are no connected devices.", comment: "No connection")
        case .wrongDataFormat:
            return NSLocalizedString("The message included invalid characters. Try another message.", comment: "JSON serialization failed")
        default:
            return NSLocalizedString("An unknown error has occured in the DataController.", comment: "Unknown error")
        }
    }
}
