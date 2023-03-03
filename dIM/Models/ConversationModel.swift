//
//  ConversationModel.swift
//  bluetoothChat
//
//  Created by Kasper Munch on 24/08/2021.
//

import Foundation
import CoreData

/// A conversation is a thread of messages with some user that you have added.
///
/// Conversations have an unique id and holds all the messages in that conversation.
/// This includes the messages that you have sent as well.
struct Conversation: Identifiable {
    /// An unique identifier for the conversation
    var id: Int32
    /// The author - or the username of the person who is not you.
    var author: String
    /// The last message sent in the conversation. This includes yours and the authors last message.
    var lastMessage: LocalMessage
    /// A list of all messages sent in the conversation.
    var messages: [LocalMessage]
    
    /// Add a message to the end of a conversation thread.
    /// - Parameter message: The message to append to the array of messages.
    mutating func addMessage(add message: LocalMessage) {
        messages.append(message)
    }
    
    /// Update the last message in the thread.
    ///
    /// This is the message shown on the `ContentView`.
    /// - Parameter message: The message to set last message to.
    mutating func updateLastMessage(new message: LocalMessage) {
        lastMessage = message
    }
}

extension Conversation {
    static func map(conversationEntities: [ConversationEntity]) -> [Conversation] {
        return conversationEntities.map { conversationEntity in
            let messages: [LocalMessage] = []
            Conversation(
                id: conversationEntity.id,
                author: conversationEntity.author,
                lastMessage: conversationEntity.lastMessage,
                messages: messages
            )
        }
    }
}

class ConversationStorage: NSObject, ObservableObject {
    @Published var conversations: [Conversation] = []
    private let conversationsController: NSFetchedResultsController<ConversationEntity>
    
    init(managedObjectContext: NSManagedObjectContext) {
        conversationsController = NSFetchedResultsController(
            fetchRequest: ConversationEntity.fetchRequest(),
            managedObjectContext: managedObjectContext,
            sectionNameKeyPath: nil, cacheName: nil)
        super.init()
        
        conversationsController.delegate = self
        
        do {
            try conversationsController.performFetch()
            conversations = conversationsController.fetchedObjects.map { Conversation.map(conversationEntities: $0) } ?? []
        } catch {
            print("Failed to fetch conversations.")
        }
    }
}


extension ConversationStorage: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        guard let conversations = controller.fetchedObjects as? [ConversationEntity] else { return }
        self.conversations = conversations
    }
}
