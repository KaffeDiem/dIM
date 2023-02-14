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
    func dataController(_ dataController: DataController, didReceive encryptedMessage: Message)
    func dataController(_ dataController: DataController, didFailWith error: String)
    func dataController(_ dataController: DataController, didFailWith error: Error)
    func dataControllerDidRelayMessage(_ dataController: DataController)
}

class LiveDataController: NSObject, DataController {
    private let central: CBCentralManager
    private let peripheral: CBPeripheralManager
    
    private let usernameValidator = UsernameValidator()
    private var usernameWithDigits: String?
    
    weak var delegate: DataControllerDelegate?
    
    private var previouslySeenMessages = [Int32]()
    
    private var cancellables = Set<AnyCancellable>()
    
    private let characteristic: CBMutableCharacteristic
    private let service: CBMutableService
    
    override init() {
        self.central = CBCentralManager(delegate: nil, queue: nil)
        self.peripheral = CBPeripheralManager(delegate: nil, queue: nil)
        self.characteristic = CBMutableCharacteristic(
            type: Session.characteristicsUUID,
            properties: [.write, .notify],
            value: nil,
            permissions: [.writeable, .readable]
        )
        
        self.service = CBMutableService(type: Session.UUID, primary: true)
        self.service.characteristics = [characteristic]
        
        super.init()
        
        central.delegate = self
        peripheral.delegate = self
        peripheral.add(service)
        
        self.usernameWithDigits = usernameValidator.userInfo?.asString
        
        setupBindings()
    }
    
    private func setupBindings() {
        usernameValidator.$userInfo.sink { [weak self] userInfo in
            if let usernameWithDigits = userInfo?.asString {
                self?.usernameWithDigits = usernameWithDigits
            }
        }.store(in: &cancellables)
    }
}

// MARK: CBCentralManagerDelegate
// CBCentralManager handles discovering other devices and connecting to them.
extension LiveDataController: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .poweredOn:
            central.scanForPeripherals(
                withServices: [Session.UUID],
                options: [CBCentralManagerScanOptionAllowDuplicatesKey: true])
        default:
            delegate?.dataController(self, didFailWith: "Bluetooth must be powered on")
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
            delegate?.dataController(self, didFailWith: error)
        }
    }
}

// MARK: CBPeripheralDelegate
extension LiveDataController: CBPeripheralDelegate {
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let error {
            delegate?.dataController(self, didFailWith: error)
            return
        }
        
        peripheral.services?.forEach { service in
            peripheral.discoverCharacteristics([Session.characteristicsUUID], for: service)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if let error {
            delegate?.dataController(self, didFailWith: error)
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
            
            let messageIsForMe = encryptedMessage.receiver == usernameWithDigits
            // If message is for me receive and handle, otherwise pass it on
            if messageIsForMe {
                delegate?.dataController(self, didReceive: encryptedMessage)
            } else {
                self.peripheral.updateValue(data, for: self.characteristic, onSubscribedCentrals: nil)
            }
        } catch {
            delegate?.dataController(self, didFailWith: error)
        }
    }
}

// MARK: CBPeripheralManagerDelegate
// CBCentralManager handles being discovered by other devices and connecting to them.
extension LiveDataController: CBPeripheralManagerDelegate {
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        switch peripheral.state {
        case .poweredOn:
            peripheral.startAdvertising([
                CBAdvertisementDataServiceUUIDsKey: [Session.UUID],
                CBAdvertisementDataLocalNameKey: UsernameValidator().userInfo?.name ?? "-"
            ])
        default:
            ()
        }
    }
    
    func peripheralManagerDidStartAdvertising(_ peripheral: CBPeripheralManager, error: Error?) {
        if let error {
            delegate?.dataController(self, didFailWith: error)
        }
    }
}
