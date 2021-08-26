//
//  SetUpVoew.swift
//  bluetoothChat
//
//  Created by Kasper Munch on 26/08/2021.
//

import SwiftUI

struct SetUpView: View {
    @State var username: String = ""
    @State var hasUsername: Bool = false
    
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
                    Text("Login")
                    TextField("Aa", text: $username, onCommit: {
                        // Do something on commit.
                    })
                        .padding()
                        .background(Color("smashed-white"))
                        .cornerRadius(10.0)
                    /*
                     Guiding text below textfield
                     */
                    if username.count < 4 {
                        Text("Minimum 4 characters.")
                            .font(.footnote)
                            .foregroundColor(.accentColor)
                    } else if username.count > 12 {
                        Text("Maximum 12 characters.")
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
                
                Spacer()
                
                VStack {
                    Button("Enter", action: {
                        hasUsername = checkUsername(username: username)
                        })
                    .padding()
                    .foregroundColor(.white)
                }
                .frame(minWidth: 0, maxWidth: .infinity)
                .background(LinearGradient(gradient: Gradient(colors: [Color(.red), Color(.orange)]), startPoint: .leading, endPoint: .trailing))
                .cornerRadius(10.0)
                .padding()
                    
                NavigationLink(destination: ContentView()
                                .navigationBarTitle("")
                                .navigationBarBackButtonHidden(true),
                               isActive: $hasUsername) {
                    EmptyView()
                }
                
            }
            .onAppear() {
                // Check if the user already has a username.
                if UserDefaults.standard.string(forKey: "Username") != nil {
                    print("Username set -> Load ContentView")
                    self.hasUsername = true
                } else {
                    self.hasUsername = false
                }
            }
        }
    }
    
    /*
     Check if the username is 4-12 chars and does not include space
     */
    func checkUsername(username: String) -> Bool{
        
        if username.count < 4 {
            return false
        } else if username.count > 12 {
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
