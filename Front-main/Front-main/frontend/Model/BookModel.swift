//
//  BookModel.swift
//  CineTome
//
//  Created by 596 on 22.04.2025.
//

import Foundation

struct Book: Codable, Identifiable, Equatable {
    let id: String
    let title: String
    let authors: [String]
    let year: Int?
    let coverUrl: String?

    enum CodingKeys: String, CodingKey {
        case id = "work_id"
        case title
        case authors
        case year
        case coverUrl = "cover_url"
    }
}

struct BookSearchResult: Codable, Identifiable {
    let id: String
    let title: String
    let authors: [String]
    let year: Int?
    let coverUrl: String?
    let description: String?
    let subjects: [String]?
    let rating: Double?

    enum CodingKeys: String, CodingKey {
        case id = "work_id"
        case title
        case authors
        case year
        case coverUrl = "cover_url"
        case description
        case subjects
        case rating
    }
}

struct BookDetails: Codable {
    let title: String
    let authors: [String]
    let publishYear: Int?
    let description: String?
    let coverUrl: String?
    let openlibraryUrl: String

    enum CodingKeys: String, CodingKey {
        case title
        case authors
        case publishYear = "publish_year"
        case description
        case coverUrl = "cover_url"
        case openlibraryUrl = "openlibrary_url"
    }
}
