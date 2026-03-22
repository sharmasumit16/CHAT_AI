//
//  AuthViewModel.swift
//  ChatAI
//
//  Created by Aditya Anand on 03/04/25.
//

import Foundation
import Firebase
import FirebaseAuth
import FirebaseFirestore

protocol AuthenticationFormProtocol {
    var formIsValid : Bool { get }
}

@MainActor
class AuthViewModel: ObservableObject {
    @Published var userSession: FirebaseAuth.User?
    @Published var currentUser: User?
    
    init(){
        self.userSession = Auth.auth().currentUser
        Task {
            await fetchUserData()
        }
    }
    
    func signIn(withEmail email: String, password: String) async throws{
        do {
            let result = try await Auth.auth().signIn(withEmail: email, password: password)
            self.userSession = result.user
            await fetchUserData()
        }catch {
            print("DEBUG: failed to sign in \(error.localizedDescription)")
        }
    }

    func createUser(withEmail email: String, password: String, fullName: String) async throws {
        do{
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            self.userSession = result.user
            let user = User(id: result.user.uid, fullname: fullName, email: email)
            let encodeUser = try Firestore.Encoder().encode(user)
            try await Firestore.firestore().collection("users").document(result.user.uid).setData(encodeUser)
            await fetchUserData()
        } catch {
            print("failed to create user \(error.localizedDescription)")
        }
    }
    
    func signOut(){
        do{
            try Auth.auth().signOut()
            self.userSession = nil
            self.currentUser = nil
        } catch {
            print("Failed to sign out \(error.localizedDescription)")
        }
    }
    func deleteAccount(){
        guard let user = Auth.auth().currentUser else { return }
        Firestore.firestore().collection("users").document(Auth.auth().currentUser!.uid).delete()
        user.delete()
        signOut()
    }
    
    func fetchUserData() async {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        guard let snapshot = try? await Firestore.firestore().collection("users").document(uid).getDocument() else { return }
        do {
            self.currentUser = try snapshot.data(as: User.self)
        } catch {
            print("failed to fetch user data \(error.localizedDescription)")
        }
        print("DEBUG: Current user is \(String(describing: self.currentUser ?? nil))")
    }
}
