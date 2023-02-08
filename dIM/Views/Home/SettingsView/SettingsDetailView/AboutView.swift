//
//  AboutView.swift
//  bluetoothChat
//
//  Created by Kasper Munch on 16/10/2021.
//

import SwiftUI
import Foundation

/// Shows some text together with an `Image`.
struct FeatureCell: View {
    var image: Image
    var title: String
    var subtitle: String
    
    var body: some View {
        HStack(spacing: 24) {
            image
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 32)
                .foregroundColor(.accentColor)
                .symbolRenderingMode(.hierarchical)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                /// Using `.init(:_)` to render Markdown links for iOS 15+
                Text(.init(subtitle))
                    .foregroundColor(.secondary)
                    .font(.subheadline)
            }
        }
    }
}

/// The `About` section in the `SettingsView`.
/// This is the small **dim** icon in the top of the settings as well as the description.
struct AboutView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                FeatureCell(image: Image("appiconsvg"), title: "About dIM", subtitle: "dIM is a decentralized chat app based on Bluetooth.")
                FeatureCell(image: Image(systemName: "network"), title: "Peer-to-peer network", subtitle: "When you send a message to someone, it will go through a peer-to-peer Bluetooth network made up of other dIM users.")
                FeatureCell(image: Image(systemName: "chevron.left.forwardslash.chevron.right"), title: "Open-Source", subtitle: "The source code of dIM is publicly available. This allow developers to verify and improve dIM to be the best and most secure decentralized messenger available. You can [view the Github repository here](https://github.com/KaffeDiem/dIM).")
                FeatureCell(image: Image(systemName: "lock.circle"), title: "Encrypted and private", subtitle: "Messages are encrypted so that only you and the receiver can read them, protecting you from prying eyes.")
                FeatureCell(image: Image(systemName: "bubble.left.and.bubble.right"), title: "Feedback is welcome", subtitle: "You can reach out to us by sending us an email or [visiting our website](https://www.dimchat.org).")
            }
            .padding([.top, .bottom], 50)
            .padding([.leading, .trailing], 20)
            .navigationTitle("Decentralized Instant Messenger")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct AboutView_Previews: PreviewProvider {
    static var previews: some View {
        AboutView()
    }
}
