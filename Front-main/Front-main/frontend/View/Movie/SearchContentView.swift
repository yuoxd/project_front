//
//  SearchContentView.swift
//  frontend
//
//  Created by 596 on 16.05.2025.
//

import SwiftUI

struct SearchContentView: View {
    @StateObject private var viewModel = ContentViewModel()
    @State private var searchQuery = ""
    @State private var contentTypeFilter: ContentTypeFilter = .all
    private let columns = [GridItem(.adaptive(minimum: 160), spacing: 16)]
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                // Search bar
                HStack(spacing: 12) {
                    SearchBar(text: $searchQuery, placeholder: "Фильмы, сериалы...") {
                        Task { await searchContent() }
                    }
                    
                    if !searchQuery.isEmpty {
                        ClearButton(action: clearSearch)
                    }
                }
                .padding(.horizontal)
                
                // Content type filter
                Picker("", selection: $contentTypeFilter) {
                    ForEach(ContentTypeFilter.allCases, id: \.self) { type in
                        Text(type.displayName).tag(type)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                .onChange(of: contentTypeFilter) { _ in
                    Task { await searchContent() }
                }
                
                // Results
                Group {
                    if viewModel.isLoading {
                        ProgressView()
                            .frame(maxHeight: .infinity)
                    } else if let error = viewModel.errorMessage {
                        ErrorView(error: error)
                    } else if viewModel.searchResults.isEmpty && !searchQuery.isEmpty {
                        EmptyStateView()
                    } else if !viewModel.searchResults.isEmpty {
                        resultsGrid
                    }
                }
                .animation(.easeInOut, value: viewModel.searchResults.map { $0.id })
            }
            .navigationTitle("Поиск")
            .background(Color(.systemGroupedBackground))
        }
    }
    
    private var resultsGrid: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(viewModel.searchResults) { item in
                    NavigationLink(
                        destination: destinationView(for: item)
                    ) {
                        ContentCardView(item: item)
                    }
                }
            }
            .padding()
        }
    }
    
    @ViewBuilder
    private func destinationView(for item: ContentItem) -> some View {
        if item.is_series {
            SeriesDetailView(seriesId: String(item.id))
        } else {
            MovieDetailView(movieId: String(item.id))
        }
    }
    
    private func searchContent() async {
        await viewModel.searchContent(query: searchQuery, contentType: contentTypeFilter.rawValue)
    }
    
    private func clearSearch() {
        searchQuery = ""
        viewModel.searchResults = []
    }
    
}

// MARK: - Components

struct SearchBar: View {
    @Binding var text: String
    let placeholder: String
    let onCommit: () -> Void
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
            
            TextField(placeholder, text: $text, onCommit: onCommit)
                .textFieldStyle(.plain)
                .tint(.accentColor)
            
            if !text.isEmpty {
                Button(action: { text = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(10)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(10)
    }
}

struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: "film")
                .font(.system(size: 40))
                .foregroundColor(.secondary)
            Text("Ничего не найдено")
                .font(.headline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

