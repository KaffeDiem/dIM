//
//  QRScreen.swift
//  bluetoothChat
//
//  Created by Kasper Munch on 29/08/2021.
//

import SwiftUI
import CodeScanner
import CoreImage.CIFilterBuiltins

/// The `QRView` gets the users public key in a string format,
/// then generates a QR code and displays it nicely.
struct QRView: View {
    
    /// The colorscheme of the current users device. Used for displaying
    /// different visuals depending on the colorscheme.
    @Environment(\.colorScheme) var colorScheme
    
    @EnvironmentObject var appSession: AppSession
    
    /// The username fetched from `UserDefaults`
    private let username: String
    
    /// Contect for drawing of the QR code.
    private let context = CIContext()
    /// Filter for drawing the QR code. Built-in function.
    private let filter = CIFilter.qrCodeGenerator()
    
    init() {
        let validator = UsernameValidator()
        guard let username = validator.userInfo?.asString else {
            fatalError("QR view was opened but no username has been set")
        }
        self.username = username
    }
    
    /// Show camera for scanning QR codes.
    @State private var qrCodeScannerIsShown = false
    
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
                Image(uiImage: generateQRCode(from: "dim://\(username)//\(CryptoHandler.fetchPublicKeyString())"))
                    .interpolation(.none)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200, alignment: .center)
            }
                
            Spacer(minLength: 150)
            
            Text("Press the scan button and scan each others QR code. You must add each other.")
                .font(.footnote)
                .foregroundColor(.accentColor)
            
            Button {
                qrCodeScannerIsShown = true
            } label: {
                Text("Scan")
                    .padding()
                    .foregroundColor(.white)
                    .frame(minWidth: 0, maxWidth: .infinity)
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [Asset.dimOrangeDark.swiftUIColor, Asset.dimOrangeLight.swiftUIColor]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(10.0)
            }.sheet(isPresented: $qrCodeScannerIsShown, content: {
                ZStack {
                    CodeScannerView(codeTypes: [.qr], completion: handleScan)
                    VStack {
                        HStack {
                            Spacer()
                            Button {
                                qrCodeScannerIsShown = false
                            } label: {
                                Image(systemName: "xmark")
                                    .foregroundColor(.white)
                                    .imageScale(.large)
                                    .padding()
                            }

                        }
                        Spacer()
                        Text("Add a new contact by scanning their QR code.")
                            .multilineTextAlignment(.center)
                            .font(.footnote)
                            .foregroundColor(.white)
                            .padding()
                    }
                }
            })
        }
        .padding()
    
        .background(
            Image("bubbleBackground")
                .resizable(resizingMode: .tile)
                .edgesIgnoringSafeArea(.all)
        )
        .navigationBarTitle("Add Contact", displayMode: .inline)
    }
    
    /// Handles the result of the QR scan.
    /// - Parameter result: Result of the QR scan or an error.
    private func handleScan(result: Result<ScanResult, ScanError>) {
        qrCodeScannerIsShown = false
        switch result {
        case .success(let result):
            appSession.addUserFromQrScan(result.string)
        case .failure(let error):
            print(error.localizedDescription)
        }
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
