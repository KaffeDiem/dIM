//
//  Extensions.swift
//  bluetoothChat
//
//  Created by Kasper Munch on 25/08/2021.
//

import SwiftUI


extension UIApplication {
    /// Called on a textfield to dismiss the keyboard when the user
    /// taps the view. This allows us to scroll the view and then
    /// dismiss the keyboard automatically.
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

extension Color {
    /// Extension on color which automatically converts a HEX color code
    /// to a RGB color format.
    /// - Parameters:
    ///   - hex: The HEX code of the color.
    ///   - alpha: The alpha value (transparency, where 1 is non-transparent).
    init(hex: UInt, alpha: Double = 1) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xff) / 255,
            green: Double((hex >> 08) & 0xff) / 255,
            blue: Double((hex >> 00) & 0xff) / 255,
            opacity: alpha
        )
    }
}
