//
//  GenreSelectionView.swift
//  frontend
//
//  Created by 596 on 16.05.2025.
//

import SwiftUI

struct GenreSelectionView: View {
    @EnvironmentObject var apiClient: ApiClient
    @State private var genres: [String] = []
    @State private var selectedGenres: Set<String> = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var isNavigatingToAuthors = false
    @Binding var selectedTab: Tab
    let onRegistrationComplete: () -> Void
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                // Заголовок
                Text("Выберите любимые жанры")
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
                    // Список жанров
                    ScrollView {
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 120))], spacing: 10) {
                            ForEach(genres, id: \.self) { genre in
                                Text(genre)
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(selectedGenres.contains(genre) ? Color.blue : Color.gray.opacity(0.2))
                                    .foregroundColor(selectedGenres.contains(genre) ? .white : .primary)
                                    .cornerRadius(10)
                                    .onTapGesture {
                                        if selectedGenres.contains(genre) {
                                            selectedGenres.remove(genre)
                                        } else {
                                            selectedGenres.insert(genre)
                                        }
                                    }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                
                // Кнопка продолжения
                Button(action: {
                    Task {
                        await saveGenresAndContinue()
                    }
                }) {
                    Text("Продолжить")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(selectedGenres.isEmpty ? Color.gray : Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .disabled(selectedGenres.isEmpty || isLoading)
                .padding(.horizontal)
                .padding(.bottom)
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(isPresented: $isNavigatingToAuthors) {
                AuthorsSelectionView(
                    selectedGenres: Array(selectedGenres),
                    selectedTab: $selectedTab,
                    onRegistrationComplete: onRegistrationComplete // Передаём дальше
                )
                .environmentObject(apiClient)
            }
            .onAppear {
                Task {
                    await loadGenres()
                }
            }
        }
    }
    
    private func loadGenres() async {
        isLoading = true
        errorMessage = nil
        
        do {
            genres = try await apiClient.fetchGenres()
            isLoading = false
        } catch {
            isLoading = false
            errorMessage = "Failed to load genres: \(error.localizedDescription)"
        }
    }
    
    private func saveGenresAndContinue() async {
        isLoading = true
        errorMessage = nil
        
        do {
            _ = try await apiClient.updateUserPreferences(
                favoriteGenres: Array(selectedGenres),
                favoriteAuthors: nil
            )
            isLoading = false
            print("GenreSelectionView: Genres saved, navigating to AuthorsSelectionView")
            isNavigatingToAuthors = true
        } catch {
            isLoading = false
            errorMessage = "Failed to save preferences: \(error.localizedDescription)"
        }
    }
}

