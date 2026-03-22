//
//  LoginView.swift
//  ChatAI
//
//  Created by Aditya Anand on 02/04/25.
//

import SwiftUI
import Firebase
import FirebaseAuth

struct LoginView: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @EnvironmentObject var viewModel: AuthViewModel
    
    var body: some View {
        NavigationStack {
            VStack {
                Image(systemName: "quote.bubble")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 100, height: 100)
                    .padding(.vertical, 32)
                    .foregroundColor(.blue)
                
                
                VStack(spacing: 24){
                    InputView(text: $email,
                              title: "Email",
                              placeholder: "name@example.com")
                    .autocapitalization(.none)
                    
                    InputView(text: $password,
                              title: "Password",
                              placeholder: "Enter Password",
                              isSecureField: true)
                    .autocapitalization(.none)
                }
                .padding(.horizontal)
                .padding(.top, 12)
                
                Button {
                    Task{
                        try await viewModel.signIn(withEmail: email, password: password)
                    }
                } label: {
                    HStack{
                        Text("SIGN IN")
                            .fontWeight(.semibold)
                        Image(systemName: "arrow.right")
                    }
                    .foregroundStyle(Color(.white))
                    .frame(width: UIScreen.main.bounds.width-32, height: 48)
                }
                .background(.blue)
                .disabled(!formIsValid)
                .opacity(formIsValid ? 1.0 : 0.5)
                .cornerRadius(10)
                .padding(.top, 24)
                
                Spacer()
                NavigationLink (
                    destination: RegistrationView()
                        .navigationBarBackButtonHidden(true)
                ){
                    HStack(spacing: 3){
                        Text("Don't have an account?")
                            .foregroundStyle(Color(.blue))
                        Text("Sign Up")
                            .foregroundStyle(Color(.blue))
                            .fontWeight(.semibold)
                    }
                    .font(.system(size: 14))
                    .padding(.vertical, 10)
                    .contentShape(Rectangle())
                }
            }
        }
    }
}

extension LoginView: AuthenticationFormProtocol {
    var formIsValid: Bool {
        return !email.isEmpty
        && email.contains("@")
        && !password.isEmpty
        && password.count >= 6
    }
}

#Preview {
    LoginView()
}
