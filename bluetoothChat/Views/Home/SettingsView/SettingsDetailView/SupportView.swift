//
//  SupportView.swift
//  bluetoothChat
//
//  Created by Kasper Munch on 16/10/2021.
//

import SwiftUI
import Foundation
import MessageUI

/// The support view which contains contact information for dIM.
///
/// This is a subview of the `SettingsView.swift` view.
struct SupportView: View {
    /// A simple alert showing if the user has not set up a default email address in the
    /// default mail app.
    @State var showingAlert = false
    
    var body: some View {
        GroupBox(label: Text("Support and Feedback"), content: {
            Divider().padding(.vertical, 4)
            
            Text("Contact us by sending an email.")
                .font(.footnote)
                .foregroundColor(.gray)
                .frame(maxWidth: .infinity, alignment: .leading)
            HStack {
                Spacer()
                Link("Website", destination: URL(string: "https://www.dimchat.org")!)
                Spacer()
                Button(action: {
                    if !EmailHelper.shared.sendEmail(subject: "dIM Support or Feedback", body: "", to: "support@dimchat.org") {
                        showingAlert = true
                    }
                }, label: {
                    Text("Email")
                        .alert("You must set up a default mailbox to send emails. Otherwise emails can be sent to support@dimchat.org", isPresented: $showingAlert) {
                            Button("OK", role: .cancel) {}
                        }
                })
                Spacer()
            }
            .padding(EdgeInsets(top: 4, leading: 0, bottom: 4, trailing: 0))
        })
            .padding(EdgeInsets(top: 2, leading: 8, bottom: 2, trailing: 8))
    }
}

/// An email helper class which allows us to send emails in the support section of
/// the settings view.
class EmailHelper: NSObject, MFMailComposeViewControllerDelegate {
    /// The EmailHelper static object.
    public static let shared = EmailHelper()
    private override init() {
    }
    
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
