//
//  ContentView.swift
//  ChatAI
//
//  Created by Aditya Anand on 28/03/25.
//

import SwiftUI
import AIProxy

struct conversationView: View {
    @StateObject var chatController: ChatController
    @State var string: String = ""
    @State private var showingSidebar = false
    @State private var lastMessageId: String?
    @EnvironmentObject var viewModel : AuthViewModel
    
        
    init(authViewModel: AuthViewModel) {
        _chatController = StateObject(wrappedValue: ChatController(authViewModel: authViewModel))
    }
    var body: some View {
        if let user = viewModel.currentUser {
            NavigationStack{
                ZStack{
                    VStack {
                        ScrollViewReader { proxy in
                            ScrollView {
                                VStack(spacing: 8) {
                                    ForEach(chatController.messages) { message in
                                        messageView(message: message)
                                            .id(message.id)
                                            .padding(.horizontal, 8)
                                    }
                                }
                                .padding(.vertical, 8)
                            }
                            .onChange(of: lastMessageId) { id, _ in
                                if let id {
                                    withAnimation {
                                        proxy.scrollTo(id, anchor: .bottom)
                                    }
                                }
                            }
                        }
                        Divider()
                        
                        HStack(alignment: .bottom) {
                            TextField("Type to chat", text: $string, axis: .vertical)
                                .textFieldStyle(.plain)
                                .padding(12)
                                .background(Color.gray.opacity(0.2))
                                .cornerRadius(15)
                                .lineLimit(5)
                            
                            Button {
                                let message = Message(content: string, isUser: true)
                                chatController.messages.append(message)
                                Task {
                                    await chatController.sendMessage(content: message.content)
                                    await MainActor.run {
                                        if let last = chatController.messages.last {
                                            lastMessageId = last.id
                                        }
                                    }
                                }
                                string = ""
                            } label: {
                                Image(systemName: "paperplane.fill")
                                    .padding(10)
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .clipShape(Circle())
                                    .padding(.vertical, 4)
                            }
                            .disabled(chatController.isTyping || string.isEmpty)
                            .opacity(chatController.isTyping || string.isEmpty ? 0.6 : 1.0)
                        }
                        .padding()
                    }
                }
                .overlay {
                    if showingSidebar {
                        Color.black.opacity(0.3)
                            .ignoresSafeArea()
                            .transition(.opacity.animation(.easeInOut(duration: 0.2)))
                            .onTapGesture {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                    showingSidebar = false
                                }
                            }
                            .zIndex(1)
                    }
                }
                .overlay(alignment: .leading) {
                    SidebarView(showingSidebar: $showingSidebar)
                        .environmentObject(chatController)
                        .frame(width: 300)
                        .offset(x: showingSidebar ? 0 : -300)
                        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: showingSidebar)
                        .zIndex(2)
                }
                .navigationTitle(showingSidebar ? "" : chatController.chatTitle)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button {
                            showingSidebar.toggle()
                        } label: {
                            Image(systemName: "line.3.horizontal")
                                .symbolVariant(showingSidebar ? .fill : .none)
                                .font(.system(size: 20, weight: .medium))
                                .frame(width: 44, height: 44)
                                .contentShape(Rectangle())
                        }
                    }
                    ToolbarItem(placement: .topBarTrailing){
                        Button {
                            print("User Profile")
                        } label: {
                            NavigationLink(destination: ProfileView()
                            ){
                                Text(user.initials)
                                    .font(.title3)
                                    .fontWeight(.semibold)
                                    .foregroundStyle(Color(.white))
                                    .frame(width: 40, height: 40)
                                    .background(Color(.systemGray3))
                                    .clipShape(Circle())
                            }
                        }
                    }
                }
            }
        }
        else {
            LoginView()
        }
    }
}

struct SidebarView: View {
    @EnvironmentObject var chatController: ChatController
    @Binding var showingSidebar: Bool
    @State private var searchText = ""
    @State private var isLoading = false
    
    var filteredConversations: [Conversation] {
        if searchText.isEmpty {
            return chatController.conversations
        } else {
            return chatController.conversations.filter { $0.title.localizedCaseInsensitiveContains(searchText) }
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            VStack(alignment: .leading, spacing: 4) {
                Text("Conversations")
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding(.horizontal)
                    .padding(.top, 16)
                
                // Search bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    TextField("Search chats", text: $searchText)
                        .font(.subheadline)
                }
                .padding(8)
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .padding(.horizontal)
                .padding(.bottom, 8)
                
                Divider()
            }
            
            // New Chat Button
            Button(action: {
                chatController.messages = []
                chatController.currentConversationId = nil
                chatController.chatTitle = "New Chat"
                showingSidebar = false
            }) {
                HStack(spacing: 12) {
                    Image(systemName: "plus.circle.fill")
                        .font(.headline)
                    Text("New Chat")
                        .fontWeight(.medium)
                    Spacer()
                }
                .padding(.vertical, 12)
                .padding(.horizontal)
                .background(Color.blue.opacity(0.1))
                .foregroundColor(.blue)
                .cornerRadius(8)
                .padding(.horizontal, 12)
                .padding(.top, 12)
            }
            
            // Conversations List
            if isLoading {
                Spacer()
                ProgressView()
                    .frame(maxWidth: .infinity)
                Spacer()
            } else if filteredConversations.isEmpty {
                Spacer()
                VStack(spacing: 8) {
                    Image(systemName: "bubble.left.and.bubble.right")
                        .font(.system(size: 40))
                        .foregroundColor(.gray)
                    Text(searchText.isEmpty ? "No conversations yet" : "No matching conversations")
                        .font(.headline)
                        .foregroundColor(.gray)
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 40)
                Spacer()
            } else {
                ScrollView {
                    LazyVStack(spacing: 2) {
                        ForEach(filteredConversations) { conversation in
                            ConversationRow(
                                showingSidebar: $showingSidebar,
                                conversation: conversation,
                                isSelected: chatController.currentConversationId == conversation.id
                            )
                        }
                    }
                    .padding(.top, 8)
                }
            }
            
            Spacer()
        }
        .frame(width: 300)
        .background(Color(.systemBackground))
        .onAppear {
            isLoading = true
            Task {
                await chatController.loadUserConversations()
                isLoading = false
            }
        }
    }
}

struct ConversationRow: View {
    @EnvironmentObject var chatController: ChatController
    @Binding var showingSidebar: Bool
    let conversation: Conversation
    let isSelected: Bool
    
    var body: some View {
        Button {
            Task {
                await chatController.loadConversation(conversation: conversation)
                showingSidebar = false
            }
        } label: {
            HStack(alignment: .center, spacing: 12) {
                Image(systemName: "bubble.left.fill")
                    .font(.system(size: 16))
                    .foregroundColor(isSelected ? .white : .blue)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(conversation.title)
                        .foregroundStyle(isSelected ? Color.white : .primary)
                        .fontWeight(.medium)
                        .lineLimit(1)
                    
                    Text(formattedDate(conversation.updatedAt))
                        .font(.caption)
                        .foregroundColor(isSelected ? .white.opacity(0.8) : .gray)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(isSelected ? .white.opacity(0.8) : .gray)
            }
            .padding(.vertical, 12)
            .padding(.horizontal)
            .background(isSelected ? Color.blue : Color.clear)
            .cornerRadius(8)
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
        .padding(.horizontal, 8)
        .contextMenu {
            Button(role: .destructive) {
                // Add delete functionality
                print("Delete conversation")
            } label: {
                Label("Delete", systemImage: "trash")
            }
            
            Button {
                // Add rename functionality
                print("Rename conversation")
            } label: {
                Label("Rename", systemImage: "pencil")
            }
        }
    }
    
    private func formattedDate(_ date: Date) -> String {
        let calendar = Calendar.current
        
        if calendar.isDateInToday(date) {
            let formatter = DateFormatter()
            formatter.dateFormat = "h:mm a"
            return "Today, \(formatter.string(from: date))"
        } else if calendar.isDateInYesterday(date) {
            return "Yesterday"
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "MMM d"
            return formatter.string(from: date)
        }
    }
}

struct validationView : View {
    @EnvironmentObject var viewModel: AuthViewModel
    var body: some View {
        Group{
            if viewModel.userSession != nil {
                conversationView(authViewModel: viewModel)
            }
            else {
                LoginView()
            }
        }
    }
}

#Preview {
    conversationView(authViewModel: AuthViewModel())
        .environmentObject(AuthViewModel())
}
