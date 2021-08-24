//
//  BluetoothManager.swift
//  bluetoothChat
//
//  Created by Kasper Munch on 23/08/2021.
//

import Foundation
import CoreBluetooth

// The Bluetooth Manager handles all searching for, creating connection to
// and sending/receiving messages to/from other Bluetooth devices.

class BluetoothManager: NSObject, ObservableObject, CBCentralManagerDelegate, CBPeripheralManagerDelegate, CBPeripheralDelegate {
    
    // Published variables are used outside of this class.
    @Published var isReady: Bool = false
    @Published var connectedPeripherals: [CBPeripheral] = []
    @Published var connectedCharateristics: [CBCharacteristic] = []
    
    // Holds all messages received from all peripherals. 
    @Published var messages: [Message] = []
    
    let service = Service()
    
    var centralManager: CBCentralManager!
    var peripheralManager: CBPeripheralManager!
    
    var characteristic: CBMutableCharacteristic?
    
    override init() {
        super.init()
        
        centralManager = CBCentralManager(delegate: self, queue: nil)
        peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
        
        centralManager.delegate = self
    }
    
    // MARK: Helper functions.
    
    // Return amount of connected devices.
    func getConnectedDevices() -> Int {
        return connectedCharateristics.count
    }
    
    // Remove a device from connected devices.
    // MARK: DOES NOT DO PROPER CLEANUP YET
    func cleanUp(_ peripheral: CBPeripheral) {
        connectedPeripherals.removeAll() { device in
            return device == peripheral
        }
        print("Remove device from connected devices.")
        
        centralManager.cancelPeripheralConnection(peripheral)
        print(centralManager.retrieveConnectedPeripherals(withServices: [self.service.UUID]))
        print("Cancelled connection to peripheral")
    }
}





