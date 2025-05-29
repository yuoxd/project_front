//
//  Auth.swift
//  frontend
//
//  Created by 596 on 16.05.2025.
//

import Foundation

struct RegistrationResponse: Codable {
    let username: String
    let email: String
    let id: Int
    let preferences: UserPreferences  // Используем UserPreferences из User.swift
    
    enum CodingKeys: String, CodingKey {
        case username, email, id
        case preferences
    }
}

struct LoginRequest: Codable {
    let email: String
    let password: String
}

struct AuthResponse: Codable {
    let token: String
    let tokenType: String
    
    enum CodingKeys: String, CodingKey {
        case token = "access_token"
        case tokenType = "token_type"
    }
}
