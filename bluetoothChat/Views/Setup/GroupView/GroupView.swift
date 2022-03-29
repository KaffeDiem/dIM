//
//  GroupView.swift
//  bluetoothChat
//
//  Created by Kasper Munch on 27/03/2022.
//

import SwiftUI

struct GroupView: View {
    @FetchRequest(
        entity: GroupEntity.entity(),
        sortDescriptors: [
            NSSortDescriptor(keyPath: \GroupEntity.created, ascending: false)
        ]
    ) var groups: FetchedResults<GroupEntity>
    
    var body: some View {
        NavigationView {
            List(groups) { group in
                NavigationLink {
                    GroupChatView(group: group)
                } label: {
                    ChatListCell(
                        title: group.name ?? "Unknown",
                        lastMessage: group.lastMessage ?? "Send the first message to the group."
                    )
                }
                .listRowSeparator(.hidden)
            }
        
        .toolbar {
            ToolbarItem(placement: .principal) {
                VStack {
                    Text("Groups")
                        .font(.headline)
                    if Session.chatHandler.discoveredDevices.count < 1 {
                        HStack {
                            Image(systemName: "antenna.radiowaves.left.and.right.slash")
                                .symbolRenderingMode(.palette)
                                .foregroundStyle(.red, .orange, .white)
                            Text("Not connected")
                                .foregroundColor(.accentColor)
                                .font(.subheadline)
                        }
                    } else {
                        HStack {
                            Image(systemName: "antenna.radiowaves.left.and.right")
                            Text("\(Session.chatHandler.discoveredDevices.count) in range").font(.subheadline)
                        }
                    }
                }
            }
            ToolbarItem(placement: .navigationBarLeading) {
                NavigationLink(destination: SettingsView(), label: {
                    Image(systemName: "gearshape.fill")
                })
            }
        }
        .navigationTitle("Groups")
        }
    }
}

struct GroupView_Previews: PreviewProvider {
    static var previews: some View {
        GroupView()
    }
}
