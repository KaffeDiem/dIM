//
//  CreateGroupView.swift
//  bluetoothChat
//
//  Created by Kasper Munch on 27/02/2022.
//

import SwiftUI

struct CreateGroupView: View {
    @State private var groupName = ""
    
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        VStack {
            
            Spacer()
            
            TextField("Group name", text: $groupName)
                .keyboardType(.namePhonePad)
                .padding()
                .background(
                    colorScheme == .dark ? Color("setup-grayDARK") : Color("setup-grayLIGHT")
                )
                .cornerRadius(10.0)
            
            VStack(alignment: .leading, spacing: 5) {
                Text("Messages can only be read by group members.")
                    .modifier(BulletlistModifier())
                    .foregroundColor(.green)
                Text("No limit on the amount of group members.")
                    .modifier(BulletlistModifier())
                    .foregroundColor(.green)
                    .padding(.bottom)
                Text("Group members cannot be removed.")
                    .modifier(BulletlistModifier())
                    .foregroundColor(.red)
                Text("Your message may not reach everyone.")
                    .modifier(BulletlistModifier())
                    .foregroundColor(.red)
            }
            .frame(maxWidth: .infinity)
            
            Spacer()
            
            Button {
                print("Create group pressed")
            } label: {
                Text("Create group")
                    .modifier(PrimaryButton())
            }
        }
        .padding()
        .navigationBarTitle("Create group")
    }
    
}

struct BulletlistModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.footnote)
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(.quaternary, in: Capsule())
    }
}

struct CreateGroupView_Previews: PreviewProvider {
    static var previews: some View {
        CreateGroupView()
    }
}
