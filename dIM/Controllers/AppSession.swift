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
    
    /// The initialiser for the AppSession.
    /// Sets up the `centralManager` and the `peripheralManager`.
    /// - Parameter context: The context for persistent storage to `CoreData`
    init(context: NSManagedObjectContext) {
        self.context = context
        
        super.init()
        
        // Set up the central and peripheral manager objects to be used across the app.
        centralManager = CBCentralManager(delegate: self, queue: nil)
        peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
        
        centralManager.delegate = self
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
    
    public func handleScan(result: String) {
        let component = result.components(separatedBy: "//")
        
        guard component.count == 3 else {
            print("QR code error: Format of scanned QR code is wrong.")
            return
        }
        
        let name = component[1]
        let publicKey = component[2]
        
        let fetchRequest: NSFetchRequest<ConversationEntity>
        fetchRequest = ConversationEntity.fetchRequest()
        
        do {
            // Get existing conversation from CoreData
            let conversations = try context.fetch(fetchRequest)
            
            // Return if user has been added already
            if conversations.contains(where: { $0.author == name }) {
                return
            }
        } catch {
            print("No previously added contacts. Adding first.")
        }
        
        // Create a new conversation with the scanned user
        let conversation = ConversationEntity(context: context)
        conversation.author = name
        conversation.publicKey = publicKey
        
        do {
            try context.save()
        } catch {
            fatalError("Could not save recently scanned user")
        }
    }
}
