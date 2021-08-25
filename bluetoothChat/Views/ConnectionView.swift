//
//  ConnectionView.swift
//  bluetoothChat
//
//  Created by Kasper Munch on 23/08/2021.
//

import SwiftUI

struct ConnectionView: View {
    @EnvironmentObject var bluetoothManager: BluetoothManager
    
    var body: some View {
        Text(bluetoothManager.discoveredPeripherals.count > 0 ? "\(bluetoothManager.discoveredPeripherals.count) connected device\(bluetoothManager.discoveredPeripherals.count > 1 ? "s" : ""). You should be connected to the outside world." : "No devices available.")
            .padding()
    }
}


struct ConnectionView_Previews: PreviewProvider {
    static var previews: some View {
        ConnectionView()
    }
}
