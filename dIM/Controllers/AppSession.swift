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
    
    func addUserFromQrScan(_ result: String) {
        do {
            try ScanHandler.retrieve(result: result, context: context)
        } catch ScanHandler.ScanHandlerError.userPreviouslyAdded {
            showBanner(.init(title: "Oops", message: "That user has been added previously.", kind: .normal))
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
        let messageToBeStored: Message
        do {
            messageToBeStored = try dataController.send(message, to: conversation)
        } catch {
            showErrorMessage(error.localizedDescription)
            return
        }
        
        // Save the message to local storage
        let localMessage = MessageEntity(context: context)
        
        localMessage.receiver = messageToBeStored.receiver
        localMessage.status = Status.sent.rawValue
        localMessage.text = messageToBeStored.text
        localMessage.date = Date()
        localMessage.id = messageToBeStored.id
        localMessage.sender = messageToBeStored.sender
        
        conversation.lastMessage = "You: " + messageToBeStored.text
        conversation.date = Date()
        conversation.addToMessages(localMessage)
        
        do {
            try context.save()
        } catch {
            showErrorMessage(error.localizedDescription)
        }
    }
    
    func showBanner(_ bannerData: BannerModifier.BannerData) {
        self.bannerData = bannerData
    }
    
    func showErrorMessage(_ error: String) {
        showBanner(.init(title: "Something went wrong", message: error, kind: .error))
    }
}
    
// MARK: Private methods
extension AppSession {
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

                let decryptedMessageText = try self.decryptMessageToText(
                    message: encryptedMessage,
                    conversation: conversation)

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
                
                DispatchQueue.main.async {
                    self.sendAcknowledgement(of: messageEntity)
                    self.sendNotificationWith(text: localMessage.text, from: localMessage.sender)
                }
            } catch {
                self.showErrorMessage("Could not save newly received message.")
            }
        }
    }
    
    private func sendAcknowledgement(of message: MessageEntity) {
        guard let usernameWithDigits = usernameValidator.userInfo?.asString else {
            fatalError("ACK sent but username has not been set. This is not allowed.")
        }
        
        guard let receiver = message.sender else {
            fatalError("Cannot send ACK when there is no receiver. This is not allowed.")
        }
        
        let ackText = "ACK/\(message.id)"
        let ackMessage = Message(
            id: Int32.random(in: 0...Int32.max),
            kind: .acknowledgement,
            sender: usernameWithDigits,
            receiver: receiver,
            text: ackText)
        
        do {
            try dataController.sendAcknowledgement(message: ackMessage)
        } catch {
            showErrorMessage(error.localizedDescription)
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
    private func decryptMessageToText(message: Message, conversation: ConversationEntity) throws -> String {
        let publicKeyOfSender = try CryptoHandler.convertPublicKeyStringToKey(conversation.publicKey)
        let symmetricKey = try CryptoHandler.deriveSymmetricKey(privateKey: CryptoHandler.fetchPrivateKey(), publicKey: publicKeyOfSender)
        return CryptoHandler.decryptMessage(text: message.text, symmetricKey: symmetricKey)
    }
    
    /// Send a notification to the user if the app is closed and and we retrieve a message.
    /// - Parameter message: The message that the user has received.
    private func sendNotificationWith(text: String, from sender: String) {
        let content = UNMutableNotificationContent()
        content.title = sender.components(separatedBy: "#").first ?? "Maybe: \(sender)"
        content.body = text
        content.sound = UNNotificationSound.default

        let trigger = UNTimeIntervalNotificationTrigger(
            timeInterval: 0.01,
            repeats: false
        )
        
        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request)
    }
}

