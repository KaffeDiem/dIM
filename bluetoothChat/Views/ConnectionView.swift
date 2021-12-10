//
//  ConnectionView.swift
//  bluetoothChat
//
//  Created by Kasper Munch on 23/08/2021.
//

import SwiftUI

struct ConnectionView: View {
    @EnvironmentObject var bluetoothManager: ChatBrain
    
    var body: some View {
        Text(bluetoothManager.discoveredDevices.count > 0 ? "\(bluetoothManager.discoveredDevices.count) connected device\(bluetoothManager.discoveredDevices.count > 1 ? "s" : ""). You should be connected to the outside world." : "No devices available.")
            .padding()
    }
}
