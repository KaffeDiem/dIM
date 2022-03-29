//
//  SwiftUIView.swift
//  bluetoothChat
//
//  Created by Kasper Munch on 27/03/2022.
//

import SwiftUI

struct ChatListCell: View {
    let title: String
    let lastMessage: String
    
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Circle()
                    .foregroundColor(colorScheme == .dark ? .gray : Color("setup-grayLIGHT"))
                    .frame(width: 50, height: 50, alignment: .center)
                    .overlay(
                        Text(title.prefix(2))
                    )
                    .padding(.trailing, 8)
                VStack(alignment: .leading) {
                    Text(title)
                        .foregroundColor(.accentColor)

                    Text(lastMessage)
                        .scaledToFit()
                        .font(.footnote)
                }
            }
        }
        .padding(8)
    }
}

struct SwiftUIView_Previews: PreviewProvider {
    static var previews: some View {
        ChatListCell(title: "Repsak", lastMessage: "Here is some placeholder text which check that the lenght of this string is truncated correcly.")
    }
}
