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
    /// True if the keyboard is shown. Used for animations.
    @FocusState private var keyboardShown: Bool
    
    /// A model for keeping track of active card in the carousel.
    @ObservedObject private var carouselViewModel = CarouselViewModel()
    
    /// Show the carousel or not.
    @State private var carouselShown = true
    
    /// ViewModel for the `SetupView`.
    @ObservedObject private var viewModel: SetupViewModel
    
    /// Get light or dark colorscheme to display different images.
    @Environment(\.colorScheme) private var colorScheme
    
    /// The CoreData context object which we save to persistent storage to.
    @Environment(\.managedObjectContext) var context
    
    @State private var usernameTextField = ""
    @State private var usernameTextFieldState: UsernameValidator.State = .undetermined
    
    init(viewModel: SetupViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        NavigationView {
            VStack {
                // Explanatory carousel
                if carouselShown {
                    SnapCarousel()
                        .environmentObject(carouselViewModel)
                        .transition(.opacity)
                }
                
                // TextField for setting username
                VStack {
                    TextField("Username", text: $usernameTextField)
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
                    if case .error(let errorMessage) = viewModel.usernameValidator.state {
                        Text(errorMessage)
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
                        viewModel.usernameValidator.set(username: usernameTextField)
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
                
                // Empty link which takes the user to the main screen if username has been set.
                NavigationLink(isActive: $viewModel.usernameValidator.isUsernameValid) {
                    HomeView(chatHandler: ChatHandler(context: context))
                } label: {
                    EmptyView()
                }
                .navigationBarTitle("")
                .navigationBarBackButtonHidden(true)
            }
            .onAppear() {
                viewModel.onAppear()
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

