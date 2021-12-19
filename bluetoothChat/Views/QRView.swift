//
//  QRScreen.swift
//  bluetoothChat
//
//  Created by Kasper Munch on 29/08/2021.
//

import SwiftUI
import CoreImage.CIFilterBuiltins

/// The `QRView` gets the users public key in a string format,
/// then generates a QR code and displays it nicely.
struct QRView: View {
    
    /// The colorscheme of the current users device. Used for displaying
    /// different visuals depending on the colorscheme.
    @Environment(\.colorScheme) var colorScheme
    
    /// The username fetched from `UserDefaults`
    let username = UserDefaults.standard.string(forKey: "Username")
    
    /// Contect for drawing of the QR code.
    let context = CIContext()
    /// Filter for drawing the QR code. Built-in function.
    let filter = CIFilter.qrCodeGenerator()
    
    var body: some View {
       
        VStack {
            
            Spacer()
            
            Text("Scan the QR code")
                .font(.title)
                .padding()
            
            ZStack {
                RoundedRectangle(cornerRadius: 25, style: .continuous)
                    .foregroundColor(.white)
                    .frame(width: 225, height: 225)
                
                /*
                 Show the QR code which can be scanned to add you as a contact.
                 The form of the QR code is:
                 dim://username//publickey
                 */
                Image(uiImage: generateQRCode(from: "dim://\(username ?? "Unknown")//\(CryptoHandler().getPublicKey())"))
                    .interpolation(.none)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200, alignment: .center)
            }
                
            Spacer(minLength: 150)
            
            Text("Open up your camera and scan each others QR code. It is required that dIM is installed on the phone. You have to add each other to become contacts.")
                .font(.footnote)
                .foregroundColor(.accentColor)
        }
        .padding()
    
        .background(
            Image("bubbleBackground")
                .resizable(resizingMode: .tile)
                .edgesIgnoringSafeArea(.all)
        )
        .navigationBarTitle("Add Contact", displayMode: .inline)
    }
    
    /// Generates a QR code given some string as an input.
    /// - Parameter string: The string to generate a QR code from. Formatted as dim://username//publickey
    /// - Returns: A UIImage for displaying on the phone.
    private func generateQRCode(from string: String) -> UIImage {
        let data = Data(string.utf8)
        filter.setValue(data, forKey: "inputMessage")

        if let outputImage = filter.outputImage {
            if let cgimg = context.createCGImage(outputImage, from: outputImage.extent) {
                return UIImage(cgImage: cgimg)
            }
        }

        return UIImage(systemName: "xmark.circle") ?? UIImage()
    }
}
