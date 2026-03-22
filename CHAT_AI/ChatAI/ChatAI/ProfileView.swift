//
//  ProfileView.swift
//  ChatAI
//
//  Created by Aditya Anand on 03/04/25.
//

import SwiftUI

struct ProfileView: View {
    @State private var selectedPersona: Persona = Personas.defaultPersona
    @EnvironmentObject var viewModel : AuthViewModel
    var body: some View {
        NavigationStack{
            if let user = viewModel.currentUser{
                List{
                    Section("Personal Information"){
                        HStack{
                            Text(user.initials)
                                .font(.title)
                                .fontWeight(.semibold)
                                .frame(width: 72, height: 72)
                                .background(Color(.systemGray3))
                                .clipShape(Circle())
                                .foregroundColor(.white)
                            
                            VStack(alignment: .leading, spacing: 4){
                                Text(user.fullname)
                                    .font(.headline)
                                Text(user.email)
                                    .font(.caption)
                                    .foregroundStyle(Color(.blue))
                            }
                        }
                    }
                    Section("Settings") {
                        NavigationLink {
                            PersonaSelectionView(selectedPersona: $selectedPersona)
                        } label: {
                            rowView(title: "Select Persona", imageName: "person.2", color: .primary)
                        }
                    }
                    Section("General"){
                        Button {
                            viewModel.signOut()
                        } label: {
                            rowView(title: "Sign Out", imageName: "arrow.left.circle", color: .primary)
                        }
                        Button {
                            viewModel.deleteAccount()
                        } label: {
                            rowView(title: "Delete Account", imageName: "x.circle", color: .red)
                                .foregroundStyle(Color.red)
                        }
                    }
                }
            }
        }
    }
}

struct rowView: View {
    let title: String
    let imageName: String?
    var color: Color = .primary
    var showCheckmark: Bool = false

    var body: some View {
        HStack {
            if(imageName != ""){
                Image(systemName: imageName!)
            }
            Text(title)
                .font(.subheadline)
                .fontWeight(.semibold)
            Spacer()
            if showCheckmark {
                Image(systemName: "checkmark")
                    .foregroundColor(.blue)
            }
        }
        .foregroundColor(color)
    }
}

struct PersonaSelectionView: View {
    @Binding var selectedPersona: Persona
    let personas = [
        Personas.defaultPersona,
        Personas.dataAnalysis,
        Personas.generalConversation,
        Personas.translation,
        Personas.codingMath,
        Personas.creative
    ]

    var body: some View {
        List {
            ForEach(personas, id: \.name) { persona in
                Button {
                    selectedPersona = persona
                } label: {
                    rowView(
                        title: persona.name,
                        imageName: "",
                        showCheckmark: selectedPersona.name == persona.name
                    )
                }
            }
        }
        .navigationTitle("Select Persona")
    }
}


#Preview {
    ProfileView()
}
