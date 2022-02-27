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
            
            Spacer()
            
            Button {
                print("Create group pressed")
            } label: {
                Text("Create group")
                    .modifier(PrimaryButton())
            }

            Text("Notice: Groups are less secure than direct messaging.")
                .font(.footnote)
        }
        .padding()
        .navigationBarTitle("Create group")
    }
    
}

struct CreateGroupView_Previews: PreviewProvider {
    static var previews: some View {
        CreateGroupView()
    }
}
