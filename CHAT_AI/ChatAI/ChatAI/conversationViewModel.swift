//
//  conversationViewModel.swift
//  ChatAI
//
//  Created by Aditya Anand on 02/04/25.
//

import SwiftUI
import AIProxy
import FirebaseFirestore

struct Message : Identifiable, Codable {
    var id: String = UUID().uuidString
    var content : String
    var isUser : Bool
    var timestamp : Date = Date()
}

struct Conversation: Identifiable, Codable {
    var id: String
    var title: String
    var createdAt: Date
    var updatedAt: Date
}

@MainActor
class ChatController : ObservableObject {
    //    @Published var messages : [Message] = [.init(content: "Hello", isUser: false), .init(content: "Hello", isUser: true)]
    @Published var messages : [Message] = []
    @Published var conversations: [Conversation] = []
    @Published var chatTitle : String = "New Chat"
    @Published var currentConversationId: String?
    @Published var isTyping = false
    var selectedPersona: Persona = Personas.defaultPersona
    private let db = Firestore.firestore()
    let openRouterService = AIProxy.openRouterDirectService(unprotectedAPIKey: constants.openRouterAPI.rawValue)
    let fireStoreManager = FirestoreManager()
    private let authViewModel: AuthViewModel
    init(authViewModel: AuthViewModel) {
            self.authViewModel = authViewModel
        }
    
    private func verifyAuth() -> String {
        return authViewModel.currentUser?.id ?? ""
    }
    
    private func userConversationsRef() -> CollectionReference {
            let userId = verifyAuth()
            return db.collection("users").document(userId).collection("conversations")
        }
    
    func provideTitle(for conversation: String) async throws -> String{
        let content = "Give me a one-liner topic/subject/summary of the chat started with \(messages.first!.content). Do not write **Summary**: or anything similar, just give me a one-liner title. There is no need to explain a thing twice in the title, just a one-liner. I will do my best to give you a title that is concise and to the point. Say we have a prompt 'what is 2+2' and the reponse should be 'Basic Arithmetic' and not 'Basic Arithmetic: Calculating the sum of 2+2'"
        
        let requestBody = OpenRouterChatCompletionRequestBody(
            messages: [
                .system(content: .text("You are an assistant.")),
                .user(content: .text(content))
            ],
            includeReasoning: false,
            models: ["deepseek/deepseek-r1"],
            temperature: 0.9
        )
        
        do {
            let stream = try await openRouterService.streamingChatCompletionRequest(body: requestBody)
            var botReply = ""
            
            for try await chunk in stream {
                if let messageContent = chunk.choices.first?.delta.content {
                    botReply += messageContent
                }
            }
            return botReply
        } catch {
            print("Could not get bot reply: \(error.localizedDescription)")
            throw error
        }
    }
    
    func startNewConversation(for userMessage: Message) async {
        do {
            let conversationsRef = userConversationsRef()
            let conversationRef = conversationsRef.document()
            
            chatTitle = try await provideTitle(for: userMessage.content)
            
            let conversation = Conversation(
                id: conversationRef.documentID,
                title: chatTitle,
                createdAt: Date(),
                updatedAt: Date()
            )
            
            try conversationRef.setData(from: conversation)
            currentConversationId = conversationRef.documentID
            
        } catch {
            print("Error creating conversation: \(error.localizedDescription)")
        }
    }
    
    func sendMessage(content: String) async {
        let userMessage = Message(content: content, isUser: true)
        print(userMessage.content)
        
        if currentConversationId == nil {
            await startNewConversation(for: userMessage)
        }
        
        guard let conversationId = currentConversationId else {
            print("Failed to create conversation")
            return
        }
        
        do {
            try await saveMessage(userMessage, conversationId: conversationId)
            await MainActor.run {
                isTyping = true
            }
            await getBotReply(for: userMessage, conversationId: conversationId)
            await MainActor.run {
                isTyping = false
            }
        } catch {
            print("Error saving message: \(error)")
        }
    }
    
    func saveMessage(_ message: Message, conversationId: String) async throws {
        let conversationsRef = userConversationsRef()
        let conversationRef = conversationsRef.document(conversationId)
        
        let document = try await conversationRef.getDocument()
        guard document.exists else {
            throw ChatError.invalidConversation
        }
        
        let batch = db.batch()
        
        let messageRef = conversationRef
            .collection("messages")
            .document(message.id)
        
        batch.setData([
            "id": message.id,
            "content": message.content,
            "isUser": message.isUser,
            "timestamp": FieldValue.serverTimestamp()
        ], forDocument: messageRef)
        
        batch.updateData(["updatedAt": FieldValue.serverTimestamp()],
                        forDocument: conversationRef)
        
        try await batch.commit()
    }
    
    func loadMessages(conversationId: String) async throws -> [Message] {
        let userId = verifyAuth()
        let snapshot = try await db.collection("users")
            .document(userId)
            .collection("conversations")
            .document(conversationId)
            .collection("messages")
            .order(by: "timestamp")
            .getDocuments()
        
        let messages = snapshot.documents.compactMap { document in
            do {
                return try document.data(as: Message.self)
            } catch {
                print("Error decoding message: \(error)")
                return nil
            }
        }
        
        print("Loaded \(messages.count) messages for conversation \(conversationId)")
        return messages
    }
    
    func loadConversation(conversation: Conversation) async {
        do {
            let loadedMessages = try await loadMessages(conversationId: conversation.id)
            await MainActor.run {
                self.messages = loadedMessages
                self.currentConversationId = conversation.id
                self.chatTitle = conversation.title
            }
            
        } catch {
            print("Failed to load conversation: \(error)")
            await MainActor.run {
                self.messages = []
                self.chatTitle = "Error loading conversation"
            }
        }
    }
    
    func loadUserConversations() async {    
        do {
            let conversationsRef = userConversationsRef()
            let snapshot = try await conversationsRef
                .order(by: "updatedAt", descending: true)
                .getDocuments()
            
            let loadedConversations = snapshot.documents.compactMap { document in
                try? document.data(as: Conversation.self)
            }
            
            await MainActor.run {
                conversations = loadedConversations
            }
            
        } catch {
            print("Error loading conversations: \(error)")
            await MainActor.run {
                conversations = []
            }
        }
    }
    
    func getConversationTitle(for id: String) -> String {
        conversations.first { $0.id == id }?.title ?? "Untitled Conversation"
    }
    
    func getBotReply(for userMessage: Message, conversationId: String) async {
        let requestBody = OpenRouterChatCompletionRequestBody(
            messages: [
                .system(content: .text(selectedPersona.systemPrompt)),
                .user(content: .text(userMessage.content))
            ],
            includeReasoning: false,
            models: ["deepseek/deepseek-r1"],
            temperature: selectedPersona.temperature
        )

        do {
            let stream = try await openRouterService.streamingChatCompletionRequest(body: requestBody)
            var botReply = ""
            var tempMessage = Message(content: "", isUser: false)
            self.messages.append(tempMessage)
            
            for try await chunk in stream {
                if let messageContent = chunk.choices.first?.delta.content {
                    botReply += messageContent
                    tempMessage.content = botReply
                    if let lastIndex = self.messages.indices.last {
                        self.messages[lastIndex] = tempMessage
                    }
                }
            }

            try await saveMessage(tempMessage, conversationId: conversationId)

        } catch {
            print("Could not get bot reply: \(error.localizedDescription)")
            await MainActor.run {
                self.messages.append(Message(content: "Sorry, I encountered an error: \(error.localizedDescription)", isUser: false))
                self.isTyping = false
            }
        }
    }
}

enum ChatError: Error {
    case unauthenticated
    case invalidConversation
    case firestoreError(Error)
    
    var localizedDescription: String {
        switch self {
        case .unauthenticated: return "Please sign in to continue"
        case .invalidConversation: return "Conversation not found"
        case .firestoreError(let error): return "Database error: \(error.localizedDescription)"
        }
    }
}
    
