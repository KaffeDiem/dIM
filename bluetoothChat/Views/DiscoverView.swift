//
//  DiscoverView.swift
//  bluetoothChat
//
//  Created by Kasper Munch on 25/08/2021.
//

import SwiftUI

struct DiscoverView: View {
    @EnvironmentObject var bluetoothManager: BluetoothManager
    
    var body: some View {
        VStack {
            Text("Send a message to a nearby device.")
                .padding()
            
            List(bluetoothManager.discoveredPeripherals, id: \.uuid) {device in
                HStack {
                    Button(action: {
                        bluetoothManager.sendData(message: "Hello there!")
                    }, label: {
                        Text(device.name)
                    })
                    Spacer()
                    Text("\(device.rssi)")
                        .font(.footnote)
                }
            }
            .navigationBarTitle("Discover", displayMode: .inline)
        }
    }
}

struct DiscoverView_Previews: PreviewProvider {
    static var previews: some View {
        DiscoverView()
    }
}
