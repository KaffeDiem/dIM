//
//  QRScreen.swift
//  bluetoothChat
//
//  Created by Kasper Munch on 29/08/2021.
//

import SwiftUI
import CoreImage.CIFilterBuiltins

struct QRScreenView: View {

    let username = UserDefaults.standard.string(forKey: "Username")
    
    let context = CIContext()
    let filter = CIFilter.qrCodeGenerator()
    
    var body: some View {
        VStack {
            
            Spacer()
            
            Text("Scan the QR code to become contacts.")
            
            Spacer()
            
            ZStack {
                RoundedRectangle(cornerRadius: 25, style: .continuous)
                    .foregroundColor(.white)
                    .frame(width: 225, height: 225)
                
                Image(uiImage: generateQRCode(from: "dim://\(username ?? "unknown")//publickey"))
                    .interpolation(.none)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200, alignment: .center)
            }
                
            Spacer()
            
            Text("Open the camera on an iPhone which has dIM installed and point the viewfinder on the QR code. Then tap the link. This will open dIM.")
                .font(.footnote)
        }
        .padding()
//        )
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
        QRScreenView()
    }
}