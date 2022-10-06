//
//  OnboardingView.swift
//  bluetoothChat
//
//  Created by Kasper Munch on 23/12/2021.
//

import SwiftUI

/// Loaded on first launch to teach the user of the concept.
struct OnboardingView: View {
    @State var currentIndex = 0
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                TabView(selection: $currentIndex) {
                    ZStack {
                        VStack {
                            VStack {
                                Spacer()
                                Image("OnboardingMulti")
                                    .resizable()
                                    .scaledToFit()
                                    .padding()
                            }
                        }
                        VStack {
                            Text("SEND OFFLINE MESSAGES")
                                .foregroundColor(.orange)
                                .bold()
                                .font(.largeTitle)
                                .multilineTextAlignment(.center)
                                .padding()
                            Text("Messages are sent through Bluetooth instead of WiFi or Mobile Data. Therefore no internet access is needed for the chat to work.")
                                .padding()
                            Spacer()
                        }
                    }
                    .tag(0)
                    
                    VStack {
                        Text("HOW IT WORKS")
                            .foregroundColor(.orange)
                            .bold()
                            .font(.largeTitle)
                            .multilineTextAlignment(.center)
                            .padding()
                        Spacer()
                    }
                    .tag(1)
                    
                    VStack {
                        Text("ADD YOUR FRIENDS AND FAMILY")
                            .foregroundColor(.orange)
                            .bold()
                            .font(.largeTitle)
                            .multilineTextAlignment(.center)
                            .padding()
                        Spacer()
                    }
                    .tag(2)
                }
                .tabViewStyle(PageTabViewStyle())
                .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
            }
        }
        .background(.gray)
    }
}

struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView()
            .preferredColorScheme(.dark)
    }
}
