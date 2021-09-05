//
//  QRScreen.swift
//  bluetoothChat
//
//  Created by Kasper Munch on 29/08/2021.
//

import SwiftUI
import CoreImage.CIFilterBuiltins

struct QRView: View {

    @Environment(\.colorScheme) var colorScheme
    
    let username = UserDefaults.standard.string(forKey: "Username")
    
    let context = CIContext()
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
                Image(uiImage: generateQRCode(from: "dim://\(username ?? "Unknown")//\(getPublicKey())"))
                    .interpolation(.none)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200, alignment: .center)
            }
                
            Spacer(minLength: 150)
            
            Text("Scan the QR code by pointing the camera at it. It is required that dIM is installed on the phone. You have to add each other to become contacts.")
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
    
    
    /*
     Generate QR codes on the fly to share your information
     with whoever scans your QR code.
     */
    func generateQRCode(from string: String) -> UIImage {
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

struct QRScreen_Previews: PreviewProvider {
    static var previews: some View {
        QRView()
    }
}
