//
//  SearchBookView.swift
//  frontend
//
//  Created by 596 on 16.05.2025.
//

import SwiftUI

struct SearchBookView: View {
    @StateObject private var viewModel = BookViewModel()
    @State private var searchQuery = ""
    
    private let columns = [GridItem(.adaptive(minimum: 160), spacing: 16)]
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                // Search bar
                HStack(spacing: 12) {
                    SearchBar(text: $searchQuery, placeholder: "Название, автор...") {
                        Task { await viewModel.searchBooks(query: searchQuery) }
                    }
                    
                    if !searchQuery.isEmpty {
                        ClearButton(action: clearSearch)
                    }
                }
                .padding(.horizontal)
                
                // Results
                VStack {
                    if viewModel.isLoading {
                        ProgressView()
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else if let error = viewModel.error {
                        ErrorView(error: error)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else if viewModel.searchResults.isEmpty && !searchQuery.isEmpty {
                        EmptyView(icon: "book", text: "Книги не найдены")
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else if !viewModel.searchResults.isEmpty {
                        resultsGrid
                    }
                }
            }
            .navigationTitle("Книги")
            .background(Color(.systemGroupedBackground))
        }
    }
    
    private var resultsGrid: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(viewModel.searchResults, id: \.id) { book in
                    NavigationLink {
                        BookDetailView(bookId: book.id)
                    } label: {
                        BookCard(book: book)
                            .frame(height: 260)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding()
            .animation(.easeInOut, value: viewModel.searchResults)
        }
    }
    
    private func clearSearch() {
        searchQuery = ""
        viewModel.searchResults = []
    }
}
// Заглушки для компонентов


struct EmptyView: View {
    let icon: String
    let text: String
    
    var body: some View {
        VStack {
            Image(systemName: icon)
                .font(.system(size: 50))
                .foregroundColor(.secondary)
            Text(text)
                .foregroundColor(.secondary)
                .padding()
        }
    }
}


struct ClearButton: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: "xmark.circle.fill")
                .font(.system(size: 20))
                .foregroundColor(.secondary)
                .transition(.opacity)
        }
    }
}

#Preview {
    SearchBookView()
        .preferredColorScheme(.light)
}
