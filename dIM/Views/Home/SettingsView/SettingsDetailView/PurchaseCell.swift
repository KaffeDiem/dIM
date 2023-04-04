//
//  PurchaseCell.swift
//  dIM
//
//  Created by Kasper Munch on 12/03/2023.
//

import SwiftUI

struct PurchaseCell: View {
    typealias OnTap = () -> Void
    
    @Environment(\.colorScheme) var colorScheme
    
    let name: String
    let price: String
    let description: String
    let onTap: OnTap
    
    var body: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading) {
                Text(name)
                    .font(.subheadline)
                    .fontWeight(.heavy)
                HStack {
                    Text(description)
                }
            }
            Spacer()
            Button {
                onTap()
            } label: {
                Text(price)
                    .fontWeight(.bold).shiny(.hyperGlossy(.systemGray2))
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .foregroundColor(colorScheme == .light ? .black : .white )
                .opacity(0.05)
        )
    }
}
