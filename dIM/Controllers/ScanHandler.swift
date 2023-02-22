//
//  ScanHandler.swift
//  dIM
//
//  Created by Kasper Munch on 22/02/2023.
//

import Foundation
import CoreData

class ScanHandler {
    enum ScanHandlerError: Error, LocalizedError {
        case invalidFormat
        case userPreviouslyAdded
    }
    
    static func retrieve(result: String, context: NSManagedObjectContext) throws {
        let component = result.components(separatedBy: "//")
        
        guard component.count == 3 else {
            throw ScanHandlerError.invalidFormat
        }
        
        let name = component[1]
        let publicKey = component[2]
        
        let fetchRequest = ConversationEntity.fetchRequest()
        let conversations: [ConversationEntity]
        do {
            conversations = try context.fetch(fetchRequest)
        } catch {
            throw error
        }
        
        if conversations.contains(where: { $0.author == name }) {
            throw ScanHandlerError.userPreviouslyAdded
        }
        
        // Create a new conversation with the added user.
        let conversation = ConversationEntity(context: context)
        conversation.author = name
        conversation.publicKey = publicKey
        
        do {
            try context.save()
        } catch {
            throw error
        }
    }
}
