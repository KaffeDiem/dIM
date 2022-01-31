//
//  SetUpVoew.swift
//  bluetoothChat
//
//  Created by Kasper Munch on 26/08/2021.
//

import SwiftUI
import UIKit
import Resolver

/**
 SetUpView handles all initial first logins where users choose a username
 and are then redirected to ContentView which is the main View of the app.
 */
struct SetupView: View {
    /// String which stores the username temporarily.
    @State private var textfieldUsername: String = ""
    
    /// True if the keyboard is shown. Used for animations.
    @FocusState private var keyboardShown: Bool
    
    /// A model for keeping track of active card in the carousel.
    @ObservedObject private var UIStateCarousel = UIStateModel()
    
    /// Show the carousel or not.
    @State private var carouselShown = true
    
    /// ViewModel for the `SetupView`.
    @ObservedObject private var viewModel: SetupViewModel
    
    /// Get light or dark colorscheme to display different images.
    @Environment(\.colorScheme) private var colorScheme
    
    /// The CoreData context object which we save to persistent storage to.
    @Environment(\.managedObjectContext) var context
    
    init(viewModel: SetupViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        NavigationView {
            VStack {
                // Explanatory carousel
                if carouselShown {
                    SnapCarousel()
                        .environmentObject(UIStateCarousel)
                        .transition(.opacity)
                }
                
                // TextField for setting username
                VStack {
                    TextField("Username", text: $textfieldUsername, onCommit: {
                        }
                    )
                    .keyboardType(.namePhonePad)
                    .padding()
                    .background(
                        colorScheme == .dark ? Color("setup-grayDARK") : Color("setup-grayLIGHT")
                    )
                    .cornerRadius(10.0)
                    .focused($keyboardShown)
                    .onChange(of: keyboardShown) { newValue in
                        withAnimation(.easeInOut(duration: 0.5)) {
                            self.carouselShown.toggle()
                        }
                    }
                    // Guide to username requirements
                    if !(textfieldUsername == "") {
                        if textfieldUsername.count < 4 {
                            Text("Minimum 4 characters.")
                                .font(.footnote)
                                .foregroundColor(.accentColor)
                        } else if textfieldUsername.count > 16 {
                            Text("Maximum 16 characters.")
                                .font(.footnote)
                                .foregroundColor(.accentColor)
                        } else if textfieldUsername.contains(" ") {
                            Text("No spaces in username.")
                                .font(.footnote)
                                .foregroundColor(.accentColor)
                        } else {
                            Text("")
                        }
                    }
                }
                .animation(.spring())
                .padding()
                .autocapitalization(.none)
                .disableAutocorrection(true)
                
                Spacer()
                
                VStack {
                    /*
                     EULA part.
                     */
                    HStack {
                        Text("By continuing you agree to the")
                        Link("EULA", destination: URL(string: "https://www.dimchat.org/eula")!)
                    }
                    
                    /*
                     Enter button which handles setting the username if valid.
                     */
                    Button(action: {
                        viewModel.setUsername(username: textfieldUsername)
                    }, label: {
                        Text("Continue")
                        .padding()
                        .foregroundColor(.white)
                        .frame(minWidth: 0, maxWidth: .infinity)
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [Color("dimOrangeDARK"), Color("dimOrangeLIGHT")]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(10.0)
                    })
                }
                .padding()
                
                // Empty link which takes the user to the main screen if username has been set.
                NavigationLink(
                    destination: HomeView(chatBrain: ChatHandler(context: context))
                                .navigationBarTitle("")
                                .navigationBarBackButtonHidden(true),
                    isActive: 	$viewModel.hasUsername) {
                    EmptyView()
                }
            }
            .onAppear() {
                viewModel.onAppear()
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}


struct SetupView_Previews: PreviewProvider {
    static var previews: some View {
        SetupView(viewModel: Resolver.resolve())
    }
}
