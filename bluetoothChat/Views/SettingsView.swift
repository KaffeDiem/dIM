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
            
            VStack {
                HStack {
                    Text("Username")
                        .foregroundColor(.accentColor)
                        .padding(.leading)
                    Spacer()
                }
                TextField(defaults.string(forKey: "Username") ?? "", text: $usernameTemp, onEditingChanged: {changed in
                    // Do something with onEditingChanged?
                }, onCommit: {
                    UIApplication.shared.endEditing()
                    defaults.set(usernameTemp, forKey: "Username")
                })
                .padding(.leading)
                .padding(.trailing)
                .padding(.bottom)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .disableAutocorrection(true)
                .autocapitalization(.none)
            }
            .navigationBarTitle("Settings")
            
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
