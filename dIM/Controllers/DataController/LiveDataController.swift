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

protocol DataControllerDelegate: AnyObject {
    func didReceiveAndSaveMessage(_ dataController: DataController, message: LocalMessage)
    func didFail(_ dataController: DataController, error: String)
    func didFail(_ dataController: DataController, error: Error)
}

class LiveDataController: NSObject, DataController {
    private let context: NSManagedObjectContext
    
    private let central: CBCentralManager
    private let peripheral: CBPeripheralManager
    
    private let usernameValidator = UsernameValidator()
    private var usernameWithDigits: String?
    
    weak var delegate: DataControllerDelegate?
    
    private var previouslySeenMessages = [Int32]()
    
    private var cancellables = Set<AnyCancellable>()
    
    init(context: NSManagedObjectContext) {
        self.central = CBCentralManager(delegate: nil, queue: nil)
        self.peripheral = CBPeripheralManager(delegate: nil, queue: nil)
        self.context = context
        super.init()
        
        central.delegate = self
        peripheral.delegate = self
        
        self.usernameWithDigits = usernameValidator.userInfo?.asString
        
        setupBindings()
        start()
    }
    
    /// Begin scanning for other devices and publish this device
    private func start() {
        central.scanForPeripherals(
            withServices: [Session.UUID],
            options: [CBCentralManagerScanOptionAllowDuplicatesKey: true])
        
        peripheral.startAdvertising([
            CBAdvertisementDataServiceUUIDsKey: [Session.UUID],
            CBAdvertisementDataLocalNameKey: UsernameValidator().userInfo?.name ?? "-"
        ])
    }
    
    private func setupBindings() {
        usernameValidator.$userInfo.sink { [weak self] userInfo in
            if let usernameWithDigits = userInfo?.asString {
                self?.usernameWithDigits = usernameWithDigits
            }
        }.store(in: &cancellables)
    }
    
    private func retrieve(encryptedMessage: Message) {
        context.perform { [weak self] in
            guard let self else { return }
            do {
                let fetchRequest = ConversationEntity.fetchRequest()
                let conversations = try fetchRequest.execute()
                let conversation = conversations
                    .first(where: { $0.author == encryptedMessage.sender })
                // Conversation to add the message to
                guard let conversation else {
                    self.delegate?.didFail(self, error: "Message received but sender is not added as contact")
                    return
                }
                
                let decryptedMessageText = self.decryptMessageToText(
                    message: encryptedMessage,
                    conversation: conversation)
                
                guard let decryptedMessageText else {
                    self.delegate?.didFail(self, error: "Did receive message but could not decrypt")
                    return
                }
                
                guard let usernameWithDigits = self.usernameWithDigits else {
                    self.delegate?.didFail(self, error: "Could not get current username with digits while receiving message")
                    return
                }
                
                let date = Date()
                
                let localMessage = LocalMessage(
                    id: encryptedMessage.id,
                    sender: encryptedMessage.sender,
                    receiver: usernameWithDigits,
                    text: decryptedMessageText,
                    date: date,
                    status: .received)
                
                let messageEntity = MessageEntity(context: self.context)
                messageEntity.id = localMessage.id
                messageEntity.receiver = localMessage.receiver
                messageEntity.sender = localMessage.sender
                messageEntity.status = localMessage.status.rawValue
                messageEntity.text = localMessage.text
                messageEntity.date = localMessage.date
                
                conversation.addToMessages(messageEntity)
                conversation.lastMessage = decryptedMessageText
                conversation.date = Date()
                
                self.delegate?.didReceiveAndSaveMessage(self, message: localMessage)
                
                try self.context.save()
            } catch {
                self.delegate?.didFail(self, error: "Could not fetch conversations from CoreData")
            }
        }
    }
    
    private func relay(encryptedMessage: Message) {
        
    }
}

// MARK: Helpers
extension LiveDataController {
    private func decryptMessageToText(message: Message, conversation: ConversationEntity) -> String? {
        let senderPublicKey = try! CryptoHandler.importPublicKey(conversation.publicKey!)
        let symmetricKey = try! CryptoHandler.deriveSymmetricKey(privateKey: CryptoHandler.getPrivateKey(), publicKey: senderPublicKey)
        return CryptoHandler.decryptMessage(text: message.text, symmetricKey: symmetricKey)
    }
}

// MARK: Send messages
extension LiveDataController {
    func send(text message: String, conversation: ConversationEntity) {
        
    }
}

// MARK: CBCentralManagerDelegate
// CBCentralManager handles discovering other devices and connecting to them.
extension LiveDataController: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .poweredOn:
            central.scanForPeripherals(withServices: [Session.UUID])
        default:
            delegate?.didFail(self, error: "Bluetooth must be turned on")
        }
    }
    
    func centralManager(
        _ central: CBCentralManager,
        didDiscover peripheral: CBPeripheral,
        advertisementData: [String : Any],
        rssi RSSI: NSNumber
    ) {
        let name = advertisementData[CBAdvertisementDataLocalNameKey] as? String
        // Connect to a peripheral device only if it is not already connected.
        switch peripheral.state {
        case .connected, .connecting:
            ()
        default:
            central.connect(peripheral)
        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        peripheral.delegate = self
        peripheral.discoverServices([Session.UUID])
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        ()
    }
    
    func centralManager(
        _ central: CBCentralManager,
        didFailToConnect peripheral: CBPeripheral,
        error: Error?
    ) {
        /*
         Try to connect again once and then stop?
         */
        
        if let error {
            delegate?.didFail(self, error: error)
        }
    }
}

// MARK: CBPeripheralDelegate
extension LiveDataController: CBPeripheralDelegate {
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let error {
            delegate?.didFail(self, error: error)
            return
        }
        
        peripheral.services?.forEach { service in
            peripheral.discoverCharacteristics([Session.characteristicsUUID], for: service)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if let error {
            delegate?.didFail(self, error: error)
            return
        }
        
        service.characteristics?.forEach { characteristic in
            if characteristic.uuid == Session.characteristicsUUID {
                peripheral.setNotifyValue(true, for: characteristic)
            }
        }
    }
    
    func peripheral(
        _ peripheral: CBPeripheral,
        didUpdateNotificationStateFor characteristic: CBCharacteristic,
        error: Error?
    ) {
        ()
    }
    
    func peripheral(
        _ peripheral: CBPeripheral,
        didUpdateValueFor characteristic: CBCharacteristic,
        error: Error?
    ) {
        if let error {
            delegate?.didFail(self, error: error)
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
            
            let messageIsForMe = encryptedMessage.receiver == usernameWithDigits
            if messageIsForMe {
                #warning("Receive message for me")
            } else {
                #warning("Relay message")
            }
        } catch {
            delegate?.didFail(self, error: error)
        }
    }
}

// MARK: CBPeripheralManagerDelegate
// CBCentralManager handles being discovered by other devices and connecting to them.
extension LiveDataController: CBPeripheralManagerDelegate {
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        ()
    }
    
//    func periphemana
}
