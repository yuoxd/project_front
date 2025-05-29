//
//  BookViewModel.swift
//  frontend
//
//  Created by 596 on 16.05.2025.
//

import Foundation

class BookViewModel: ObservableObject {
    @Published var popularBooks: [Book] = []
    @Published var newBooks: [Book] = []
    @Published var recommendedBooks: [Book] = []
    @Published var fantasyBooks: [Book] = []
    @Published var searchResults: [Book] = []
    @Published var isLoading = false
    @Published var error: String?
    
    private let apiClient = ApiClient()
    
    @MainActor
    func loadBooks() async {
        isLoading = true
        error = nil
        
        do {
            // Популярные книги: query="fiction", sortByPopularity=true
            async let popular = apiClient.searchBooks(
                query: "fiction",
                limit: 10,
                page: 1,
                searchType: "subject",
                sortByPopularity: true,
                sortByNew: false,
                translate: false
            )
            
            // Новые книги: query="fiction", sortByNew=true
            async let new = apiClient.searchBooks(
                query: "fiction",
                limit: 10,
                page: 1,
                searchType: "subject",
                sortByPopularity: false,
                sortByNew: true,
                translate: false
            )
            
            // Рекомендованные книги: query="bestseller", searchType="recommended"
            async let recommended = apiClient.searchBooks(
                query: "bestseller",
                limit: 10,
                page: 1,
                searchType: "recommended",
                sortByPopularity: false,
                sortByNew: false,
                translate: false
            )
            
            // Фэнтези книги: query="fantasy", searchType="subject"
            async let fantasy = apiClient.searchBooks(
                query: "fantasy",
                limit: 10,
                page: 1,
                searchType: "subject",
                sortByPopularity: false,
                sortByNew: false,
                translate: false
            )
            
            let results = try await (popular, new, recommended, fantasy)
            
            // Преобразование BookSearchResult в Book
            popularBooks = results.0.map { Book(id: $0.id, title: $0.title, authors: $0.authors, year: $0.year, coverUrl: $0.coverUrl) }
            newBooks = results.1.map { Book(id: $0.id, title: $0.title, authors: $0.authors, year: $0.year, coverUrl: $0.coverUrl) }
            recommendedBooks = results.2.map { Book(id: $0.id, title: $0.title, authors: $0.authors, year: $0.year, coverUrl: $0.coverUrl) }
            fantasyBooks = results.3.map { Book(id: $0.id, title: $0.title, authors: $0.authors, year: $0.year, coverUrl: $0.coverUrl) }
        } catch {
            self.error = "Ошибка загрузки: \(error.localizedDescription)"
            print("Loading error:", error)
        }
        
        isLoading = false
    }
    
    @MainActor
    func searchBooks(query: String) async {
        guard !query.isEmpty else {
            searchResults = []
            return
        }
        
        isLoading = true
        error = nil
        
        do {
            let results = try await apiClient.searchBooks(
                query: query,
                limit: 10,
                page: 1,
                searchType: nil,
                sortByPopularity: false,
                sortByNew: false,
                translate: false
            )
            searchResults = results.map { result in
                Book(
                    id: result.id,
                    title: result.title,
                    authors: result.authors,
                    year: result.year,
                    coverUrl: result.coverUrl
                )
            }
        } catch {
            self.error = "Ошибка поиска: \(error.localizedDescription)"
            print("Search error:", error)
        }
        
        isLoading = false
    }
}
