//
//  Extensions.swift
//  bluetoothChat
//
//  Created by Kasper Munch on 25/08/2021.
//

import SwiftUI

struct PrimaryButton: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding()
            .foregroundColor(.white)
            .frame(minWidth: 0, maxWidth: .infinity)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [Color("dimOrangeDARK"), Color("dimOrangeLIGHT")]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(10.0)
    }
}

extension UIApplication {
    /// Called on a textfield to dismiss the keyboard when the user
    /// taps the view. This allows us to scroll the view and then
    /// dismiss the keyboard automatically.
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
