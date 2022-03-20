//
//  CreateGroupViewModel.swift
//  bluetoothChat
//
//  Created by Kasper Munch on 20/03/2022.
//

import Foundation

class CreateGroupViewModel: ObservableObject {
    @Published var showCreatedGroup = false
    
    private var context = Session.context
    
    public func dismissCreatedGroup() {
        showCreatedGroup = false
    }
    
    public func addGroup(_ name: String, withMember member: ConversationEntity) {
        let newGroup = GroupEntity(context: context)
        newGroup.created = Date()
        newGroup.name = name
        newGroup.lastMessage = "Send a message to the group"
        newGroup.symmetricKey = CryptoHandler.generateSymmetricKey().serialize()
        
        try? context.save()
    }
}
