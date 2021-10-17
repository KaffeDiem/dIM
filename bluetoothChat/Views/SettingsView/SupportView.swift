//
//  SupportView.swift
//  bluetoothChat
//
//  Created by Kasper Munch on 16/10/2021.
//

import SwiftUI
import Foundation
import MessageUI

struct SupportView: View {
    @State var showingAlert = false
    
    var body: some View {
        GroupBox(label: Text("Support and Feedback"), content: {
            Divider().padding(.vertical, 4)
            
            Text("Feel free to send me a mail if you have any feedback on the app. As dIM is an Open Source project you may create an issue on Github if you have found any bugs. Find the Github repository on the website. Feedback emails can be sent to support@dimchat.org.")
                .font(.footnote)
                .foregroundColor(.gray)
                .frame(maxWidth: .infinity, alignment: .leading)
            HStack {
                Spacer()
                Link("Website", destination: URL(string: "https://www.dimchat.org")!)
                Spacer()
                Button(action: {
                    if !EmailHelper.shared.sendEmail(subject: "dIM Support and Feedback", body: "", to: "support@dimchat.org") {
                        showingAlert = true
                    }
                }, label: {
                    Text("Support")
                        .alert("You must configure a default mailbox to send mails.", isPresented: $showingAlert) {
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

struct SupportView_Previews: PreviewProvider {
    static var previews: some View {
        SupportView()
    }
}


class EmailHelper: NSObject, MFMailComposeViewControllerDelegate {
    public static let shared = EmailHelper()
    private override init() {
        //
    }
    
    func sendEmail(subject:String, body:String, to:String) -> Bool {
        if !MFMailComposeViewController.canSendMail() {
            print("No mail account found")
            // Todo: Add a way to show banner to user about no mail app found or configured
            // Utilities.showErrorBanner(title: "No mail account found", subtitle: "Please setup a mail account")
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
        
        // OR If you use SwiftUI 2.0 based WindowGroup try this one
        // UIApplication.shared.windows.first?.rootViewController
    }
}
