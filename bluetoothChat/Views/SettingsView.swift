//
//  SettingsView.swift
//  bluetoothChat
//
//  Created by Kasper Munch on 25/08/2021.
//

import SwiftUI


struct SettingsView: View {
    
    let defaults = UserDefaults.standard
    
    @EnvironmentObject var chatBrain: ChatBrain
    
    @State var usernameTemp: String = ""
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack {
            
            VStack {
                /*
                 dIM Icon in top of settings view.
                 */
                Image("appiconsvg")
                    .resizable()
                    .frame(width: 128, height: 128, alignment: .center)
                    .aspectRatio(contentMode: .fit)
                    .scaledToFit()
                
                Spacer()
                
                HStack {
                    Text("Set a new username")
//                        .foregroundColor(.accentColor)
                        .padding(.leading)
                }
                
                /*
                 Text field to input new username
                 */
                TextField(
                    defaults.string(forKey: "Username")!,
                    text: $usernameTemp,
                    onCommit: {
                            
                        UIApplication.shared.endEditing()
                        
                        if checkValidUsername(username: usernameTemp) {
                            defaults.set(usernameTemp, forKey: "Username")
                        } else {
                            usernameTemp = ""
                        }
                    }
                )
                .keyboardType(.namePhonePad)
                .padding()
                .background(
                    colorScheme == .dark ? Color("setup-grayDARK") : Color("setup-grayLIGHT")
                )
                .cornerRadius(10.0)
                
                /*
                 Text below textfield.
                 */
                
                if usernameTemp.count < 4 {
                    Text("Minimum 4 characters.")
                        .font(.footnote)
                        .foregroundColor(.accentColor)
                } else if usernameTemp.count > 16 {
                    Text("Maximum 16 characters.")
                        .font(.footnote)
                        .foregroundColor(.accentColor)
                } else if usernameTemp.contains(" ") {
                    Text("No spaces in username.")
                        .font(.footnote)
                        .foregroundColor(.accentColor)
                } else {
                    Text("")
                }
                
                Spacer()
                
                if chatBrain.discoveredDevices.count < 1 {
                    Text("Not connected to anyone.")
                        .font(.footnote)
                        .foregroundColor(.accentColor)
                } else {
                    Text("\(chatBrain.discoveredDevices.count) device\(chatBrain.discoveredDevices.count == 1 ? "" : "s") connected.")
                        .font(.footnote)
                        .foregroundColor(.accentColor)
                }
                
                Text("\(chatBrain.routedMessagesCounter) messages routed.")
                    .font(.footnote)
                    .foregroundColor(.accentColor)
            }
            .padding()
            .autocapitalization(.none)
            .disableAutocorrection(true)
            
            .navigationBarTitle("Settings")
        }
    }
    
    func checkValidUsername(username: String) -> Bool{
        if username.count < 4 {
            return false
        } else if username.count > 16 {
            return false
        } else if username.contains(" ") {
            return false
        }
        return true
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
