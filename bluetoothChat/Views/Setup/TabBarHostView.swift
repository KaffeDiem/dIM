//
//  TabBarHostView.swift
//  bluetoothChat
//
//  Created by Kasper Munch on 20/03/2022.
//

import SwiftUI

struct TabBarHostView: View {
    
    @FetchRequest(
        entity: GroupEntity.entity(),
        sortDescriptors: [
            NSSortDescriptor(keyPath: \GroupEntity.created, ascending: false)
        ]
    ) var groups: FetchedResults<GroupEntity>
    
    var body: some View {
        if Session.username != nil {
            TabView {
                HomeView()
                    .tabItem {
                        Label("Chats", systemImage: "bubble.left.and.bubble.right.fill")
                    }
                NavigationView {
                    List(groups) { group in
                        Text(group.name ?? "Uknown")
                    }
                }
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
