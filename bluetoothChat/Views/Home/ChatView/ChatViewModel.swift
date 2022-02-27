//
//  ChatViewModel.swift
//  bluetoothChat
//
//  Created by Kasper Munch on 27/02/2022.
//

import Foundation

class ChatViewModel: ObservableObject {
    
    @Published var conversation: ConversationEntity
    
    init(forConversation conversation: ConversationEntity) {
        self.conversation = conversation
    }
    
    func onAppear() {
        sendReadReceipt()
    }
    
    func onDissapear() {
        sendReadReceipt()
    }
    
    func createGroup() {
        
    }
    
    private func sendReadReceipt() {
        if UserDefaults.standard.bool(forKey: "settings.readmessages") {
            Session.chatHandler.sendReadMessage(conversation)
        }
    }
}
