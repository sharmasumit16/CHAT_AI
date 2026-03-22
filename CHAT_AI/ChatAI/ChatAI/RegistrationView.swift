//
//  RegistrationView.swift
//  ChatAI
//
//  Created by Aditya Anand on 02/04/25.
//

import SwiftUI

struct RegistrationView: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var name : String = ""
    @State private var confirmPassword : String = ""
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var viewModel: AuthViewModel
    
    var body: some View {
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
                
                InputView(text: $name,
                          title: "Your Name",
                          placeholder: "John Smith")
                
                InputView(text: $password,
                          title: "Password",
                          placeholder: "Enter Password",
                          isSecureField: true)
                .autocapitalization(.none)
                ZStack(alignment: .trailing) {
                    InputView(text: $confirmPassword,
                              title: "Confirm Password",
                              placeholder: "Confirm Your Password",
                              isSecureField: true)
                    .autocapitalization(.none)
                    
                    if !password.isEmpty && !confirmPassword.isEmpty {
                        if confirmPassword != password {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.red)
                        } else {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(Color(.green))
                                .foregroundColor(.green)
                                .padding()
                        }
                    }
                }
            }
            .padding(.horizontal)
            .padding(.top, 12)
            
            Button {
                Task{
                    try await viewModel.createUser(withEmail: email, password: password, fullName: name)
                }
            } label: {
                HStack{
                    Text("SIGN UP")
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
            
            Button {
                dismiss()
            } label: {
                HStack(spacing: 3){
                    Text("Already have an account?")
                        .foregroundStyle(Color(.blue))
                    Text("Sign In")
                        .foregroundStyle(Color(.blue))
                        .fontWeight(.semibold)
                }
            }

        }
    }
}

extension RegistrationView: AuthenticationFormProtocol {
    var formIsValid: Bool {
        return !email.isEmpty
        && email.contains("@")
        && !password.isEmpty
        && password.count >= 6
        && !name.isEmpty
        && confirmPassword == password
    }
}

#Preview {
    RegistrationView()
}
