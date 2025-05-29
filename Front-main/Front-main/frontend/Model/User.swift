//
//  User.swift
//  frontend
//
//  Created by 596 on 16.05.2025.
//

import Foundation

import Foundation

struct User: Codable {
    let id: Int
    let username: String
    let email: String
    let preferences: UserPreferences?
}

struct UserPreferences: Codable {
    let favoriteGenres: [String]?
    let favoriteAuthors: [String]?
    
    enum CodingKeys: String, CodingKey {
        case favoriteGenres = "favorite_genres"
        case favoriteAuthors = "favorite_authors"
    }
}

struct UpdatePreferencesRequest: Codable {
    let favoriteGenres: [String]?
    let favoriteAuthors: [String]?
    
    enum CodingKeys: String, CodingKey {
        case favoriteGenres = "favorite_genres"
        case favoriteAuthors = "favorite_authors"
    }
}
