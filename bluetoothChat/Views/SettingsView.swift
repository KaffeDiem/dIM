//
//  SettingsView.swift
//  bluetoothChat
//
//  Created by Kasper Munch on 25/08/2021.
//

import SwiftUI


struct SettingsView: View {
    
    let defaults = UserDefaults.standard
    
    @State var usernameTemp: String = ""
    
    var body: some View {
        VStack {
            
            HStack {
                Text("Username")
                    .padding(.leading)
                    .padding(.top)
                Spacer()
            }
            TextField(defaults.string(forKey: "Username") ?? "Aa", text: $usernameTemp, onEditingChanged: {changed in
                print("onEditingChanged: \(changed)")
            }, onCommit: {
                UIApplication.shared.endEditing()
                defaults.set(usernameTemp, forKey: "Username")
            })
            .padding(.leading)
            .padding(.trailing)
            .padding(.bottom)
            .textFieldStyle(RoundedBorderTextFieldStyle())
            
            .navigationBarTitle("Settings")
            
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
