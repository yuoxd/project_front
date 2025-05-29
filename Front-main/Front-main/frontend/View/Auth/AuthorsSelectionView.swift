//
//  AuthorsSelectionView.swift
//  frontend
//
//  Created by 596 on 16.05.2025.
//

import SwiftUI

struct AuthorsSelectionView: View {
    @EnvironmentObject var apiClient: ApiClient
    let selectedGenres: [String]  // Принимаем выбранные жанры из предыдущего экрана
    @State private var authors: [String] = []
    @State private var selectedAuthors: Set<String> = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    @Binding var selectedTab: Tab
    let onRegistrationComplete: () -> Void
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                // Заголовок
                Text("Выберите любимых писателей")
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding(.top)
                
                // Сообщение об ошибке
                if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.caption)
                        .padding(.horizontal)
                }
                
                // Индикатор загрузки
                if isLoading {
                    ProgressView()
                        .padding()
                } else {
                    // Список авторов
                    ScrollView {
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 120))], spacing: 10) {
                            ForEach(authors, id: \.self) { author in
                                Text(author)
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(selectedAuthors.contains(author) ? Color.blue : Color.gray.opacity(0.2))
                                    .foregroundColor(selectedAuthors.contains(author) ? .white : .primary)
                                    .cornerRadius(10)
                                    .onTapGesture {
                                        if selectedAuthors.contains(author) {
                                            selectedAuthors.remove(author)
                                        } else {
                                            selectedAuthors.insert(author)
                                        }
                                    }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                
                // Кнопка завершения
                Button(action: {
                    Task {
                        await saveAuthorsAndFinish()
                    }
                }) {
                    Text("Закончить")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(selectedAuthors.isEmpty ? Color.gray : Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .disabled(selectedAuthors.isEmpty || isLoading)
                .padding(.horizontal)
                .padding(.bottom)
            }
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                Task {
                    await loadAuthors()
                }
            }
        }
    }
    
    private func loadAuthors() async {
        isLoading = true
        errorMessage = nil
        
        do {
            authors = try await apiClient.fetchAuthors()
            isLoading = false
        } catch {
            isLoading = false
            errorMessage = "Failed to load authors: \(error.localizedDescription)"
        }
    }
    
    private func saveAuthorsAndFinish() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let response = try await apiClient.updateUserPreferences(
                favoriteGenres: selectedGenres,
                favoriteAuthors: Array(selectedAuthors)
            )
            isLoading = false
            print("AuthorsSelectionView: Preferences saved, response: \(response)")
            selectedTab = .profile
            print("AuthorsSelectionView: Calling onRegistrationComplete")
            onRegistrationComplete() // Вызываем обратный вызов
        } catch {
            isLoading = false
            errorMessage = "Failed to save preferences: \(error.localizedDescription)"
        }
    }
}

