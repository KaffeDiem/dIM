//
//  DIMTextField.swift
//  dIM
//
//  Created by Kasper Munch on 23/02/2023.
//

import SwiftUI

struct DIMChatTextField: View {
    typealias OnSubmit = (_ text: String) -> Void
    
    @Binding var text: String
    let image: UIImage? = nil
    let placeholder: String
    let characterLimitShown: Bool
    let onSubmit: OnSubmit?
    
    @State private var borderColor: Color = Asset.greyLight.swiftUIColor
    private let borderColorActive: Color = Asset.dimOrangeLight.swiftUIColor
    private let borderColorInactive: Color = Asset.greyLight.swiftUIColor
    
    @FocusState private var isFocused: Bool
    
    var body: some View {
        HStack(spacing: 8) {
            if let image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .offset(x: 24, y: 0)
                    .frame(height: 20, alignment: .leading)
            }
            
            TextField(placeholder, text: $text, onEditingChanged: { editing in
                withAnimation(.spring()) {
                    borderColor = editing ? borderColorActive : borderColorInactive
                }
            })
            .focused($isFocused)
            .padding([.leading, .top, .bottom], 12)
            .onSubmit {
                if let onSubmit {
                    onSubmit(text)
                }
            }
            
            if characterLimitShown {
                if text.count > 260 {
                    Text("\(text.count)/260")
                        .foregroundColor(.red)
                        .padding(.trailing, 12)
                } else {
                    Text("\(text.count)/260")
                        .padding(.trailing, 12)
                }
            }
        }
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(borderColor)
        )
        .onAppear {
            isFocused = true
        }
    }
}
