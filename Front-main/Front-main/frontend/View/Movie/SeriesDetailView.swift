//
//  SeriesDetailView.swift
//  CineTome
//
//  Created by 596 on 23.04.2025.
//

import SwiftUI

struct SeriesDetailView: View {
    let seriesId: String
    @StateObject private var viewModel = SeriesDetailViewModel()
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
            } else if let series = viewModel.series {
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        posterView(series: series)
                        mainInfoView(series: series)
                        aiDescriptionView(series: series)
                        seasonsView(seasons: series.seasons_info)
                    }
                    .padding(.vertical)
                }
                .navigationTitle(series.title)
                .navigationBarTitleDisplayMode(.inline)
            }
        }
        .alert("Ошибка генерации", isPresented: $showGenerationError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Не удалось сгенерировать описание. Попробуйте позже.")
        }
        .task {
            await viewModel.loadSeriesDetails(seriesId: seriesId)
        }
    }
    
    private var placeholderImage: some View {
        ZStack {
            Color.gray.opacity(0.3)
            Image(systemName: "tv")
                .resizable()
                .scaledToFit()
                .frame(width: 60)
                .foregroundColor(.white)
        }
        .frame(width: 220, height: 330)
        .cornerRadius(12)
    }
    
    private func generateSummary() {
        guard let series = viewModel.series else { return }
        
        Task {
            isGeneratingSummary = true
            do {
                aiSummary = try await viewModel.generateSummary(
                    title: series.title,
                    year: String(series.year ?? 11)
                )
            } catch {
                showGenerationError = true
            }
            isGeneratingSummary = false
        }
    }
    
    // MARK: - Subviews
    private func posterView(series: ContentItem) -> some View {
        AsyncImage(url: URL(string: series.poster ?? "")) { phase in
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
    }
    
    private func mainInfoView(series: ContentItem) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(series.title)
                .font(.title.bold())
            
            HStack(spacing: 12) {
                if let year = series.year {
                    InfoBadge(text: String(year), icon: "calendar")
                }
                
                if let seasonCount = series.seasons_info?.count, seasonCount > 0 {
                    InfoBadge(text: "\(seasonCount) сезон\(seasonCount > 1 ? "ов" : "")", icon: "square.stack")
                }
                
                if let episodeCount = series.seasons_info?.reduce(0) { $0 + ($1.episodes?.count ?? 0) }, episodeCount > 0 {
                    InfoBadge(text: "\(episodeCount) эпизод\(episodeCount > 1 ? "ов" : "")", icon: "play.tv")
                }
            }
            
            if let genres = series.genres, !genres.isEmpty {
                InfoBadge(text: genres.joined(separator: ", "), icon: "film")
            }
            
            RatingView(kpRating: series.rating_kinopoisk, imdbRating: series.rating_imdb)
        }
        .padding(.horizontal)
    }
    
    private func aiDescriptionView(series: ContentItem) -> some View {
        VStack(spacing: 15) {
            if let summary = aiSummary ?? series.ai_summary {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("AI Описание")
                            .font(.headline.bold())
                        Image(systemName: "sparkles")
                            .foregroundColor(.yellow)
                    }
                    
                    Text(summary)
                        .padding()
                        .background(Color.green.opacity(0.08))
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.green.opacity(0.3), lineWidth: 1)
                        )
                }
            }
            
            Button(action: generateSummary) {
                HStack {
                    if isGeneratingSummary {
                        ProgressView()
                            .tint(.white)
                    } else {
                        Image(systemName: (aiSummary ?? series.ai_summary) == nil ? "sparkles" : "arrow.clockwise")
                        Text((aiSummary ?? series.ai_summary) == nil ? "Сгенерировать описание" : "Обновить описание")
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background((aiSummary ?? series.ai_summary) == nil ? Color.green : Color.green.opacity(0.7))
                .foregroundColor(.white)
                .cornerRadius(10)
                .padding(.horizontal)
            }
            .disabled(isGeneratingSummary)
        }
        .padding(.top, 10)
    }
    
    private func seasonsView(seasons: [ContentItem.SeasonInfo]?) -> some View {
        Group {
            if let seasons = seasons, !seasons.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Сезоны")
                        .font(.headline.bold())
                    ForEach(seasons, id: \.number) { season in
                        if let number = season.number {
                            HStack {
                                Text("Сезон \(number)")
                                    .font(.subheadline)
                                if let year = season.year {
                                    Text("(\(year))")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                                if let episodeCount = season.episodes?.count, episodeCount > 0 {
                                    Text("\(episodeCount) эп.")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.top, 10)
            }
        }
    }
}

class SeriesDetailViewModel: ObservableObject {
    @Published var series: ContentItem?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let apiClient = ApiClient()
    
    @MainActor
    func loadSeriesDetails(seriesId: String) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let series = try await apiClient.fetchSeriesDetails(seriesId: seriesId)
            self.series = series
        } catch {
            errorMessage = "Ошибка загрузки: \(error.localizedDescription)"
            print("Loading error:", error)
        }
        
        isLoading = false
    }
    
    @MainActor
    func generateSummary(title: String, year: String?) async throws -> String {
        // Не устанавливаем isLoading, так как используем isGeneratingSummary
        do {
            return try await apiClient.generateContentSummary(
                title: title,
                content_type: "series",
                year: year
            )
        } catch {
            errorMessage = "Ошибка генерации: \(error.localizedDescription)"
            throw error
        }
    }
}

#Preview {
    NavigationStack {
        SeriesDetailView(seriesId: "123")
    }
}
