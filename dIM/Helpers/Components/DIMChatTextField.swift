//
//  DIMTextField.swift
//  dIM
//
//  Created by Kasper Munch on 23/02/2023.
//

import SwiftUI

struct DIMChatTextField: View {
    typealias OnSubmit = (_ text: String) -> Void
    typealias OnChange = (_ text: String) -> Void
    
    private let placeholder: String
    private let image: UIImage?
    
    @State private var text: String = ""
    @State private var borderColor: Color
    private let borderColorActive: Color
    private let borderColorInactive: Color
    private let characterLimitShown: Bool
    
    private var onChange: OnSubmit?
    private var onSubmit: OnSubmit?
    
    @FocusState private var isFocused: Bool
    
    init(
        image: UIImage? = nil,
        placeholder: String? = nil,
        onChange: OnChange? = nil,
        onSubmit: OnSubmit? = nil,
        characterLimitShown: Bool = true
    ) {
        self.image = image
        self.placeholder = placeholder ?? ""
        self.onChange = onChange
        self.onSubmit = onSubmit
        self.characterLimitShown = characterLimitShown
        
        self.borderColorInactive = Asset.greyLight.swiftUIColor
        self.borderColorActive = Asset.dimOrangeLight.swiftUIColor
        self.borderColor = borderColorInactive
    }
    
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
            .onChange(of: text) { text in
                if let onChange {
                    onChange(text)
                }
            }
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

struct DIMChatTextField_Previews: PreviewProvider {
    static var previews: some View {
        DIMChatTextField(image: .init(named: "scribble"), placeholder: "Placeholder")
    }
}
