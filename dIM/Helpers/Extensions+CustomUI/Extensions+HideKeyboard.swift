//
//  Extensions+HideKeyboard.swift
//  dIM
//
//  Created by Kasper Munch on 09/02/2023.
//

import SwiftUI

extension View {
    func hideKeyboard() {
        let resign = #selector(UIResponder.resignFirstResponder)
        UIApplication.shared.sendAction(resign, to: nil, from: nil, for: nil)
    }
}
