//
//  Extensions+IfModifier.swift
//  dIM
//
//  Created by Kasper Munch on 24/02/2023.
//

import SwiftUI

extension View {
    @ViewBuilder func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}
