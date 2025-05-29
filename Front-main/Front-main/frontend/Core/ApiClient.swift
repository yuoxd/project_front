//
//  ApiClient.swift
//  CineTome
//
//  Created by 596 on 22.04.2025.
//

import Foundation

class ApiClient: ObservableObject {
    @Published private(set) var token: String?
    private let baseURL: String
    private let urlSession: URLSession
    
    init(baseURL: String = "http://172.20.10.3:8001/", urlSession: URLSession = .shared) {
        self.baseURL = baseURL
        self.urlSession = urlSession
        self.token = KeychainManager.shared.getToken()
    }
    
    func fetchMovies(collectionType: CollectionType = .pop, limit: Int = 10) async throws -> [ContentItem] {
        let validatedLimit = min(max(limit, 1), 20)
        let type: String
        switch collectionType {
        case .pop: type = "TOP_100_POPULAR_FILMS"
        case .new: type = "TOP_AWAIT_FILMS"
        case .best: type = "TOP_250_BEST_FILMS"
        case .family: type = "FAMILY"
        case .vampire: type = "VAMPIRE_THEME"
        case .love: type = "LOVE_THEME"
        case .zombie: type = "ZOMBIE_THEME"
        case .comics: type = "COMICS_THEME"
        case .oskar: type = "OSKAR_WINNERS_2021"
        case .releases: type = "CLOSES_RELEASES"
        }
        
        var components = URLComponents(string: "\(baseURL)api/kp/collections")
        components?.queryItems = [
            URLQueryItem(name: "type", value: type),
            URLQueryItem(name: "page", value: "1"),
            URLQueryItem(name: "limit", value: "\(validatedLimit)")
        ]
        
        guard let url = components?.url else {
            throw APIError.invalidURL
        }
        
        return try await fetchData(from: url)
    }
    
    func fetchSeries(collectionType: CollectionType = .pop, limit: Int = 10) async throws -> [ContentItem] {
        let validatedLimit = min(max(limit, 1), 20)
        let type: String
        switch collectionType {
        case .pop: type = "TOP_250_TV_SHOWS"
        case .best: type = "TOP_250_TV_SHOWS"
        default: type = "TOP_250_TV_SHOWS"
        }
        
        var components = URLComponents(string: "\(baseURL)api/kp/collections")
        components?.queryItems = [
            URLQueryItem(name: "type", value: type),
            URLQueryItem(name: "page", value: "1"),
            URLQueryItem(name: "limit", value: "\(validatedLimit)")
        ]
        
        guard let url = components?.url else {
            throw APIError.invalidURL
        }
        
        let items = try await fetchData(from: url) as [ContentItem]
        return items.filter { $0.is_series }
    }
    
    func searchContent(query: String, contentType: String = "ALL", limit: Int = 10) async throws -> [ContentItem] {
        guard !query.isEmpty, query.count >= 2 else {
            throw APIError.invalidQuery("Query must be at least 2 characters long")
        }
        
        let validatedLimit = min(max(limit, 1), 20)
        var components = URLComponents(string: "\(baseURL)api/kp/search")
        components?.queryItems = [
            URLQueryItem(name: "query", value: query),
            URLQueryItem(name: "content_type", value: contentType),
            URLQueryItem(name: "page", value: "1"),
            URLQueryItem(name: "limit", value: "\(validatedLimit)")
        ]
        
        guard let url = components?.url else {
            throw APIError.invalidURL
        }
        
        return try await fetchData(from: url)
    }
    
    func fetchMovieDetails(movieId: String) async throws -> ContentItem {
        guard !movieId.isEmpty else {
            throw APIError.invalidQuery("Movie ID cannot be empty")
        }
        
        var components = URLComponents(string: "\(baseURL)api/kp/films/\(movieId)")
        components?.queryItems = [
            URLQueryItem(name: "with_summary", value: "true"),
            URLQueryItem(name: "with_similars", value: "true")
        ]
        
        guard let url = components?.url else {
            throw APIError.invalidURL
        }
        
        return try await fetchData(from: url)
    }
    
    func fetchSeriesDetails(seriesId: String) async throws -> ContentItem {
        guard !seriesId.isEmpty else {
            throw APIError.invalidQuery("Series ID cannot be empty")
        }
        
        var components = URLComponents(string: "\(baseURL)api/kp/series/\(seriesId)")
        components?.queryItems = [
            URLQueryItem(name: "with_summary", value: "true"),
            URLQueryItem(name: "with_seasons", value: "true")
        ]
        
        guard let url = components?.url else {
            throw APIError.invalidURL
        }
        
        return try await fetchData(from: url)
    }
    
    func searchBooks(
        query: String,
        limit: Int = 10,
        page: Int = 1,
        searchType: String? = nil,
        sortByPopularity: Bool = false,
        sortByNew: Bool = false,
        translate: Bool = false
    ) async throws -> [BookSearchResult] {
        guard !query.isEmpty else {
            throw APIError.invalidQuery("Query cannot be empty")
        }
        
        guard query.count >= 2 else {
            throw APIError.invalidQuery("Query must be at least 2 characters long")
        }
        
        var components = URLComponents(string: "\(baseURL)books/search/")
        components?.queryItems = [
            URLQueryItem(name: "query", value: query),
            URLQueryItem(name: "limit", value: "\(limit)"),
            URLQueryItem(name: "page", value: "\(page)"),
            URLQueryItem(name: "sort_by_popularity", value: "\(sortByPopularity)"),
            URLQueryItem(name: "sort_by_new", value: "\(sortByNew)"),
            URLQueryItem(name: "translate", value: "\(translate)")
        ]
        
        if let searchType = searchType {
            components?.queryItems?.append(URLQueryItem(name: "search_type", value: searchType))
        }
        
        guard let url = components?.url else {
            throw APIError.invalidURL
        }
        
        return try await fetchData(from: url)
    }
    
    func fetchBookDetails(workId: String, translate: Bool = false) async throws -> BookDetails {
        guard !workId.isEmpty else {
            throw APIError.invalidQuery("Work ID cannot be empty")
        }
        
        var components = URLComponents(string: "\(baseURL)books/\(workId)")
        components?.queryItems = [
            URLQueryItem(name: "translate", value: "\(translate)")
        ]
        
        guard let url = components?.url else {
            throw APIError.invalidURL
        }
        
        print("Request URL: \(url.absoluteString)")
        return try await fetchData(from: url)
    }
    
    func fetchBooks(category: String, limit: Int = 10, page: Int = 1) async throws -> [Book] {
        var query: String
        var searchType: String? = nil
        var sortByPopularity = false
        var sortByNew = false
        
        switch category {
        case "popular":
            query = "*"
            sortByPopularity = true
        case "new":
            query = "*"
            sortByNew = true
        case "recommended":
            query = "*"
            searchType = "recommended"
        case "genre/fantasy":
            query = "fantasy"
            searchType = "genre"
        default:
            query = category
        }
        
        let results = try await searchBooks(
            query: query.isEmpty ? "*" : query,
            limit: limit,
            page: page,
            searchType: searchType,
            sortByPopularity: sortByPopularity,
            sortByNew: sortByNew
        )
        
        return results.map { result in
            Book(
                id: result.id,
                title: result.title,
                authors: result.authors,
                year: result.year,
                coverUrl: result.coverUrl
            )
        }
    }
    
    private func fetchData<T: Decodable>(from url: URL) async throws -> T {
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        if let token = token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        let (data, response) = try await urlSession.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        
        if !(200...299).contains(httpResponse.statusCode) {
            if let errorString = String(data: data, encoding: .utf8) {
                print("Server error response: \(errorString)")
            }
            throw APIError.serverError(httpResponse.statusCode)
        }
        
        do {
            let decoder = JSONDecoder()
            return try decoder.decode(T.self, from: data)
        } catch {
            print("Decoding error: \(error)")
            throw APIError.decodingError(error)
        }
    }
    
    private func validateResponse(_ response: URLResponse, data: Data) throws {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        
        print("Status code: \(httpResponse.statusCode)")
        if data.isEmpty {
            print("Response data is empty")
            throw APIError.invalidResponse
        }
        
        if let responseString = String(data: data, encoding: .utf8) {
            print("Server response: \(responseString)")
        } else {
            print("Failed to convert response data to string")
            throw APIError.invalidResponse
        }
        
        if !(200...299).contains(httpResponse.statusCode) {
            let errorMessage = String(data: data, encoding: .utf8) ?? "Unknown error"
            switch httpResponse.statusCode {
            case 400:
                throw APIError.invalidRequest(message: errorMessage)
            case 401:
                throw APIError.unauthorized
            case 409:
                throw APIError.userAlreadyExists
            default:
                throw APIError.serverErrorWithMessage(httpResponse.statusCode, errorMessage)
            }
        }
    }
    
    func register(username: String, email: String, password: String) async throws -> User {
        guard let url = URL(string: "\(baseURL)auth/register") else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        let registrationData = [
            "username": username,
            "email": email,
            "password": password
        ]
        
        do {
            request.httpBody = try JSONEncoder().encode(registrationData)
            print("Sending registration request to: \(url.absoluteString)")
            print("Request body: \(String(data: request.httpBody!, encoding: .utf8) ?? "No body")")
            
            let (data, response) = try await urlSession.data(for: request)
            try validateResponse(response, data: data)
            
            do {
                let decoder = JSONDecoder()
                let registrationResponse = try decoder.decode(RegistrationResponse.self, from: data)
                
                let user = User(
                    id: registrationResponse.id,
                    username: registrationResponse.username,
                    email: registrationResponse.email,
                    preferences: registrationResponse.preferences
                )
                
                try await login(email: email, password: password)
                return user
            } catch {
                print("Decoding error: \(error)")
                throw APIError.decodingError(error)
            }
        } catch let urlError as URLError {
            print("URLSession error: \(urlError)")
            if urlError.code == .notConnectedToInternet {
                throw APIError.networkError("No internet connection")
            } else if urlError.code == .cannotConnectToHost {
                throw APIError.networkError("Cannot connect to server")
            } else {
                throw APIError.networkError(urlError.localizedDescription)
            }
        } catch {
            print("Registration error: \(error)")
            if let apiError = error as? APIError {
                throw apiError
            }
            throw APIError.networkError(error.localizedDescription)
        }
    }
    
    func login(email: String, password: String) async throws -> User {
        guard let url = URL(string: "\(baseURL)auth/login") else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        let credentials = LoginRequest(email: email, password: password)
        
        do {
            request.httpBody = try JSONEncoder().encode(credentials)
            print("Sending login request to: \(url.absoluteString)")
            print("Request body: \(String(data: request.httpBody!, encoding: .utf8) ?? "No body")")
            
            let (data, response) = try await urlSession.data(for: request)
            try validateResponse(response, data: data)
            
            do {
                let decoder = JSONDecoder()
                let authResponse = try decoder.decode(AuthResponse.self, from: data)
                
                print("Received token: \(authResponse.token)")
                self.token = authResponse.token
                KeychainManager.shared.saveToken(authResponse.token)
                
                return try await fetchCurrentUser()
            } catch {
                print("Decoding error: \(error)")
                throw APIError.decodingError(error)
            }
        } catch let urlError as URLError {
            print("URLSession error: \(urlError)")
            if urlError.code == .notConnectedToInternet {
                throw APIError.networkError("No internet connection")
            } else if urlError.code == .cannotConnectToHost {
                throw APIError.networkError("Cannot connect to server")
            } else {
                throw APIError.networkError(urlError.localizedDescription)
            }
        } catch {
            print("Login error: \(error)")
            if let apiError = error as? APIError {
                throw apiError
            }
            throw APIError.networkError(error.localizedDescription)
        }
    }
    
    func logout() {
        token = nil
        KeychainManager.shared.deleteToken()
    }
    
    func fetchCurrentUser() async throws -> User {
        guard let token = token else {
            throw APIError.unauthorized
        }
        
        guard let url = URL(string: "\(baseURL)users/me") else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let (data, response) = try await urlSession.data(for: request)
        try validateResponse(response, data: data)
        
        do {
            let decoder = JSONDecoder()
            return try decoder.decode(User.self, from: data)
        } catch {
            print("Decoding error: \(error)")
            throw APIError.decodingError(error)
        }
    }
    
    func fetchGenres() async throws -> [String] {
        guard let url = URL(string: "\(baseURL)users/genres") else {
            throw APIError.invalidURL
        }
        return try await fetchData(from: url)
    }
    
    func fetchAuthors() async throws -> [String] {
        guard let url = URL(string: "\(baseURL)users/authors") else {
            throw APIError.invalidURL
        }
        return try await fetchData(from: url)
    }
    
    func updateUserPreferences(favoriteGenres: [String]?, favoriteAuthors: [String]?) async throws -> User {
        guard let url = URL(string: "\(baseURL)users/me") else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        if let token = token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        } else {
            throw APIError.unauthorized
        }
        
        let preferencesData = UserPreferences(
            favoriteGenres: favoriteGenres ?? [],
            favoriteAuthors: favoriteAuthors ?? []
        )
        let requestBody = UpdatePreferencesRequest(
            favoriteGenres: preferencesData.favoriteGenres ?? [],
            favoriteAuthors: preferencesData.favoriteAuthors ?? []
        )
        
        do {
            request.httpBody = try JSONEncoder().encode(requestBody)
        } catch {
            print("Encoding error: \(error)")
            throw APIError.invalidRequest(message: "Failed to encode request body")
        }
        
        let (data, response) = try await urlSession.data(for: request)
        try validateResponse(response, data: data)
        
        do {
            let decoder = JSONDecoder()
            return try decoder.decode(User.self, from: data)
        } catch {
            print("Decoding error: \(error)")
            throw APIError.decodingError(error)
        }
    }
    
    func generateContentSummary(title: String, content_type: String, author: String? = nil, year: String? = nil) async throws -> String {
        let urlString = "\(baseURL)ai/generate-summary"
        guard let url = URL(string: urlString) else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let requestBody: [String: Any] = [
            "title": title,
            "content_type": content_type,
            "author": author ?? "",
            "year": year ?? ""
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        
        let (data, _) = try await urlSession.data(for: request)
        if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
           let summary = json["summary"] as? String {
            return summary
        }
        throw APIError.decodingError(NSError(domain: "", code: 0, userInfo: nil))
    }
}
