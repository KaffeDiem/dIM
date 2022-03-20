//
//  CreateGroupView.swift
//  bluetoothChat
//
//  Created by Kasper Munch on 27/02/2022.
//

import SwiftUI
import PopupView

struct CreateGroupView: View {
    @Environment(\.colorScheme) private var colorScheme
    @ObservedObject private var viewModel = CreateGroupViewModel()
    
    var body: some View {
        VStack {
            Spacer()
            
            HStack {
                Text("Name of group")
                    .foregroundColor(.gray)
                    .font(.footnote)
                Spacer()
            }
            TextField("Aa", text: $viewModel.groupName)
                .keyboardType(.namePhonePad)
                .padding()
                .background(
                    colorScheme == .dark ? Color("setup-grayDARK") : Color("setup-grayLIGHT")
                )
                .cornerRadius(10.0)
                .padding(.bottom)
            
            Spacer()
            
            VStack(alignment: .leading, spacing: 5) {
                Text("· Messages can only be read by group members.")
                    .modifier(BulletlistModifier())
                    .foregroundColor(.green)
                Text("· No limit on the amount of group members.")
                    .modifier(BulletlistModifier())
                    .foregroundColor(.green)
                    .padding(.bottom)
                Text("· Group members cannot be removed.")
                    .modifier(BulletlistModifier())
                    .foregroundColor(.red)
                Text("· Your message may not reach everyone.")
                    .modifier(BulletlistModifier())
                    .foregroundColor(.red)
            }
            .frame(maxWidth: .infinity)
            
            Button {
                viewModel.showCreatedGroup = true
            } label: {
                if viewModel.createGroupButtonEnabled {
                    Text("Create group")
                        .modifier(PrimaryButton())
                } else {
                    Text("Create group")
                        .modifier(PrimaryButtonDisabled())
                }
            }
            .padding(.top)
            .disabled(viewModel.createGroupButtonEnabled)
        }
        .padding()
        .navigationBarTitle("Create group")
        .popup(
            isPresented: $viewModel.showCreatedGroup,
            type: .toast,
            position: .bottom,
            animation: .default,
            autohideIn: 4.0,
            dragToDismiss: true,
            closeOnTap: true,
            closeOnTapOutside: false,
            backgroundColor: .clear,
            dismissCallback: {
                viewModel.dismissCreatedGroup()
            }, view: {
                Text("The group \"\(viewModel.groupName)\" has been created.")
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, maxHeight: 120)
                    .background(Color("setup-grayDARK"))
                    .cornerRadius(10)
            })
    }
    
}

struct BulletlistModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.footnote)
            .padding(8)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(.quaternary, in: Capsule())
    }
}

struct CreateGroupView_Previews: PreviewProvider {
    static var previews: some View {
        CreateGroupView()
            .previewDevice("iPhone 13 Pro")
    }
}
