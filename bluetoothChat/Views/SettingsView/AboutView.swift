//
//  AboutView.swift
//  bluetoothChat
//
//  Created by Kasper Munch on 16/10/2021.
//

import SwiftUI

/// The `About` section in the `SettingsView`.
/// This is the small **dim** icon in the top of the settings as well as the description.
struct AboutView: View {
    var body: some View {
        /*
         dIM Icon in top of settings view.
         */
        GroupBox(label: Text("Decentralized Instant Messenger"), content: {
            Divider().padding(.vertical, 4)
            HStack {
                Image("appiconsvg")
                    .resizable()
                    .frame(width: 96, height: 96, alignment: .leading)
                    .aspectRatio(contentMode: .fit)
                    .scaledToFit()
                Spacer()
                
                    
                Text("""
                    dIM is a decentralized chat app based on Bluetooth. If you send a contact a message it will be sent on the Bluetooth peer-to-peer network. Messages are encrypted such that only you and the receiver can read the content.
                    """
                )
                    .foregroundColor(.gray)
                    .font(.footnote)
                    .padding(.leading)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        })
            .padding(EdgeInsets(top: 2, leading: 8, bottom: 2, trailing: 8))
    }
}
