//
//  DiscoverView.swift
//  bluetoothChat
//
//  Created by Kasper Munch on 25/08/2021.
//

import SwiftUI

struct DiscoverView: View {
    @EnvironmentObject var chatBrain: ChatBrain
    
    var body: some View {
        VStack {
            Text("Send a message to a nearby device.")
                .padding(.top)
                .padding(.leading)
                .padding(.trailing)
            
            List(chatBrain.discoveredDevices, id: \.uuid) {device in
                HStack {
                    Button(action: {
                        chatBrain.sendData(message: "Has started a conversation!")
                    }, label: {
                        Text(device.name)
                            .padding()
                    })
                    Spacer()
                    Text("\(device.rssi)")
                        .font(.footnote)
                        .padding()
                }
            }
            .navigationBarTitle("Discover", displayMode: .inline)
        }
        .onAppear() {
            // Update the RSSI of the discoveredDevices when the list appears.
            for device in chatBrain.discoveredDevices {
                device.peripheral.readRSSI()
            }
        }
    }
}
