//
//  BookListView.swift
//  frontend
//
//  Created by 596 on 16.05.2025.
//

import SwiftUI

struct BookListView: View {
    @Binding var selectedTab: Tab
    @StateObject private var viewModel = BookViewModel()
    
    var body: some View {
        NavigationStack {
            ScrollView(.vertical) {
                VStack(alignment: .leading, spacing: 20) {
                    if let error = viewModel.error {
                        ErrorView(error: error)
                    }
                    
                    if viewModel.isLoading && viewModel.popularBooks.isEmpty {
                        ProgressView()
                            .frame(maxWidth: .infinity)
                    } else {
                        bookSection(title: "Популярные книги", books: viewModel.popularBooks)
                        bookSection(title: "Новинки", books: viewModel.newBooks)
                        bookSection(title: "Рекомендуем", books: viewModel.recommendedBooks)
                        bookSection(title: "Фэнтези", books: viewModel.fantasyBooks)
                    }
                }
                .padding(.vertical)
            }
            .refreshable {
                await viewModel.loadBooks()
            }
            .task {
                if viewModel.popularBooks.isEmpty {
                    await viewModel.loadBooks()
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink {
                        SearchBookView()
                    } label: {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.blue)
                    }
                }
            }
        }
    }
    
    private func bookSection(title: String, books: [Book]) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.headline)
                .padding(.horizontal)
            
            if books.isEmpty {
                Text("Нет данных")
                    .foregroundColor(.secondary)
                    .padding(.horizontal)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack(spacing: 15) {
                        ForEach(books) { book in
                            NavigationLink {
                                BookDetailView(bookId: book.id)
                            } label: {
                                BookCard(book: book)
                            }
                            .buttonStyle(.plain)
                            .onTapGesture {
                                print("NavigationLink tapped for bookId: \(book.id)") // Отладка
                            }
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
    }
}

struct ErrorView: View {
    let error: String
    
    var body: some View {
        Text(error)
            .foregroundColor(.red)
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.red.opacity(0.1))
            .cornerRadius(8)
            .padding(.horizontal)
    }
}

#Preview {
    NavigationStack {
        BookListView(selectedTab: .constant(.book))
    }
}
