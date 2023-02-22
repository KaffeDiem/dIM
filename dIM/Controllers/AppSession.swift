//
//  BluetoothManager.swift
//  bluetoothChat
//
//  Created by Kasper Munch on 23/08/2021.
//

import Foundation
import CoreBluetooth
import SwiftUI
import CoreData
import Combine

/// The Bluetooth Manager handles all searching for, creating connection to
/// and sending/receiving messages to/from other Bluetooth devices.
///
/// This class handles almost all the logic in the app and is passed around
/// to the different views such that they all have access to the same Bluetooth
/// objects as well as conversations. When the app is launched all the information
/// is stored in memory and written to the persistent storage as needed.
/// - Note: It conforms to a variety of delegates which is used for callback functions from the Apple APIs.
/// - Note: In code the AppSession has been divided into files for seperation and isolation of features.
class AppSession: NSObject, ObservableObject, CBCentralManagerDelegate, CBPeripheralManagerDelegate, CBPeripheralDelegate {
    
    private var cancellables = Set<AnyCancellable>()
    
    @Published var bannerDataShouldShow = false
    @Published var bannerData: BannerModifier.BannerData = .init(title: "", message: "") {
        didSet {
            withAnimation(.spring()) {
                bannerDataShouldShow = true
            }
        }
    }
    
    /// Managed object context for saving to CoreData
    let context: NSManagedObjectContext
    
    /// A simple counter to show amount of relayed messages this session.
    /// It is reset when the app is force-closed or the device is restarted.
    @Published var routedCounter: Int = 0
    
    /// A UUID which is updated when a **ACK** message is retrieved. This forces
    /// a refresh of the `ChatView` and the message status is updated.
    @Published var refreshID = UUID()
    
    // Holds an array of messages to be delivered at a later point.
    // Used for the queue functionality.
    @Published var messageQueue: [queuedMessage] = []
    
    @Published private(set) var connectedDevicesAmount = 0
    
    
    // Holds a reference to all devices discovered. If no reference
    // is held then the Bluetooth connection may be dropped.
    @Published var discoveredDevices: [Device] = []
    
    /// Holds the connected characteristics. This is only used for the chat
    /// functionality for now.
    var connectedCharateristics: [CBCharacteristic] = []
    
    /// The centralManager acts as our Bluetooth server and receives messages
    /// sent by clients to the server.
    var centralManager: CBCentralManager!
    
    /// The peripheralManager acts as our Bluetooth clients and establishes
    /// connections to other BT servers. It also sends messages.
    var peripheralManager: CBPeripheralManager!
    
    /// The characteristic which defines our chat functionality for the
    /// Bluetooth API.
    var characteristic: CBMutableCharacteristic?
    
    /// Save messages which has been seen before such that they are not sent again.
    /// Otherwise they can loop around in the network forever.
    var seenMessages: [Int32] = []
    
    /// A dictionary which stores how many messages we have received from a connected peripheral.
    /// It is cleaned from time to time as well.
    var peripheralMessages: [String : [Date]] = [:]
    
    /// A dictionary which holds the ids of messages relayed and the corresponding sender
    /// of said messages. This is used for DSR.
    var senderOfMessageID: [Int32 : String] = [:]
    
    /// Seen CoreBluetooth Central devices
    var seenCBCentral: [CBCentral] = []
    
    private let dataController: LiveDataController
    private let usernameValidator = UsernameValidator()
    
    /// The initialiser for the AppSession.
    /// Sets up the `centralManager` and the `peripheralManager`.
    /// - Parameter context: The context for persistent storage to `CoreData`
    init(context: NSManagedObjectContext) {
        self.context = context
        self.dataController = LiveDataController()
        
        super.init()
        
        dataController.delegate = self
    }
    
    /// Drop connection and remove references for a peripheral device.
    /// - Parameter peripheral: Device to forget.
    func cleanUpPeripheral(_ peripheral: CBPeripheral) {
        let connected = centralManager.retrieveConnectedPeripherals(withServices: [Session.UUID])
        
        // Drop connection to a connected peripheral device
        connected
            .filter { $0 == peripheral }
            .forEach {
                centralManager.cancelPeripheralConnection($0)
            }
        
        // Remove all references to peripheral
        discoveredDevices.removeAll(where: { $0.peripheral == peripheral })
    }
    
    public func addUserFromQrScan(_ result: String) {
        do {
            try ScanHandler.retrieve(result: result, context: context)
        } catch ScanHandler.ScanHandlerError.userPreviouslyAdded {
            showBanner(.init(title: "User added", message: "User already exists.", kind: .normal))
            return
        } catch ScanHandler.ScanHandlerError.invalidFormat {
            showBanner(.init(title: "Oops", message: "The scanned QR code does not look correct.", kind: .error))
            return
        } catch {
            showErrorMessage(error.localizedDescription)
            return
        }
        showBanner(.init(title: "User added", message: "All good! The user has been added.", kind: .success))
    }
    
    func send(text message: String, conversation: ConversationEntity) {
        let messageForStorage: Message
        do {
            messageForStorage = try dataController.send(message, to: conversation)
        } catch {
            showErrorMessage(error.localizedDescription)
            return
        }
        
        // Save the message to local storage
        let localMessage = MessageEntity(context: context)
        
        localMessage.receiver = messageForStorage.receiver
        localMessage.status = Status.sent.rawValue
        localMessage.text = messageForStorage.text
        localMessage.date = Date()
        localMessage.id = messageForStorage.id
        localMessage.sender = messageForStorage.sender
        
        conversation.lastMessage = "You: " + messageForStorage.text
        conversation.date = Date()
        conversation.addToMessages(localMessage)
        
        do {
            try context.save()
        } catch {
            showErrorMessage(error.localizedDescription)
        }
    }
    
    private func showBanner(_ bannerData: BannerModifier.BannerData) {
        self.bannerData = bannerData
    }
    
    private func showErrorMessage(_ error: String) {
        showBanner(.init(title: "Something went wrong", message: error, kind: .error))
    }
    
    private func receive(encryptedMessage: Message) {
        context.perform { [weak self] in
            guard let self else { return }
            do {
                let fetchRequest = ConversationEntity.fetchRequest()
                let conversations = try fetchRequest.execute()
                let conversation = conversations
                    .first(where: { $0.author == encryptedMessage.sender })
                guard let conversation else {
                    self.showErrorMessage("Received a message for you, but the sender has not been added as a contact.")
                    return
                }

                let decryptedMessageText = self.decryptMessageToText(
                    message: encryptedMessage,
                    conversation: conversation)

                guard let decryptedMessageText else {
                    self.showErrorMessage("Received a message which could not be decrypted.")
                    return
                }

                guard let usernameWithDigits = self.usernameValidator.userInfo?.asString else {
                    self.showErrorMessage("Could not find your current username.")
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

                try self.context.save()
            } catch {
                self.showErrorMessage("Could not save newly received message.")
            }
        }
    }
}

extension AppSession: DataControllerDelegate {
    func dataController(_ dataController: DataController, isConnectedTo deviceAmount: Int) {
        connectedDevicesAmount = deviceAmount
    }
    
    func dataControllerDidRelayMessage(_ dataController: DataController) {
        routedCounter += 1
    }
    
    func dataController(_ dataController: DataController, didReceive encryptedMessage: Message) {
        receive(encryptedMessage: encryptedMessage)
    }
    
    func dataController(_ dataController: DataController, didFailWith error: Error) {
        self.showErrorMessage(error.localizedDescription)
    }
}

// MARK: Helpers
extension AppSession {
    private func decryptMessageToText(message: Message, conversation: ConversationEntity) -> String? {
        let senderPublicKey = try! CryptoHandler.importPublicKey(conversation.publicKey!)
        let symmetricKey = try! CryptoHandler.deriveSymmetricKey(privateKey: CryptoHandler.getPrivateKey(), publicKey: senderPublicKey)
        return CryptoHandler.decryptMessage(text: message.text, symmetricKey: symmetricKey)
    }
}

