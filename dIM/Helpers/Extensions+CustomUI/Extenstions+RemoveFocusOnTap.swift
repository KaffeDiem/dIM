//
//  Extenstions+RemoveFocusOnTap.swift
//  dIM
//
//  Created by Kasper Munch on 24/02/2023.
//

import SwiftUI

extension View {
    public func removeFocusOnTap() -> some View {
        modifier(RemoveFocusOnTapModifier())
    }
}

public struct RemoveFocusOnTapModifier: ViewModifier {
    public func body(content: Content) -> some View {
        content
#if os (iOS)
            .onTapGesture {
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to:nil, from:nil, for:nil)
            }
#elseif os(macOS)
            .onTapGesture {
                DispatchQueue.main.async {
                    NSApp.keyWindow?.makeFirstResponder(nil)
                }
            }
#endif
    }
}
