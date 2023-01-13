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
            
            Spacer()
        }
    }
}

/// The `About` section in the `SettingsView`.
/// This is the small **dim** icon in the top of the settings as well as the description.
struct AboutView: View {
    var body: some View {
        VStack {
            VStack {
                FeatureCell(image: Image("appiconsvg"), title: "About dIM", subtitle: "dIM is a decentralized chat app based on Bluetooth.")
                FeatureCell(image: Image(systemName: "network"), title: "Peer-to-peer network", subtitle: "When you send a message to someone, it will go through a peer-to-peer Bluetooth network made of other dIM users.")
                FeatureCell(image: Image(systemName: "chevron.left.forwardslash.chevron.right"), title: "Open-Source", subtitle: "The source code of dIM is available to developers to help them improve their apps and dIM. It also raises trust into dIM security. [Visit dIM's GitHub repository...](https://google.com)")
                FeatureCell(image: Image(systemName: "lock.circle"), title: "Encrypted and private", subtitle: "Messages are encrypted so that only you and the receiver can read them, protecting you from prying eyes.")
                FeatureCell(image: Image(systemName: "bubble.left.and.bubble.right"), title: "Feedback is welcome", subtitle: "You can reach out to us by [sending us an email](mailto:support@dimchat.org?subject=dIM%20Support%20or%20Feedback) or [visiting out website](https://www.dimchat.org).")
            }
            .padding()
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
