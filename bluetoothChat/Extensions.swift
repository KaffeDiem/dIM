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
