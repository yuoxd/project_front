//
//  ContentViewModel.swift
//  CineTome
//
//  Created by 596 on 22.04.2025.
//

import Foundation

class ContentViewModel: ObservableObject {
    @Published var collections: [CollectionType: [ContentItem]] = [:]
    @Published var seriesCollections: [CollectionType: [ContentItem]] = [:]
    @Published var searchResults: [ContentItem] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let apiClient = ApiClient()
    
    @MainActor
    func loadCollections() async {
        isLoading = true
        errorMessage = nil
        
        // Загрузка фильмов
        async let popMovies = apiClient.fetchMovies(collectionType: .pop)
        async let newMovies = apiClient.fetchMovies(collectionType: .new)
        async let bestMovies = apiClient.fetchMovies(collectionType: .best)
        async let familyMovies = apiClient.fetchMovies(collectionType: .family)
        async let vampireMovies = apiClient.fetchMovies(collectionType: .vampire)
        async let loveMovies = apiClient.fetchMovies(collectionType: .love)
        async let zombieMovies = apiClient.fetchMovies(collectionType: .zombie)
        async let comicsMovies = apiClient.fetchMovies(collectionType: .comics)
        async let oskarMovies = apiClient.fetchMovies(collectionType: .oskar)
        async let releasesMovies = apiClient.fetchMovies(collectionType: .releases)
        
        // Загрузка сериалов
        async let popSeries = apiClient.fetchSeries(collectionType: .pop)
        async let bestSeries = apiClient.fetchSeries(collectionType: .best)
        
        do {
            let results = try await (
                popMovies: popMovies,
                newMovies: newMovies,
                bestMovies: bestMovies,
                familyMovies: familyMovies,
                vampireMovies: vampireMovies,
                loveMovies: loveMovies,
                zombieMovies: zombieMovies,
                comicsMovies: comicsMovies,
                oskarMovies: oskarMovies,
                releasesMovies: releasesMovies,
                popSeries: popSeries,
                bestSeries: bestSeries
            )
            collections[.pop] = results.popMovies
            collections[.new] = results.newMovies
            collections[.best] = results.bestMovies
            collections[.family] = results.familyMovies
            collections[.vampire] = results.vampireMovies
            collections[.love] = results.loveMovies
            collections[.zombie] = results.zombieMovies
            collections[.comics] = results.comicsMovies
            collections[.oskar] = results.oskarMovies
            collections[.releases] = results.releasesMovies
            seriesCollections[.pop] = results.popSeries
            seriesCollections[.best] = results.bestSeries
            print("Loaded collections: \(collections.count) movie collections, \(seriesCollections.count) series collections") // Отладка
        } catch {
            errorMessage = "Ошибка загрузки: \(error.localizedDescription)"
            print("Load collections error:", error)
        }
        
        isLoading = false
    }
    
    @MainActor
    func searchContent(query: String, contentType: String) async {
        guard !query.isEmpty else {
            searchResults = []
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            let results = try await apiClient.searchContent(
                query: query,
                contentType: contentType, // Уже в правильном формате
                limit: 10
            )
            searchResults = results
        } catch {
            errorMessage = "Ошибка поиска: \(error.localizedDescription)"
            print("Search error:", error)
            searchResults = []
        }
        
        isLoading = false
    }
}
