//
//  ConnectivityView.swift
//  bluetoothChat
//
//  Created by Kasper Munch on 16/10/2021.
//

import SwiftUI

/// The connectivityView is used for showing the user current connections.
///
/// It also shows a few statistics for this session.
struct ConnectivityView: View {
    /// The ChatBrain object is used to get statistics and current connections.
    @EnvironmentObject var chatBrain: ChatBrain
    
    var body: some View {
        GroupBox(label: Text("Connectivity"), content: {
            
            Divider().padding(.vertical, 4)
            
            Text("At least one device connected is needed to send and receive messages.")
                .font(.footnote)
                .foregroundColor(.gray)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            if chatBrain.discoveredDevices.count < 1 {
                Label("Not connected.", systemImage: "figure.stand")
                    .padding(EdgeInsets(top: 4, leading: 0, bottom: 4, trailing: 0))
            } else {
                Label(
                    "\(chatBrain.discoveredDevices.count) device\(chatBrain.discoveredDevices.count == 1 ? "" : "s") connected.",
                    systemImage: "figure.stand.line.dotted.figure.stand"
                )
                    .padding(EdgeInsets(top: 4, leading: 0, bottom: 4, trailing: 0))
            }
            
            Text("Messages sent trough your phone to be delivered to others.")
                .font(.footnote)
                .foregroundColor(.gray)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Label("\(chatBrain.routedCounter) messages routed.", systemImage: "network")
                .padding(EdgeInsets(top: 4, leading: 0, bottom: 4, trailing: 0))
        })
    }
}
