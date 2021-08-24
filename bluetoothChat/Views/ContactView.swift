//
//  ContantView.swift
//  bluetoothChat
//
//  Created by Kasper Munch on 23/08/2021.
//

import SwiftUI

// The most recent thread view covering user photo, name and most recent message.
struct ContactView: View {
    var message: Message
    var BM: BluetoothManager
    
    var body: some View {
        NavigationLink(
            destination: ChatView(BM: BM),
            label: {
                HStack {
                    Image(systemName: "person")
                        .frame(width: 50, height: 50, alignment: .center)
                    
                    VStack { 
                        HStack {
                            Text(message.author)
                            Spacer()
                        }
                        HStack {
                            Text(message.text)
                                .scaledToFit()
                                .font(.footnote)
                            Spacer()
                        }
                    }
                }
            })
    }
}
