//
//  Persona.swift
//  ChatAI
//
//  Created by Aditya Anand on 30/04/25.
//

import Foundation

struct Persona {
    let name: String
    let systemPrompt: String
    let temperature: Double
}

enum Personas {
    static let defaultPersona = Persona(
        name: "Default",
        systemPrompt: "You are an assistant.",
        temperature: 1.0
    )
    
    static let dataAnalysis = Persona(
        name: "Data Analysis",
        systemPrompt: "You're a friendly and helpful assistant. Always respond with a warm tone.",
        temperature: 1.0
    )

    static let generalConversation = Persona(
        name: "General Conversation",
        systemPrompt: "You are a bot who is good are general communication.",
        temperature: 1.3
    )
    
    static let translation = Persona(
        name: "Translation",
        systemPrompt: "You are a bot who is good in translating.",
        temperature: 1.3
    )

    static let codingMath = Persona(
        name: "Coding and Math",
        systemPrompt: "You're a highly professional and concise mathematics and programming assistant.",
        temperature: 0.0
    )
    
    static let creative = Persona(
        name: "Creative Writing and Poetry",
        systemPrompt: "You're a highly creative and imaginative writing assistant, expert in writing and poetry.",
        temperature: 1.5
    )
}

