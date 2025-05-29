//
//  BookDetailView.swift
//  CineTome
//
//  Created by 596 on 22.04.2025.
//

import SwiftUI

struct BookDetailView: View {
    let bookId: String
    @StateObject private var viewModel = BookDetailViewModel()
    @State private var aiSummary: String?
    @State private var isGeneratingSummary = false
    @State private var showGenerationError = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                if viewModel.isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                } else if let error = viewModel.error {
                    ErrorView(error: error)
                } else if let book = viewModel.book {
                    // Обложка книги
                    AsyncImage(url: URL(string: book.coverUrl ?? "")) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFit()
                                .frame(height: 280)
                                .shadow(radius: 6)
                        case .failure:
                            placeholderImage
                        case .empty:
                            ProgressView()
                                .frame(width: 200, height: 280)
                        @unknown default:
                            placeholderImage
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.bottom, 10)

                    // Основная информация
                    VStack(alignment: .leading, spacing: 8) {
                        Text(book.title)
                            .font(.title.bold())
                        
                        if !book.authors.isEmpty {
                            InfoBadge(text: book.authors.joined(separator: ", "), icon: "person")
                        }
                        
                        if let year = book.publishYear {
                            InfoBadge(text: String(year), icon: "calendar")
                        }
                    }
                    .padding(.horizontal)

                    // Описание книги (исправленная проверка)
                    if let description = book.description, !description.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Описание")
                                .font(.headline.bold())
                            
                            Text(description)
                                .font(.body)
                        }
                        .padding()
                        .background(Color.gray.opacity(0.08))
                        .cornerRadius(10)
                        .padding(.horizontal)
                    }

                    // AI Генерация описания
                    VStack(spacing: 15) {
                        if let summary = aiSummary {
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Text("AI Анализ")
                                        .font(.headline.bold())
                                    Image(systemName: "sparkles")
                                        .foregroundColor(.yellow)
                                }
                                
                                Text(summary)
                                    .padding()
                                    .background(Color.purple.opacity(0.08))
                                    .cornerRadius(12)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color.purple.opacity(0.3), lineWidth: 1)
                                    )
                            }
                        }
                        
                        Button(action: generateSummary) {
                            HStack {
                                if isGeneratingSummary {
                                    ProgressView()
                                        .tint(.white)
                                } else {
                                    Image(systemName: aiSummary == nil ? "sparkles" : "arrow.clockwise")
                                    Text(aiSummary == nil ? "Сгенерировать анализ" : "Обновить анализ")
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(aiSummary == nil ? Color.purple : Color.purple.opacity(0.7))
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            .padding(.horizontal)
                        }
                        .disabled(isGeneratingSummary)
                    }
                    .padding(.top, 10)
                }
            }
            .padding()
        }
        .navigationTitle(viewModel.book?.title ?? "Книга")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Ошибка генерации", isPresented: $showGenerationError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Не удалось сгенерировать анализ. Попробуйте позже.")
        }
        .task {
            await viewModel.loadBookDetails(bookId: bookId)
        }
    }
    
    private var placeholderImage: some View {
        ZStack {
            Color.gray.opacity(0.3)
            Image(systemName: "book.closed.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 100)
                .foregroundColor(.white)
        }
        .frame(height: 280)
        .cornerRadius(8)
    }
    
    private func generateSummary() {
        guard let book = viewModel.book else { return }
        
        Task {
            isGeneratingSummary = true
            do {
                aiSummary = try await viewModel.generateSummary(
                    title: book.title,
                    authors: book.authors,
                    year: book.publishYear.map { String($0) }
                )
            } catch {
                showGenerationError = true
            }
            isGeneratingSummary = false
        }
    }
}

class BookDetailViewModel: ObservableObject {
    @Published var book: BookDetails?
    @Published var isLoading = false
    @Published var error: String?
    
    private let apiClient = ApiClient()
    
    @MainActor
    func loadBookDetails(bookId: String, translate: Bool = false) async {
        isLoading = true
        error = nil
        
        do {
            let bookDetails = try await apiClient.fetchBookDetails(workId: bookId, translate: translate)
            self.book = bookDetails
        } catch {
            self.error = "Ошибка загрузки: \(error.localizedDescription)"
            print("Loading error:", error)
        }
        
        isLoading = false
    }
    
    @MainActor
    func generateSummary(title: String, authors: [String], year: String?) async throws -> String {
        isLoading = true
        defer { isLoading = false }
        
        do {
            return try await apiClient.generateContentSummary(
                title: title,
                content_type: "book",
                author: authors.joined(separator: ", "),
                year: year
            )
        } catch {
            self.error = "Ошибка генерации: \(error.localizedDescription)"
            throw error
        }
    }
}

#Preview {
    NavigationStack {
        BookDetailView(bookId: "OL82537W")
    }
}
