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
            }
        }
    }
}

struct GroupView_Previews: PreviewProvider {
    static var previews: some View {
        GroupView()
    }
}
