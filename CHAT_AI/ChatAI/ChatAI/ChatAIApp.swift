//
//  ChatAIApp.swift
//  ChatAI
//
//  Created by Aditya Anand on 28/03/25.
//

import SwiftUI
import FirebaseCore

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()
    return true
  }
}

@main
struct ChatAIApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject var viewModel = AuthViewModel()
    @StateObject var chatController = ChatController(authViewModel: AuthViewModel())
    
    var body: some Scene {
        WindowGroup {
            validationView()
                .environmentObject(viewModel)
                .environmentObject(chatController)
        }
    }
}
