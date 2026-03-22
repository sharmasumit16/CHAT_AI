//
//  User.swift
//  ChatAI
//
//  Created by Aditya Anand on 03/04/25.
//

import Foundation

struct User: Identifiable, Codable {
    let id: String
    let fullname: String
    let email: String
    
    var initials: String{ //closure
        let formatter = PersonNameComponentsFormatter()
        if let components = formatter.personNameComponents(from: fullname) {
            formatter.style = .abbreviated
            return formatter.string(from: components)
        }
        return ""
    }
}

extension User {
    static var Mock_User = User(id: NSUUID().uuidString, fullname: "Taylor Swift", email: "taylor13@gmail.com")
}
