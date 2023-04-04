//
//  DataController.swift
//  dIM
//
//  Created by Kasper Munch on 12/02/2023.
//

import Foundation
import CoreData
import CoreBluetooth
import Combine
import CryptoController

public enum DataControllerError: Error, LocalizedError {
    case bluetoothTurnedOff
    case sentEmptyMessage
    case noConnectedDevices
    case unknown
    
    public var errorDescription: String? {
        switch self {
        case .bluetoothTurnedOff:
            return NSLocalizedString("You should turn Bluetooth on.", comment: "Bluetooth off")
        case .sentEmptyMessage:
            return NSLocalizedString("You cannot send empty messages.", comment: "No message text")
        case .noConnectedDevices:
            return NSLocalizedString("There are no connected devices.", comment: "No connection")
        default:
            return NSLocalizedString("An unknown error has occured in the DataController.", comment: "Unknown error")
        }
    }
}

public protocol DataControllerDelegate: AnyObject {
    func dataController(_ dataController: DataController, isConnectedTo deviceAmount: Int)
    func dataController(_ dataController: DataController, didReceive encryptedMessage: Message)
    func dataController(_ dataController: DataController, didReceiveAcknowledgement message: Message)
    func dataController(_ dataController: DataController, didReceiveRead message: Message)
    func dataController(_ dataController: DataController, didFailWith error: Error)
    func dataControllerDidRelayMessage(_ dataController: DataController)
}

/// The responsibility of the DataController is to handle all Bluetooth related
/// communication. All implementation details should be hidden from the outside,
/// so much that we would not care if Bluetooth was used.
/// The DataController communicates back through simple delegate methods, as such
/// one should implement the ``DataControllerDelegate``.
public class LiveDataController: NSObject, DataController {
    private let centralManager: CBCentralManager
    private let peripheralManager: CBPeripheralManager
    
    /// CoreBluetooth requires a reference to connected peripherals.
    private var disoveredPeripherals: [CBPeripheral] = []
    
    public weak var delegate: DataControllerDelegate?
    
    /// A list of previously seen messages used to not send messages repeatedly.
    private var previouslySeenMessages = [Int32]()
    
    private let characteristic: CBMutableCharacteristic
    private let service: CBMutableService
    
    /// Developer is responsible for keeping this username updated.
    public var username: String = ""
    
    public override init() {
        self.centralManager = CBCentralManager(delegate: nil, queue: .main)
        self.peripheralManager = CBPeripheralManager(delegate: nil, queue: nil)
        self.characteristic = CBMutableCharacteristic(
            type: Session.characteristicsUUID,
            properties: [.write, .notify],
            value: nil,
            permissions: [.writeable, .readable])
        self.service = CBMutableService(type: Session.UUID, primary: true)
        self.service.characteristics = [characteristic]
        
        super.init()
        
        centralManager.delegate = self
        peripheralManager.delegate = self
    }
    
    /// Send a message to another dIM user.
    /// - Parameters:
    ///   - text: The message text.
    ///   - conversation: The conversation, which holds necessary information for sending a message.
    /// - Returns: The sent message.
    public func send(_ text: String, to receiver: String, publicKey: String, from username: String) throws -> Message {
        guard !text.isEmpty else {
            throw DataControllerError.sentEmptyMessage
        }
        guard centralManager.retrieveConnectedPeripherals(withServices: [service.uuid]).count > 0 else {
            throw DataControllerError.noConnectedDevices
        }
        
        let privateKey = try CryptoController.fetchPrivateKey()
        let receiverPublicKey = try CryptoController.convertPublicKeyStringToKey(publicKey)
        let symmetricKey = try CryptoController.deriveSymmetricKey(privateKey: privateKey, publicKey: receiverPublicKey)
        let encryptedText = try CryptoController.encryptMessage(
            text: text, symmetricKey: symmetricKey)
        
        let messageId = Int32.random(in: 0...Int32.max)
        let encryptedMessage = Message(
            id: messageId,
            kind: .regular,
            sender: username,
            receiver: receiver,
            text: encryptedText
        )
        
        // Send the encrypted message to all connected peripherals
        do {
            let messageEncoded = try JSONEncoder().encode(encryptedMessage)
            self.peripheralManager.updateValue(messageEncoded, for: characteristic, onSubscribedCentrals: nil)
        } catch {
            throw error
        }
        
        // Return the unencrypted sent message.
        return Message(
            id: messageId,
            kind: .regular,
            sender: username,
            receiver: receiver,
            text: text
        )
    }
    
    public func sendAcknowledgementOrRead(message: Message) throws {
        previouslySeenMessages.append(message.id)
        let messageEncoded = try JSONEncoder().encode(message)
        peripheralManager.updateValue(
            messageEncoded,
            for: characteristic,
            onSubscribedCentrals: nil)
    }
}

// MARK: CBCentralManagerDelegate
// CBCentralManager handles discovering other devices and connecting to them.
extension LiveDataController: CBCentralManagerDelegate {
    public func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .poweredOn:
            centralManager.scanForPeripherals(withServices: [Session.UUID], options: [CBCentralManagerScanOptionAllowDuplicatesKey: true])
        default:
            delegate?.dataController(self, didFailWith: DataControllerError.bluetoothTurnedOff)
        }
    }
    
    public func centralManager(
        _ central: CBCentralManager,
        didDiscover peripheral: CBPeripheral,
        advertisementData: [String : Any],
        rssi RSSI: NSNumber
    ) {
        // Connect to a peripheral device only if it is not already connected.
        switch peripheral.state {
//        case .connected, .connecting: ()
        default:
            central.connect(peripheral)
            if !disoveredPeripherals.contains(peripheral) {
                disoveredPeripherals.append(peripheral)
            }
        }
        delegate?.dataController(self, isConnectedTo: central.retrieveConnectedPeripherals(withServices: [Session.UUID]).count)
    }
    
    public func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        peripheral.delegate = self
        peripheral.discoverServices([Session.UUID])
    }
    
    public func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        disoveredPeripherals.removeAll(where: { $0 == peripheral })
        delegate?.dataController(self, isConnectedTo: central.retrieveConnectedPeripherals(withServices: [Session.UUID]).count)
    }
    
    public func centralManager(
        _ central: CBCentralManager,
        didFailToConnect peripheral: CBPeripheral,
        error: Error?
    ) {
        disoveredPeripherals.removeAll(where: { $0 == peripheral })
        if let error {
            delegate?.dataController(self, didFailWith: error)
        }
    }
}

// MARK: CBPeripheralDelegate
extension LiveDataController: CBPeripheralDelegate {
    public func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let error {
            delegate?.dataController(self, didFailWith: error)
            return
        }
        
        peripheral.services?.forEach { service in
            peripheral.discoverCharacteristics([Session.characteristicsUUID], for: service)
        }
    }
    
    public func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if let error {
            delegate?.dataController(self, didFailWith: error)
            return
        }
        
        service.characteristics?.forEach { characteristic in
            if characteristic.uuid == Session.characteristicsUUID {
                peripheral.setNotifyValue(true, for: characteristic)
            }
        }
        
        delegate?.dataController(self, isConnectedTo: centralManager.retrieveConnectedPeripherals(withServices: [Session.UUID]).count)
    }
    
    public func peripheral(
        _ peripheral: CBPeripheral,
        didUpdateNotificationStateFor characteristic: CBCharacteristic,
        error: Error?
    ) {
        if let error {
            delegate?.dataController(self, didFailWith: error)
        }
    }
    
    public func peripheral(_ peripheral: CBPeripheral, didModifyServices invalidatedServices: [CBService]) {
        delegate?.dataController(self, isConnectedTo: centralManager.retrieveConnectedPeripherals(withServices: [Session.UUID]).count)
    }
    
    public func peripheral(
        _ peripheral: CBPeripheral,
        didUpdateValueFor characteristic: CBCharacteristic,
        error: Error?
    ) {
        if let error {
            delegate?.dataController(self, didFailWith: error)
            return
        }
        
        guard let data = characteristic.value else {
            return
        }
        
        do {
            let encryptedMessage = try JSONDecoder().decode(Message.self, from: data)
            // Do not continue if this message has been seen already
            guard !previouslySeenMessages.contains(encryptedMessage.id) else { return }
            previouslySeenMessages.append(encryptedMessage.id)
            
            let messageIsForMe = encryptedMessage.receiver == username
            // If message is for me receive and handle, otherwise pass it on
            if messageIsForMe {
                let messageComponents = encryptedMessage.text.components(separatedBy: "/")
                // Decide type of message and handle accordingly
                switch messageComponents.first {
                case "ACK":
                    delegate?.dataController(self, didReceiveAcknowledgement: encryptedMessage)
                case "READ":
                    delegate?.dataController(self, didReceiveRead: encryptedMessage)
                default:
                    delegate?.dataController(self, didReceive: encryptedMessage)
                }
            } else {
                // Send message to all connected peripherals
                self.peripheralManager.updateValue(data, for: self.characteristic, onSubscribedCentrals: nil)
                delegate?.dataControllerDidRelayMessage(self)
            }
        } catch {
            delegate?.dataController(self, didFailWith: error)
        }
    }
}

// MARK: CBPeripheralManagerDelegate
// CBCentralManager handles being discovered by other devices and connecting to them.
extension LiveDataController: CBPeripheralManagerDelegate {
    public func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        switch peripheral.state {
        case .poweredOn:
            peripheralManager.removeAllServices()
            peripheralManager.add(service)
            peripheralManager.startAdvertising([
                CBAdvertisementDataServiceUUIDsKey: [Session.UUID],
                CBAdvertisementDataLocalNameKey: username
            ])
        default:
            delegate?.dataController(self, didFailWith: DataControllerError.bluetoothTurnedOff)
        }
    }
    
    public func peripheralManagerDidStartAdvertising(_ peripheral: CBPeripheralManager, error: Error?) {
        if let error {
            delegate?.dataController(self, didFailWith: error)
        }
    }
}
