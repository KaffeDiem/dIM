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
    let placeholder: String
    let onSubmit: OnSubmit?
    
    @FocusState private var isFocused: Bool
    @State private var characterLimitShown: Bool = false
    private let characterLimit = 260
    
    @State private var borderColor: Color = Asset.greyLight.swiftUIColor
    private let borderColorActive: Color = Asset.dimOrangeLight.swiftUIColor
    private let borderColorInactive: Color = Asset.greyLight.swiftUIColor
    
    var body: some View {
        HStack(spacing: 8) {
            TextField(placeholder, text: $text, onEditingChanged: { editing in
                withAnimation(.spring()) {
                    borderColor = editing ? borderColorActive : borderColorInactive
                }
            })
            .focused($isFocused)
            .toolbarRole(.editor)
            .toolbarTitleMenu(content: {
                Text("World")
            })
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    HStack {
                        Button {
                            print("Add stickers")
                        } label: {
                            Image(systemName: "face.smiling.inverse")
                        }
                        Spacer()
                    }
                }
            }
            .padding([.leading, .top, .bottom], 12)
            .onSubmit {
                submit()
            }
            
            if characterLimitShown {
                Text("\(text.count)/260")
                    .foregroundColor(.red)
                    .padding([.leading, .trailing], 8)
            }
            
            Button {
                submit()
            } label: {
                Image(systemName: text.isEmpty ? "arrow.up.circle" : "arrow.up.circle.fill")
                    .animation(.spring(), value: text.isEmpty)
                    .imageScale(.large)
            }
            .padding(.trailing)
        }
        .onChange(of: text, perform: { newValue in
            characterLimitShown = newValue.count > characterLimit
        })
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(borderColor)
        )
        .onAppear {
            isFocused = true
        }
    }
    
    private func submit() {
        if let onSubmit {
            onSubmit(text)
        }
    }
}

struct ChatTextField_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            DIMChatTextField(text: .constant("Test"), placeholder: "", onSubmit: nil)
                .padding()
                .previewDevice(PreviewDevice(rawValue: "iPhone 14 Pro"))
                .previewDisplayName("Short text")
            
            DIMChatTextField(text: .constant(""), placeholder: "", onSubmit: nil)
                .padding()
                .previewDevice(PreviewDevice(rawValue: "iPhone 14 Pro"))
                .previewDisplayName("No text")
            
            DIMChatTextField(text: .constant("Some very long text which pushes the limits of what a message box will keep in the boundaries. Some very long text which pushes the limits of what a message box will keep in the boundaries. Some very long text which pushes the limits of what a message box will keep in the boundaries."), placeholder: "", onSubmit: nil)
                .padding()
                .previewDevice(PreviewDevice(rawValue: "iPhone 14 Pro"))
                .previewDisplayName("Long text")
        }
    }
}
