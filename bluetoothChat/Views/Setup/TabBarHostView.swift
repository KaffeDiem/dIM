//
//  TabBarHostView.swift
//  bluetoothChat
//
//  Created by Kasper Munch on 20/03/2022.
//

import SwiftUI

struct TabBarHostView: View {
    
    var body: some View {
        if Session.username != nil {
            TabView {
                HomeView()
                    .tabItem {
                        Label("Chats", systemImage: "bubble.left.and.bubble.right.fill")
                    }
                GroupView()
                    .tabItem {
                        Label("Groups", systemImage: "person.3")
                    }
            }
        } else {
            SetupView(viewModel: SetupViewModel())
        }
    }
}

struct TabBarHostView_Previews: PreviewProvider {
    static var previews: some View {
        TabBarHostView()
    }
}
