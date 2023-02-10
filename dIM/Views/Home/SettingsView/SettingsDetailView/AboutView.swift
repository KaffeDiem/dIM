//
//  AboutView.swift
//  bluetoothChat
//
//  Created by Kasper Munch on 16/10/2021.
//

import SwiftUI
import Foundation
import MessageUI

/// Shows some text together with an `Image`.
struct FeatureCell: View {
    var image: Image
    var title: String
    var subtitle: String
    
    var body: some View {
        HStack(spacing: 24) {
            image
                .resizable()
                .scaledToFit()
                .foregroundColor(.accentColor)
                .symbolRenderingMode(.hierarchical)
                .frame(width: 32, alignment: .leading)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                // Using `.init(:_)` to render Markdown links for iOS 15+
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
    @State private var emailHelperAlertIsShown = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                FeatureCell(image: Image("appiconsvg"), title: "About dIM", subtitle: "dIM is an open-source decentralized chat app based on Bluetooth.")
                FeatureCell(image: Image(systemName: "network"), title: "Peer-to-peer network", subtitle: "When you send a message to someone, it will go through a peer-to-peer Bluetooth network made up of other dIM users.")
                FeatureCell(image: Image(systemName: "chevron.left.forwardslash.chevron.right"), title: "Open-Source", subtitle: "The source code of dIM is publicly available. This allow developers to verify and improve dIM to be the best and most secure decentralized messenger available. You can [view the Github repository here](https://github.com/KaffeDiem/dIM).")
                FeatureCell(image: Image(systemName: "lock.circle"), title: "Encrypted and private", subtitle: "Messages are encrypted so that only you and the receiver can read them, protecting you from prying eyes.")
                FeatureCell(image: Image(systemName: "bubble.left.and.bubble.right"), title: "Feedback is welcome", subtitle: "You can reach out to us by sending us an email or [visiting our website](https://www.dimchat.org).")
                    .padding(.bottom, 20)
                
                Button {
                    if !EmailHelper.shared.sendEmail(subject: "dIM Support or Feedback", body: "", to: "support@dimchat.org") {
                        emailHelperAlertIsShown = true
                    }
                } label: {
                    Text("Email")
                }
                .padding(.bottom, 20)
                
                HStack {
                    Spacer()
                    Text("v\(Bundle.main.releaseVersionNumber ?? "")b\(Bundle.main.buildVersionNumber ?? "")")
                        .foregroundColor(.gray)
                        .font(.footnote)
                }
            }
        }
        .padding(20)
        .navigationTitle("Decentralized Instant Messenger")
        .navigationBarTitleDisplayMode(.inline)
        .alert("No default mail set", isPresented: $emailHelperAlertIsShown) {
            Button("OK", role: .cancel) { () }
        } message: {
            Text("Set a default mailbox to send an email or use your favorite mail provider and contact us at support@dimchat.org")
        }
    }
}

struct AboutView_Previews: PreviewProvider {
    static var previews: some View {
        AboutView()
    }
}

/// An email helper class which allows us to send emails in the support section of
/// the settings view.
fileprivate class EmailHelper: NSObject, MFMailComposeViewControllerDelegate {
    /// The EmailHelper static object.
    public static let shared = EmailHelper()
    private override init() {}
    
    /// Send an email by using the built in email app in iOS.
    ///
    /// Should show a pop-up in the future if the default mail has not been set.
    /// - Parameters:
    ///   - subject: The subject field for the email.
    ///   - body: The text in the body of the email.
    ///   - to: The receiving email address.
    /// - Returns: A boolean confirming that a default email has been set up.
    func sendEmail(subject:String, body:String, to:String) -> Bool {
        if !MFMailComposeViewController.canSendMail() {
            print("No mail account found")
            return false
        }
        
        let picker = MFMailComposeViewController()
        
        picker.setSubject(subject)
        picker.setMessageBody(body, isHTML: true)
        picker.setToRecipients([to])
        picker.mailComposeDelegate = self
        
        EmailHelper.getRootViewController()?.present(picker, animated: true, completion: nil)
        return true
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        EmailHelper.getRootViewController()?.dismiss(animated: true, completion: nil)
    }
    
    static func getRootViewController() -> UIViewController? {
        (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.window?.rootViewController
    }
}
