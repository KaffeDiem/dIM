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

/// The responsibility of the DataController is to handle all Bluetooth related
/// communication. All implementation details should be hidden from the outside,
/// so much that we would not care if Bluetooth was used.
/// The DataController communicates back through simple delegate methods, as such
/// one should implement the ``DataControllerDelegate``.
public class LiveDataController: NSObject, DataController {
    public struct Config {
        /**
         Enable the message queue, which is the feature that allows your messages
         to be delivered by others if you are not in range of receipent.
         
         If a message is sent from A->B but B is not in range, however A->C is in range,
         then C travels a few miles and connects to B, such that C can deliver the message
         from A, C->B thus delivers the message from A->B without being in range of
         oneanother.
         */
        let enableMessageQueue: Bool
        
        /**
         Use Dynamic Source Routing algorithm for routing ACK messages.
         This reduces the traffic on the network up to ~50% for large networks.
         */
        let useDSRAlgorithm: Bool
        
        /**
         Username of the user.
         Usually formatted as `username#1234`, such that the username includes random digits.
         */
        let username: String
        
        public init(
            enableMessageQueue: Bool = true,
            useDSRAlgorithm: Bool = true,
            usernameWithRandomDigits: String
        ) {
            self.enableMessageQueue = enableMessageQueue
            self.useDSRAlgorithm = useDSRAlgorithm
            self.username = usernameWithRandomDigits
        }
    }
    
    public weak var delegate: DataControllerDelegate?
    
    private let centralManager: CBCentralManager
    private let peripheralManager: CBPeripheralManager
    
    /// CoreBluetooth requires a reference to connected peripherals.
    private var disoveredPeripherals: [CBPeripheral] = []
    
    /// A list of previously seen messages used to not send messages repeatedly.
    private var previouslySeenMessages = [Int32]()
    
    private let characteristic: CBMutableCharacteristic
    private let service: CBMutableService
    private let config: Config
    
    /// Set up the DataController with a configuration.
    ///
    /// - Warning: If the username is changed after the DataController has been initialized,
    ///           the DataController will not work as expected.
    ///           If it is changed the DataController must re-initialized.
    ///
    /// - Parameter config: Config desribing the behaviour of the DataController.
    public init(config: Config) {
        self.config = config
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
    
    public func send(message: SendMessageInformation) async throws {
        Task {
            guard !message.encryptedText.isEmpty else {
                throw DataControllerError.sentEmptyMessage
            }
            guard centralManager.retrieveConnectedPeripherals(withServices: [service.uuid]).count > 0 else {
                throw DataControllerError.noConnectedDevices
            }
            
            let encryptedMessage = Message(
                id: message.id,
                kind: .regular,
                sender: config.username,
                receiver: message.receipent,
                text: message.encryptedText)
            
            // Encode the encrypted message to JSON.
            // Send it off to all connected devices.
            do {
                let messageEncoded = try JSONEncoder().encode(encryptedMessage)
                self.peripheralManager.updateValue(messageEncoded, for: characteristic, onSubscribedCentrals: nil)
            } catch {
                throw DataControllerError.wrongDataFormat
            }
        }
    }
    
    public func sendAcknowledgementOrRead(message: Message) async throws {
        Task {
            previouslySeenMessages.append(message.id)
            let messageEncoded = try JSONEncoder().encode(message)
            peripheralManager.updateValue(
                messageEncoded,
                for: characteristic,
                onSubscribedCentrals: nil)
        }
    }
}

// MARK: CBCentralManagerDelegate
// CBCentralManager handles discovering other devices and connecting to them.
extension LiveDataController: CBCentralManagerDelegate {
    public func centralManagerDidUpdateState(_ central: CBCentralManager) {
        // Only start scanning for devices if Bluetooth is turned on.
        // Otherwise notify the delegate that Bluetooth is turned off.
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
        // One could also check if the device is already connected by checking `peripheral.state`.
        // This could save CPU usage but devices would be slower to connect. CPU usage is very low.
        central.connect(peripheral)
        if !disoveredPeripherals.contains(peripheral) {
            disoveredPeripherals.append(peripheral)
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
            
            let messageIsForMe = config.username == encryptedMessage.receiver
            // If message is for me receive and handle, otherwise pass it on
            if messageIsForMe {
                let messageComponents = encryptedMessage.text.components(separatedBy: "/")
                // Decide type of message and handle accordingly
                switch messageComponents.first {
                case Message.Kind.acknowledgement.asString:
                    delegate?.dataController(self, didReceiveAcknowledgement: encryptedMessage)
                case Message.Kind.read.asString:
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
                CBAdvertisementDataLocalNameKey: config.username
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
