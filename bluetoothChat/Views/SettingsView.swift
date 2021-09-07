//
//  SettingsView.swift
//  bluetoothChat
//
//  Created by Kasper Munch on 25/08/2021.
//

import SwiftUI


/*
 Device Information view in bottom of screen.
 */
struct DeviceInformationView: View {
    
    var connectedDevices: Int
    
    var body: some View {
        if connectedDevices < 1 {
            Label("Not connected.", systemImage: "figure.stand")
                .font(.footnote)
                .foregroundColor(.gray)
        } else {
            Label(
                "\(connectedDevices) device\(connectedDevices == 1 ? "" : "s") connected.",
                systemImage: "figure.stand.line.dotted.figure.stand"
            )
            .font(.footnote)
            .foregroundColor(.gray)
        }
    }
}


/*
 Read message toggle.
 */
struct ReadToggle: View {
    
    let defaults = UserDefaults.standard
    @State var readStatusToggle: Bool = UserDefaults.standard.bool(forKey: "settings.readmessages")
    
    var body: some View {
        VStack {
            Toggle("Read receipts", isOn: $readStatusToggle)
                .onChange(of: readStatusToggle, perform: {value in
                    if value {
                        defaults.setValue(readStatusToggle, forKey: "settings.readmessages")
                        print("toggle on")
                    } else {
                        defaults.setValue(readStatusToggle, forKey: "settings.readmessages")
                        print("toggle off")
                    }
                })
                .toggleStyle(SwitchToggleStyle(tint: .accentColor))
        }
    }
}


struct SettingsView: View {
    
    let defaults = UserDefaults.standard
    
    @EnvironmentObject var chatBrain: ChatBrain
    
    @State var usernameTemp: String = ""
    @Environment(\.colorScheme) var colorScheme
    
    @State private var connectedDevices = 0
    
    var body: some View {
        VStack(spacing: 20) {
            
            ScrollView {
                /*
                 dIM Icon in top of settings view.
                 */
                GroupBox(label: Text("Decentralized Instant Messenger"), content: {
                    Divider().padding(.vertical, 4)
                    HStack {
                        Image("appiconsvg")
                            .resizable()
                            .frame(width: 128, height: 128, alignment: .leading)
                            .aspectRatio(contentMode: .fit)
                            .scaledToFit()
                        Spacer()
                        DeviceInformationView(connectedDevices: connectedDevices)
                    }
                })
                
                Spacer()
                
                GroupBox(label: Text("Allow people to see that you have read their messages."), content: {
                    Divider().padding(.vertical, 4)
                    ReadToggle()
                })
                
                
                Spacer()
                
                GroupBox(label: Text("Change username"), content: {
                    Divider().padding(.vertical, 4)
                    /*
                     Text field to input new username
                     */
                    Text("Notice: If you change your username you and your contacts will have to add each other again.")
                        .foregroundColor(.gray)
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
                        Text(" ")
                    }
                })
                
                
            }
            .padding()
            .autocapitalization(.none)
            .disableAutocorrection(true)
            .navigationBarTitle("Settings", displayMode: .large)
        }
        .onAppear() {
            Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
                connectedDevices = chatBrain.discoveredDevices.count
            }
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
