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
                        // Send a 'Hello' message to start a conversation.
                        chatBrain.sendMessage(for: device.name, text: "Has started a conversation!")
                        
                    }, label: {
                        Text(device.name)
                            .padding()
                    })
                    Spacer()
                    Text("\(calculateDistance(device.rssi))m away")
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
    
    func calculateDistance(_ rssi: Int) -> Int {
        let txPower = -59
        
        if rssi == 0 {
            return -1
        }
        
        let ratio = Float(rssi)*1.0/Float(txPower)
        
        if ratio < 1.0 {
            return Int(pow(ratio, 10.0))
        }
        
        return Int((0.89976)*pow(ratio,7.709) + 0.111)
    }
}
