//
//  MovieDetailView.swift
//  CineTome
//
//  Created by 596 on 23.04.2025.
//

import SwiftUI

struct MovieDetailView: View {
    let movieId: String
    @StateObject private var viewModel = MovieDetailViewModel()
    @State private var aiSummary: String?
    @State private var isGeneratingSummary = false
    @State private var showGenerationError = false
    
    var body: some View {
        VStack {
            if viewModel.isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if let error = viewModel.errorMessage {
                ErrorView(error: error)
            } else if let movie = viewModel.movie {
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        AsyncImage(url: URL(string: movie.poster ?? "")) { phase in
                            switch phase {
                            case .success(let image):
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                            case .failure:
                                placeholderImage
                            case .empty:
                                ProgressView()
                            @unknown default:
                                placeholderImage
                            }
                        }
                        .frame(width: 220, height: 330)
                        .cornerRadius(12)
                        .shadow(radius: 8)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text(movie.title)
                                .font(.title.bold())
                            
                            HStack(spacing: 12) {
                                if let year = movie.year {
                                    InfoBadge(text: String(year), icon: "calendar")
                                }
                                
                                if let duration = movie.filmLengthMinutes {
                                    InfoBadge(text: "\(duration) мин", icon: "clock")
                                }
                                
                                if let ageLimit = movie.rating_age_limits {
                                    InfoBadge(text: ageLimit, icon: "exclamationmark.triangle")
                                }
                            }
                            
                            if let genres = movie.genres, !genres.isEmpty {
                                InfoBadge(text: genres.joined(separator: ", "), icon: "film")
                            }
                            
                            if let countries = movie.countries, !countries.isEmpty {
                                InfoBadge(text: countries.joined(separator: ", "), icon: "globe")
                            }
                            
                            RatingView(kpRating: movie.rating_kinopoisk, imdbRating: movie.rating_imdb)
                        }
                        .padding(.horizontal)
                        
                        VStack(spacing: 15) {
                            if let summary = aiSummary ?? movie.ai_summary {
                                VStack(alignment: .leading, spacing: 8) {
                                    HStack {
                                        Text("AI Описание")
                                            .font(.headline.bold())
                                        Image(systemName: "sparkles")
                                            .foregroundColor(.yellow)
                                    }
                                    
                                    Text(summary)
                                        .padding()
                                        .background(Color.blue.opacity(0.08))
                                        .cornerRadius(12)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(Color.blue.opacity(0.3), lineWidth: 1)
                                        )
                                }
                            }
                            
                            Button(action: generateSummary) {
                                HStack {
                                    if isGeneratingSummary {
                                        ProgressView()
                                            .tint(.white)
                                    } else {
                                        Image(systemName: (aiSummary ?? movie.ai_summary) == nil ? "sparkles" : "arrow.clockwise")
                                        Text((aiSummary ?? movie.ai_summary) == nil ? "Сгенерировать описание" : "Обновить описание")
                                    }
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background((aiSummary ?? movie.ai_summary) == nil ? Color.blue : Color.blue.opacity(0.7))
                                .foregroundColor(.white)
                                .cornerRadius(10)
                                .padding(.horizontal)
                            }
                            .disabled(isGeneratingSummary)
                        }
                        .padding(.top, 10)
                    }
                }
                .navigationTitle(movie.title)
                .navigationBarTitleDisplayMode(.inline)
            }
        }
        .alert("Ошибка генерации", isPresented: $showGenerationError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Не удалось сгенерировать описание. Попробуйте позже.")
        }
        .task {
            await viewModel.loadMovieDetails(movieId: movieId)
        }
    }
    
    private var placeholderImage: some View {
        ZStack {
            Color.gray.opacity(0.3)
            Image(systemName: "film")
                .resizable()
                .scaledToFit()
                .frame(width: 60)
                .foregroundColor(.white)
        }
        .frame(width: 220, height: 330)
        .cornerRadius(12)
    }
    
    private func generateSummary() {
            guard let movie = viewModel.movie else { return }
            
            Task {
                isGeneratingSummary = true
                do {
                    // Проверяем и разупаковываем year
                    let yearString: String = movie.year.map { String($0) } ?? ""
                    aiSummary = try await viewModel.generateSummary(
                        title: movie.title,
                        year: yearString
                    )
                } catch {
                    showGenerationError = true
                }
                isGeneratingSummary = false
            }
        }
}

class MovieDetailViewModel: ObservableObject {
    @Published var movie: ContentItem?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let apiClient: ApiClient
    
    init(apiClient: ApiClient = ApiClient()) {
        self.apiClient = apiClient
    }
    
    @MainActor
    func loadMovieDetails(movieId: String) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let movieDetails = try await apiClient.fetchMovieDetails(movieId: movieId)
            self.movie = movieDetails
        } catch {
            errorMessage = handleError(error)
        }
        
        isLoading = false
    }
    
    func generateSummary(title: String, year: String?) async throws -> String {
        do {
            return try await apiClient.generateContentSummary(
                title: title,
                content_type: "movie",
                author: nil,
                year: year
            )
        } catch {
            throw error
        }
    }
    
    private func handleError(_ error: Error) -> String {
        switch error {
        case APIError.serverError(let code):
            return "Server error: \(code)"
        case APIError.decodingError:
            return "Failed to parse movie data"
        case APIError.invalidQuery:
            return "Invalid movie ID"
        default:
            return "Failed to load movie details: \(error.localizedDescription)"
        }
    }
}


struct InfoBadge: View {
    let text: String
    let icon: String
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.caption)
            Text(text)
                .font(.subheadline)
        }
        .foregroundColor(.secondary)
    }
}

struct RatingView: View {
    let kpRating: Double?
    let imdbRating: Double?
    
    var body: some View {
        HStack(spacing: 16) {
            if let kpRating = kpRating {
                RatingBadge(value: String(format: "%.1f", kpRating), systemName: "star.fill", color: .orange)
            }
            
            if let imdbRating = imdbRating {
                RatingBadge(value: String(format: "%.1f", imdbRating), systemName: "star.fill", color: .blue)
            }
        }
        .padding(.vertical, 4)
    }
}

struct RatingBadge: View {
    let value: String
    let systemName: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: systemName)
                .foregroundColor(color)
            
            Text(value)
                .font(.subheadline.bold())
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(color.opacity(0.2))
        .cornerRadius(6)
    }
}

#Preview {
    NavigationStack {
        MovieDetailView(movieId: "535341")
    }
}

