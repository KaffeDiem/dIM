//
//  SetUpVoew.swift
//  bluetoothChat
//
//  Created by Kasper Munch on 26/08/2021.
//

import SwiftUI

/**
 SetUpView handles all initial first logins where users choose a username
 and are then redirected to ContentView which is the main View of the app.
 */
struct SetupView: View {
    /// CoreDate context object
    @Environment(\.managedObjectContext) var context
    @Environment(\.colorScheme) private var colorScheme
    
    /// True if the keyboard is shown. Used for animations.
    @FocusState private var keyboardShown: Bool
    
    /// A model for keeping track of active card in the carousel.
    @ObservedObject private var carouselViewModel = CarouselViewModel()
    
    /// Show the carousel or not.
    @State private var carouselShown = true
    
    @ObservedObject private var usernameValidator = UsernameValidator()
    
    @State private var usernameTextField = ""
    @State private var usernameTextFieldState: UsernameValidator.State = .undetermined
    
    var body: some View {
        NavigationView {
            if usernameValidator.isUsernameValid {
                HomeView(appSession: AppSession(context: context))
                    .navigationBarTitle("")
                    .navigationBarBackButtonHidden(true)
            } else {
                VStack {
                    // Explanatory carousel
                    if carouselShown {
                        SnapCarousel()
                            .environmentObject(carouselViewModel)
                            .transition(.opacity)
                    }
                    
                    // TextField for setting username
                    VStack {
                        TextField("Enter username", text: $usernameTextField) {
                            hideKeyboard()
                        }
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
                        
                        // Show a warning if username is invalid
                        if case .error(let errorMessage) = usernameValidator.validate(username: usernameTextField) {
                            Text(usernameTextField.isEmpty ? "" : errorMessage)
                                .font(.footnote)
                                .foregroundColor(.accentColor)
                        }
                    }
                    .animation(.spring())
                    .padding()
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    
                    Spacer()
                    
                    VStack {
                        // EULA part.
                        HStack {
                            Text("By continuing you agree to the")
                            Link("EULA", destination: URL(string: "https://www.dimchat.org/eula")!)
                        }
                        
                        // Enter button
                        Button {
                            usernameValidator.set(username: usernameTextField, context: context)
                        } label: {
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
                        }
                    }
                    .padding()
                }
                .onTapGesture {
                    hideKeyboard()
                }
                .onAppear {
                    UNUserNotificationCenter.current().requestAuthorization(
                        options: [.alert, .badge, .sound]
                    ) { success, error in
                        if success {
                            print("All set!")
                        } else if let e = error {
                            print(e.localizedDescription)
                        }
                    }
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

