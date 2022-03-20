//
//  CreateGroupViewModel.swift
//  bluetoothChat
//
//  Created by Kasper Munch on 20/03/2022.
//

import Foundation

class CreateGroupViewModel: ObservableObject {
    @Published var groupName = "" {
        didSet {
            createGroupButtonEnabled = validateGroupName(groupName)
        }
    }
    @Published var showCreatedGroup = false
    @Published var createGroupButtonEnabled = false
    
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
    
    private func validateGroupName(_ name: String) -> Bool {
        if name.count < 4 {
            return false
        } else if name.count > 16 {
            return false
        } else if name.contains(" ") {
            return false
        }
        return true
    }
}
