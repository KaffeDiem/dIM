//
//  StickersView.swift
//  dIM
//
//  Created by Kasper Munch on 05/03/2023.
//

import SwiftUI

struct StickersView: View {
    let rows = [GridItem(.fixed(30)), GridItem(.flexible(minimum: 64, maximum: 128))]
    
    var body: some View {
        ScrollView(.horizontal) {
            LazyHGrid(rows: rows, alignment: .center) {
                ForEach(0x1f600...0x1f679, id: \.self) { value in
                    Text(String(format: "%x", value))
                    Text(emoji(value))
                        .font(.largeTitle)
                }
            }
        }
    }
    
    private func emoji(_ value: Int) -> String {
        guard let scalar = UnicodeScalar(value) else { return "?" }
        return String(Character(scalar))
    }
}

struct StickersView_Previews: PreviewProvider {
    static var previews: some View {
        StickersView()
    }
}
