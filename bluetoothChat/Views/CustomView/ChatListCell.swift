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
    
    var body: some View {
        VStack(alignment: .leading) {
            VStack(alignment: .leading) {
                Text(title)
                    .foregroundColor(.accentColor)

                Text(lastMessage)
                    .scaledToFit()
                    .font(.footnote)
            }
        }
        .padding()
    }
}

struct SwiftUIView_Previews: PreviewProvider {
    static var previews: some View {
        ChatListCell(title: "Repsak", lastMessage: "Here is some placeholder text which check that the lenght of this string is truncated correcly.")
    }
}
