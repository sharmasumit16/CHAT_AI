//
//  FirebaseChatManagement.swift
//  ChatAI
//
//  Created by Aditya Anand on 27/04/25.
//

import FirebaseFirestore

class FirestoreManager {
    static let shared = FirestoreManager()
    private let db = Firestore.firestore()
    
    init() {}
    

    private let conversationsCollection = "conversations"
    private let messagesCollection = "messages"
    
    func createNewConversation(title: String) async throws -> String {
        let conversationRef = db.collection(conversationsCollection).document()
        let conversation = Conversation(
            id: conversationRef.documentID,
            title: title,
            createdAt: Date(),
            updatedAt: Date()
        )
        try conversationRef.setData(from: conversation)
        return conversationRef.documentID
    }
    

    func saveMessage(_ message: Message, to conversationId: String) async throws {
        let messagesRef = db.collection(conversationsCollection)
            .document(conversationId)
            .collection(messagesCollection)
            .document(message.id)
        
        try messagesRef.setData(from: message)
        let conversationRef = db.collection(conversationsCollection).document(conversationId)
        try await conversationRef.updateData([
            "updatedAt": FieldValue.serverTimestamp()
        ])
    }
    

    func loadConversations() async throws -> [Conversation] {
        let snapshot = try await db.collection(conversationsCollection)
            .order(by: "updatedAt", descending: true)
            .getDocuments()
        
        return snapshot.documents.compactMap { document in
            try? document.data(as: Conversation.self)
        }
    }
    
    func loadMessages(for conversationId: String) async throws -> [Message] {
        let snapshot = try await db.collection(conversationsCollection)
            .document(conversationId)
            .collection(messagesCollection)
            .order(by: "timestamp")
            .getDocuments()
        
        return snapshot.documents.compactMap { document in
            try? document.data(as: Message.self)
        }
    }
}
