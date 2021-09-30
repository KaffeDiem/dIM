//
//  SetUpVoew.swift
//  bluetoothChat
//
//  Created by Kasper Munch on 26/08/2021.
//

import SwiftUI
import UIKit

/*
 SetUpView handles all initial first logins where users choose a username
 and are then redirected to ContentView which is the main View of the app.
 */


struct SetUpView: View {
    @State var username: String = ""
    @State var hasUsername: Bool = false
    
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.managedObjectContext) var context
    
    init() {
        
    }
    
    var body: some View {
        NavigationView {
            VStack {
                
                Image("appiconsvg")
                    .resizable()
                    .frame(width: 128, height: 128, alignment: .center)
                    .aspectRatio(contentMode: .fit)
                    .scaledToFit()
                Text("Chat with your friends without restrictions.")
                    .font(.subheadline)
                    .padding(EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10))
                
                Spacer()
                
                VStack {
                    Text("Choose username")
                    TextField("Aa", text: $username, onCommit: {
                        // Do something on commit.
                        }
                    )
                    .keyboardType(.namePhonePad)
                    .padding()
                    .background(
                        colorScheme == .dark ? Color("setup-grayDARK") : Color("setup-grayLIGHT")
                    )
                    .cornerRadius(10.0)
                    
                    /*
                     Guiding text below textfield
                     */
                    if username.count < 4 {
                        Text("Minimum 4 characters.")
                            .font(.footnote)
                            .foregroundColor(.accentColor)
                    } else if username.count > 16 {
                        Text("Maximum 16 characters.")
                            .font(.footnote)
                            .foregroundColor(.accentColor)
                    } else if username.contains(" ") {
                        Text("No spaces in username.")
                            .font(.footnote)
                            .foregroundColor(.accentColor)
                    } else {
                        Text("")
                    }
                }
                .padding()
                .autocapitalization(.none)
                .disableAutocorrection(true)
                
                Spacer()
                
                /*
                 Enter button which handles setting the username if valid.
                 */
                VStack {
                    Button("Enter", action: {
                        let usernameValid: Bool = checkUsername(username: username)
                        //  If the username is accepted then save it to persistent memory.
                        if usernameValid {
                            let usernameDigits = username + "#" + String(Int.random(in: 100000...999999))
                            UserDefaults.standard.set(usernameDigits, forKey: "Username")
                        }
                        
                        hasUsername = usernameValid
                        }
                    )
                    .padding()
                    .foregroundColor(.white)
                }
                .frame(minWidth: 0, maxWidth: .infinity)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [Color("dimOrangeDARK"), Color("dimOrangeLIGHT")]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(10.0)
                .padding()
                
                // Empty link which takes the user to the main screen if username has been set.
                NavigationLink(destination: HomeView(chatBrain: ChatBrain(context: context))
                                .navigationBarTitle("")
                                .navigationBarBackButtonHidden(true),
                               isActive: $hasUsername) {
                    EmptyView()
                }
            }
            .onAppear() {
                // Check if the user already has a username.
                if UserDefaults.standard.string(forKey: "Username") != nil {
                    print("Username has been set -> Skip SetUpView")
                    self.hasUsername = true
                } else {
                    self.hasUsername = false
                }
                
                // Request permission to send notifications.
                UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
                    if success {
                        print("All set!")
                    } else if let error = error {
                        print(error.localizedDescription)
                    }
                }
            }
        }
        
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    /*
     Check if the username is 4-12 chars and does not include space
     */
    func checkUsername(username: String) -> Bool{
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


struct SetUpVoew_Previews: PreviewProvider {
    static var previews: some View {
        SetUpView()
    }
}
