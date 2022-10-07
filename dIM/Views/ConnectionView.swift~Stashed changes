//
//  ConnectionView.swift
//  bluetoothChat
//
//  Created by Kasper Munch on 23/08/2021.
//

import SwiftUI

struct ConnectionView: View {
    let connectedDevices: Int
    
    var body: some View {
        Text(connectedDevices > 0 ? "\(connectedDevices) connected device\(connectedDevices > 1 ? "s" : ""). You should be connected to the outside world." : "No devices available.")
    }
}


struct ConnectionView_Previews: PreviewProvider {
    static var previews: some View {
        ConnectionView(connectedDevices: 1)
    }
}
