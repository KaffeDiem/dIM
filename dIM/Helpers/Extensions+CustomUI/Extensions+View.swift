//
//  Extensions+View.swift
//  dIM
//
//  Created by Kasper Munch on 18/02/2023.
//

import SwiftUI

extension View {
    func banner(data: Binding<BannerModifier.BannerData>, isPresented: Binding<Bool>) -> some View {
        self.modifier(BannerModifier(data: data, shouldShow: isPresented))
    }
}
