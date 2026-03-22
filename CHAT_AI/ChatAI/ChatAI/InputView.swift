//
//  InputView.swift
//  ChatAI
//
//  Created by Aditya Anand on 02/04/25.
//

import SwiftUI

struct InputView: View {
    @Binding var text: String
    let title : String
    let placeholder : String
    var isSecureField : Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12){
            Text(title)
                .foregroundColor(Color(.darkGray))
                .fontWeight(.semibold)
                .font(.footnote)
            
            if isSecureField {
                SecureField(placeholder, text: $text)
                    .font(.system(size: 14))
            } else {
                TextField(placeholder, text: $text)
                    .font(.system(size: 14))
            }
            
        }
    }
}

#Preview {
    InputView(text: .constant(""), title: "Email Address", placeholder: "name@example.com")
}
